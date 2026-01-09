#!/usr/bin/env python3
"""
fetch-agents.py

Haalt agent componenten op vanuit de agent-capabilities repository en kopieert ze naar deze workspace.
Dit script is bedoeld voor initieel ophalen van agents vanuit een centrale bron repository.

ARCHITECTUUR:
  Charters worden NIET gefetched - deze zijn lokaal in governance/agent-charters/ en agent-charters/.
  Alleen agent componenten worden gefetched: prompts, runners, orchestrations, buildplans, pipelines.

GEBRUIK:
  # Dry-run (toon wat er opgehaald zou worden)
  python fetch-agents.py --dry-run
  
  # Haal alle agents op
  python fetch-agents.py
  
  # Haal specifieke agents op
  python fetch-agents.py --agents cdm-architect logisch-data-modelleur
  
  # Gebruik een andere bron repository
  python fetch-agents.py --source https://github.com/hans-blok/agent-capabilities.git

Agent: u95.python-script-schrijver
Versie: 2.0
Datum: 09-01-2026
"""

import argparse
import logging
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path
from typing import List, Optional


class AgentFetcher:
    """Fetches agent artifacts from a source repository."""
    
    def __init__(
        self, 
        target_root: Path, 
        source_url: str = "https://github.com/hans-blok/agent-capabilities.git",
        dry_run: bool = False,
        update_scripts: bool = False,
        platform: str = 'github-actions'
    ):
        """Initialize the fetcher."""
        self.target_root = target_root
        self.source_url = source_url
        self.dry_run = dry_run
        self.update_scripts = update_scripts
        self.platform = platform
        self.copied_files = []
        self.temp_dir = None
        self.source_root = None
        self.logger = None
    
    def setup_logging(self):
        """Setup file-based logging in target/logs directory."""
        log_dir = self.target_root / "logs"
        log_dir.mkdir(parents=True, exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_file = log_dir / f"fetch-agents_{timestamp}.log"
        
        # Configure logging
        self.logger = logging.getLogger('fetch-agents')
        self.logger.setLevel(logging.DEBUG)
        
        # File handler
        file_handler = logging.FileHandler(log_file, encoding='utf-8')
        file_handler.setLevel(logging.DEBUG)
        file_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        file_handler.setFormatter(file_formatter)
        self.logger.addHandler(file_handler)
        
        self.log(f"Logging naar: {log_file}", "INFO")
    
    def log(self, message: str, prefix: str = "INFO"):
        """Log a message with prefix."""
        colors = {
            "INFO": "\033[96m",
            "SUCCESS": "\033[92m",
            "WARNING": "\033[93m",
            "ERROR": "\033[91m",
            "DRY-RUN": "\033[95m"
        }
        reset = "\033[0m"
        color = colors.get(prefix, "")
        print(f"{color}[{prefix}] {message}{reset}")
        
        # Also log to file if logger is configured
        if self.logger:
            log_methods = {
                "INFO": self.logger.info,
                "SUCCESS": self.logger.info,
                "WARNING": self.logger.warning,
                "ERROR": self.logger.error,
                "DRY-RUN": self.logger.info
            }
            log_method = log_methods.get(prefix, self.logger.info)
            log_method(message)
    
    def clone_source(self) -> Path:
        """Clone source repository to temporary location."""
        self.log(f"Klonen van: {self.source_url}")
        
        if self.dry_run:
            self.log("Would clone source repository", "DRY-RUN")
            # Create fake temp dir for dry-run
            return Path(tempfile.mkdtemp())
        
        temp_dir = Path(tempfile.mkdtemp())
        self.temp_dir = temp_dir
        
        try:
            result = subprocess.run(
                ["git", "clone", self.source_url, str(temp_dir)],
                capture_output=True,
                text=True,
                check=True
            )
            self.log(f"Repository gekloond naar: {temp_dir}")
            return temp_dir
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Git clone mislukt: {e.stderr}")
    
    def validate_workspaces(self):
        """Validate target workspace."""
        if not self.target_root.exists():
            raise FileNotFoundError(f"Target workspace niet gevonden: {self.target_root}")
        
        # Check if source has agent structure (for dry-run with real source)
        if self.source_root and not self.dry_run:
            source_prompts = self.source_root / "agent-componenten" / "prompts"
            if not source_prompts.exists():
                raise FileNotFoundError(f"Geen agent prompts gevonden in source: {source_prompts}")
        
        self.log(f"Source: {self.source_url}")
        self.log(f"Target: {self.target_root}")
        self.log(f"Platform: {self.platform}")
    
    def get_available_agents(self) -> List[str]:
        """Get list of available agents from source."""
        if self.dry_run:
            # Return dummy list for dry-run
            self.log("Would scan for available agents", "DRY-RUN")
            return []
        
        prompts_dir = self.source_root / "agent-componenten" / "prompts"
        if not prompts_dir.exists():
            self.log(f"Prompts directory niet gevonden: {prompts_dir}", "WARNING")
            return []
        
        agents = []
        for prompt_file in prompts_dir.glob("*.prompt.md"):
            # Extract agent name (e.g., "b.cdm-architect.prompt.md" -> "cdm-architect")
            name = prompt_file.stem.replace(".prompt", "")
            # Remove phase prefix (e.g., "b.cdm-architect" -> "cdm-architect")
            if '.' in name:
                name = '.'.join(name.split('.')[1:])
            agents.append(name)
        
        return sorted(agents)
    
    def find_agent_files(self, agent_name: str) -> dict:
        """
        Find all files belonging to an agent.
        
        NOTE: Charters worden NIET gefetched - deze zijn lokaal in governance/agent-charters/.
        We fetchen alleen de gegenereerde componenten: prompts, runners, orchestrations, etc.
        """
        files = {
            'prompt': None,
            'runner': None,
            'orchestration': None,
            'buildplan': None,
            'pipeline': None,
            'agent': None  # Agent definition (.agent.md) - deprecated, kept for backward compatibility
        }
        
        if self.dry_run:
            self.log(f"Would find files for agent: {agent_name}", "DRY-RUN")
            return files
        
        # Find prompt (pattern: *.<agent-name>.prompt.md)
        prompts_dir = self.source_root / "agent-componenten" / "prompts"
        for prompt_file in prompts_dir.glob(f"*.{agent_name}.prompt.md"):
            files['prompt'] = prompt_file
            break
        
        # Find agent definition (pattern: *.<agent-name>.agent.md)
        # NOTE: Dit wordt deprecated - agent definitions (.agent.md) zijn verwijderd.
        # Alleen charters (.agent.charter) blijven bestaan en die zijn lokaal in governance/agent-charters/.
        agents_dir = self.source_root / "agent-componenten" / "agents"
        if agents_dir.exists():
            for agent_file in agents_dir.glob(f"*.{agent_name}.agent.md"):
                files['agent'] = agent_file
                break
        
        # Find runner (pattern: *.<agent-name>.py in runners/)
        runners_dir = self.source_root / "agent-componenten" / "runners"
        if runners_dir.exists():
            for runner_file in runners_dir.glob(f"*.{agent_name}.py"):
                files['runner'] = runner_file
                break
        
        # Find orchestration (pattern: *.<agent-name>.orchestration.yaml in orchestrations/)
        orch_dir = self.source_root / "agent-componenten" / "orchestrations"
        if orch_dir.exists():
            for orch_file in orch_dir.glob(f"*.{agent_name}.orchestration.yaml"):
                files['orchestration'] = orch_file
                break
        
        # Find buildplan (pattern: *.<agent-name>.json in buildplans/)
        buildplans_dir = self.source_root / "agent-componenten" / "buildplans"
        if buildplans_dir.exists():
            for buildplan_file in buildplans_dir.glob(f"*.{agent_name}.json"):
                files['buildplan'] = buildplan_file
                break
        
        # Find pipeline (pattern: *.<agent-name>.* in pipelines/generated/<platform>/)
        pipelines_dir = self.source_root / "agent-componenten" / "pipelines" / "generated" / self.platform
        if pipelines_dir.exists():
            for pipeline_file in pipelines_dir.glob(f"*.{agent_name}.*"):
                files['pipeline'] = pipeline_file
                break
        
        return files
    
    def copy_file(self, source: Path, target: Path):
        """Copy a file from source to target."""
        if self.dry_run:
            self.log(f"Would copy: {source.name} -> {target.relative_to(self.target_root)}", "DRY-RUN")
            self.copied_files.append(source)
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
            self.log(f"Copied: {source.name} -> {target.relative_to(self.target_root)}")
            self.copied_files.append(source)
    
    def fetch_agent(self, agent_name: str):
        """Fetch a single agent to target workspace."""
        self.log(f"Ophalen agent: {agent_name}")
        
        files = self.find_agent_files(agent_name)
        
        if not files['prompt'] and not self.dry_run:
            self.log(f"Agent '{agent_name}' niet gevonden (geen prompt)", "WARNING")
            return False
        
        # Copy prompt
        if files['prompt']:
            source_prompt = files['prompt']
            target_prompt = self.target_root / ".github" / "prompts" / source_prompt.name
            self.copy_file(source_prompt, target_prompt)
        
        # Copy agent definition if exists
        if files['agent']:
            source_agent = files['agent']
            rel_agent = source_agent.relative_to(self.source_root)
            target_agent = self.target_root / rel_agent
            self.copy_file(source_agent, target_agent)
        else:
            if not self.dry_run:
                self.log(f"Geen agent definitie gevonden voor {agent_name}", "WARNING")
        
        # Copy buildplan if exists
        if files['buildplan']:
            source_buildplan = files['buildplan']
            rel_buildplan = source_buildplan.relative_to(self.source_root)
            target_buildplan = self.target_root / rel_buildplan
            self.copy_file(source_buildplan, target_buildplan)
        else:
            if not self.dry_run:
                self.log(f"Geen buildplan gevonden voor {agent_name}", "WARNING")
        
        # Copy runner if exists
        if files['runner']:
            source_runner = files['runner']
            rel_runner = source_runner.relative_to(self.source_root)
            target_runner = self.target_root / rel_runner
            self.copy_file(source_runner, target_runner)
        else:
            if not self.dry_run:
                self.log(f"Geen runner gevonden voor {agent_name}", "WARNING")
        
        # Copy orchestration if exists
        if files['orchestration']:
            source_orch = files['orchestration']
            rel_orch = source_orch.relative_to(self.source_root)
            target_orch = self.target_root / rel_orch
            self.copy_file(source_orch, target_orch)
        else:
            if not self.dry_run:
                self.log(f"Geen orchestration gevonden voor {agent_name}", "WARNING")
        
        # Copy pipeline if exists
        if files['pipeline']:
            if self.platform == 'github-actions':
                target_pipeline_dir = self.target_root / ".github" / "workflows"
            elif self.platform == 'gitlab-ci':
                target_pipeline_dir = self.target_root  # GitLab CI files in root
            else:
                target_pipeline_dir = self.target_root / ".pipelines"
            
            self.copy_file(files['pipeline'], target_pipeline_dir / files['pipeline'].name)
        else:
            if not self.dry_run:
                self.log(f"Geen pipeline gevonden voor {agent_name} (platform: {self.platform})", "WARNING")
        
        return True
    
    def fetch_scripts(self):
        """Fetch scripts directory (including fetch-agents.py itself)."""
        if not self.update_scripts:
            return
        
        if self.dry_run:
            self.log("Would copy scripts directory", "DRY-RUN")
            return
        
        source_scripts = self.source_root / "scripts"
        target_scripts = self.target_root / "scripts"
        
        if not source_scripts.exists():
            self.log("Geen scripts directory gevonden", "WARNING")
            return
        
        self.log("Bijwerken scripts directory...")
        
        # Copy all Python files from scripts directory
        for script_file in source_scripts.glob("*.py"):
            target_file = target_scripts / script_file.name
            self.copy_file(script_file, target_file)
    
    def fetch_workflows(self):
        """Fetch workflow pipelines (multi-agent compositions)."""
        if self.dry_run:
            self.log("Would copy workflow pipelines", "DRY-RUN")
            return
        
        pipelines_dir = self.source_root / "agent-componenten" / "pipelines" / "generated" / self.platform
        if not pipelines_dir.exists():
            self.log("Geen workflow pipelines directory gevonden", "WARNING")
            return
        
        # Find all workflow pipelines (pattern: workflow.*.*)
        workflow_count = 0
        self.log("Ophalen workflows...")
        for workflow_file in pipelines_dir.glob("workflow.*"):
            if self.platform == 'github-actions':
                target_pipeline_dir = self.target_root / ".github" / "workflows"
            elif self.platform == 'gitlab-ci':
                target_pipeline_dir = self.target_root  # GitLab CI files in root
            else:
                target_pipeline_dir = self.target_root / ".pipelines"
            
            self.copy_file(workflow_file, target_pipeline_dir / workflow_file.name)
            workflow_count += 1
        
        if workflow_count > 0:
            self.log(f"Workflows opgehaald: {workflow_count}", "SUCCESS")
        else:
            self.log("Geen workflows gevonden")
    
    def fetch_agents_yaml(self):
        """Fetch agents.yaml configuration."""
        if self.dry_run:
            self.log("Would copy agents.yaml", "DRY-RUN")
            return
        
        source_yaml = self.source_root / ".github" / "copilot" / "agents.yaml"
        target_yaml = self.target_root / ".github" / "copilot" / "agents.yaml"
        
        if source_yaml.exists():
            self.copy_file(source_yaml, target_yaml)
        else:
            self.log("Geen agents.yaml gevonden", "WARNING")
    
    def cleanup(self):
        """Clean up temporary directory."""
        if self.temp_dir and self.temp_dir.exists():
            try:
                # On Windows, git files can be read-only, so we need to handle permissions
                def handle_remove_readonly(func, path, exc):
                    """Error handler for Windows readonly files."""
                    import stat
                    import os
                    if not os.access(path, os.W_OK):
                        # Change file to be writable
                        os.chmod(path, stat.S_IWUSR | stat.S_IREAD)
                        func(path)
                    else:
                        raise
                
                shutil.rmtree(self.temp_dir, onerror=handle_remove_readonly)
                self.log(f"Temporary directory verwijderd")
            except Exception as e:
                self.log(f"Kon temporary directory niet volledig verwijderen: {e}", "WARNING")
                self.log(f"Je kunt handmatig verwijderen: {self.temp_dir}", "INFO")
    
    def run(self, agent_names: Optional[List[str]] = None):
        """Run the fetch operation."""
        try:
            # Setup logging to file
            if not self.dry_run:
                self.setup_logging()
            
            if self.dry_run:
                self.log("DRY-RUN MODE - geen bestanden worden gekopieerd", "DRY-RUN")
            
            # Clone source repository
            self.source_root = self.clone_source()
            
            self.validate_workspaces()
            
            # Get agents to fetch
            if agent_names:
                agents = agent_names
            else:
                agents = self.get_available_agents()
                if agents:
                    self.log(f"Ophalen van alle {len(agents)} agents")
                else:
                    self.log("Geen agents gevonden" if not self.dry_run else "Would fetch all agents", 
                            "WARNING" if not self.dry_run else "DRY-RUN")
                    if self.dry_run:
                        agents = []  # Continue with empty list for dry-run
            
            # Fetch each agent
            success_count = 0
            for agent_name in agents:
                if self.fetch_agent(agent_name):
                    success_count += 1
            
            # Fetch workflows (multi-agent pipelines)
            self.fetch_workflows()
            
            # Fetch agents.yaml
            self.fetch_agents_yaml()
            
            # Fetch scripts if requested
            self.fetch_scripts()
            
            # Summary
            self.log(f"\nSamenvatting:", "SUCCESS")
            self.log(f"  Agents opgehaald: {success_count}/{len(agents) if agents else 0}")
            self.log(f"  Bestanden gekopieerd: {len(self.copied_files)}")
            if self.update_scripts:
                self.log(f"  Scripts bijgewerkt: ja")
            
            if self.dry_run:
                self.log("\nDit was een dry-run. Voer opnieuw uit zonder --dry-run om op te halen.", "DRY-RUN")
            
            return 0
            
        except Exception as e:
            self.log(f"Fout tijdens fetch: {e}", "ERROR")
            raise
        finally:
            self.cleanup()


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Haal agent artefacten op vanuit een bron repository',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Voorbeelden:
  # Dry-run
  python fetch-agents.py --dry-run
  
  # Haal alle agents op
  python fetch-agents.py
  
  # Haal specifieke agents op
  python fetch-agents.py --agents cdm-architect logisch-data-modelleur
  
  # Update scripts directory (inclusief fetch-agents.py zelf)
  python fetch-agents.py --update-scripts
  
  # Gebruik andere bron
  python fetch-agents.py --source https://github.com/other/repo.git
        """
    )
    
    parser.add_argument('--agents', nargs='+',
                       help='Specifieke agent namen om op te halen (zonder fase prefix)')
    
    parser.add_argument('--dry-run', action='store_true',
                       help='Toon wat er opgehaald zou worden zonder te kopiëren')
    
    parser.add_argument('--update-scripts', action='store_true',
                       help='Werk scripts directory bij (inclusief fetch-agents.py)')
    
    parser.add_argument('--source', 
                       default="https://github.com/hans-blok/agent-capabilities.git",
                       help='Bron repository URL (default: agent-capabilities)')
    
    parser.add_argument('--target', default=None,
                       help='Target workspace directory (default: current directory)')
    
    parser.add_argument('--platform', default='github-actions',
                       help='Pipeline platform om op te halen (github-actions, gitlab-ci)')
    
    args = parser.parse_args()
    
    target = Path(args.target).resolve() if args.target else Path.cwd()
    
    fetcher = AgentFetcher(
        target, 
        source_url=args.source, 
        dry_run=args.dry_run, 
        update_scripts=args.update_scripts,
        platform=args.platform
    )
    return fetcher.run(agent_names=args.agents)


if __name__ == '__main__':
    sys.exit(main())
