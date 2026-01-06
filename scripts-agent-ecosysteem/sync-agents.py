#!/usr/bin/env python3
"""
DIT SCRIPT NIET DRAAIEN IN AGENT-CAPABILITIES REPO!

sync-agents.py

Synchroniseert agent artefacten van deze workspace naar een andere workspace.
Kopiëert prompts, runners en orchestraties zodat andere projecten dezelfde agents kunnen gebruiken.

GEBRUIK:
  # Dry-run (toon wat er gekopieerd zou worden)
  python scripts-agent-ecosysteem/sync-agents.py --target ../mijn-project --dry-run
  
  # Kopieer alle agents
  python scripts-agent-ecosysteem/sync-agents.py --target ../mijn-project
  
  # Kopieer specifieke agents
  python scripts-agent-ecosysteem/sync-agents.py --target ../mijn-project --agents cdm-architect ldm
  
  # Clone eerst een repository
  git clone https://github.com/user/target-repo.git ../mijn-project
  python scripts-agent-ecosysteem/sync-agents.py --target ../mijn-project

Agent: sync-agents.py
Versie: 1.0
Datum: 06-01-2026
"""

import argparse
import shutil
import sys
from pathlib import Path
from typing import List, Optional


class AgentSyncer:
    """Synchronizes agent artifacts to another workspace."""
    
    def __init__(self, source_root: Path, target_root: Path, dry_run: bool = False):
        """Initialize the syncer."""
        self.source_root = source_root
        self.target_root = target_root
        self.dry_run = dry_run
        self.copied_files = []
        self.skipped_files = []
    
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
    
    def validate_workspaces(self):
        """Validate source and target workspaces."""
        if not self.source_root.exists():
            raise FileNotFoundError(f"Source workspace niet gevonden: {self.source_root}")
        
        if not self.target_root.exists():
            raise FileNotFoundError(
                f"Target workspace niet gevonden: {self.target_root}\n"
                f"Clone eerst de repository:\n"
                f"  git clone <repository-url> {self.target_root}"
            )
        
        # Check if source has agent structure
        source_prompts = self.source_root / ".github" / "prompts"
        if not source_prompts.exists():
            raise FileNotFoundError(f"Geen agent prompts gevonden in source: {source_prompts}")
        
        self.log(f"Source: {self.source_root}")
        self.log(f"Target: {self.target_root}")
    
    def get_available_agents(self) -> List[str]:
        """Get list of available agents from source."""
        prompts_dir = self.source_root / ".github" / "prompts"
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
        """Find all files belonging to an agent."""
        files = {
            'prompt': None,
            'runner': None,
            'orchestration': None
        }
        
        # Find prompt (pattern: *.<agent-name>.prompt.md)
        prompts_dir = self.source_root / ".github" / "prompts"
        for prompt_file in prompts_dir.glob(f"*.{agent_name}.prompt.md"):
            files['prompt'] = prompt_file
            break
        
        # Find runner and orchestration (search in all phase directories)
        scripts_base = self.source_root / "scripts"
        orch_base = self.source_root / "orchestrations"
        
        for phase_dir in scripts_base.glob("*"):
            if phase_dir.is_dir():
                runner = phase_dir / f"{agent_name}.py"
                if runner.exists():
                    files['runner'] = runner
                    break
        
        for phase_dir in orch_base.glob("*"):
            if phase_dir.is_dir():
                orch = phase_dir / f"{agent_name}.orchestration.yaml"
                if orch.exists():
                    files['orchestration'] = orch
                    break
        
        return files
    
    def copy_file(self, source: Path, target: Path):
        """Copy a file from source to target."""
        if self.dry_run:
            self.log(f"Would copy: {source.relative_to(self.source_root)} -> {target.relative_to(self.target_root)}", "DRY-RUN")
            self.copied_files.append(source)
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
            self.log(f"Copied: {source.relative_to(self.source_root)} -> {target.relative_to(self.target_root)}")
            self.copied_files.append(source)
    
    def sync_agent(self, agent_name: str):
        """Sync a single agent to target workspace."""
        self.log(f"Syncing agent: {agent_name}")
        
        files = self.find_agent_files(agent_name)
        
        if not files['prompt']:
            self.log(f"Agent '{agent_name}' niet gevonden (geen prompt)", "WARNING")
            return False
        
        # Copy prompt
        source_prompt = files['prompt']
        target_prompt = self.target_root / ".github" / "prompts" / source_prompt.name
        self.copy_file(source_prompt, target_prompt)
        
        # Copy runner if exists
        if files['runner']:
            source_runner = files['runner']
            rel_runner = source_runner.relative_to(self.source_root)
            target_runner = self.target_root / rel_runner
            self.copy_file(source_runner, target_runner)
        else:
            self.log(f"Geen runner gevonden voor {agent_name}", "WARNING")
        
        # Copy orchestration if exists
        if files['orchestration']:
            source_orch = files['orchestration']
            rel_orch = source_orch.relative_to(self.source_root)
            target_orch = self.target_root / rel_orch
            self.copy_file(source_orch, target_orch)
        else:
            self.log(f"Geen orchestration gevonden voor {agent_name}", "WARNING")
        
        return True
    
    def sync_agents_yaml(self):
        """Sync agents.yaml configuration."""
        source_yaml = self.source_root / ".github" / "copilot" / "agents.yaml"
        target_yaml = self.target_root / ".github" / "copilot" / "agents.yaml"
        
        if source_yaml.exists():
            self.copy_file(source_yaml, target_yaml)
        else:
            self.log("Geen agents.yaml gevonden", "WARNING")
    
    def run(self, agent_names: Optional[List[str]] = None):
        """Run the sync operation."""
        try:
            self.validate_workspaces()
            
            if self.dry_run:
                self.log("DRY-RUN MODE - geen bestanden worden gekopieerd", "DRY-RUN")
            
            # Get agents to sync
            if agent_names:
                agents = agent_names
            else:
                agents = self.get_available_agents()
                self.log(f"Syncing alle {len(agents)} agents")
            
            # Sync each agent
            success_count = 0
            for agent_name in agents:
                if self.sync_agent(agent_name):
                    success_count += 1
            
            # Sync agents.yaml
            self.sync_agents_yaml()
            
            # Summary
            self.log(f"\nSamenvatting:", "SUCCESS")
            self.log(f"  Agents gesynchroniseerd: {success_count}/{len(agents)}")
            self.log(f"  Bestanden gekopieerd: {len(self.copied_files)}")
            
            if self.dry_run:
                self.log("\nDit was een dry-run. Voer opnieuw uit zonder --dry-run om te kopiëren.", "DRY-RUN")
            
            return 0
            
        except Exception as e:
            self.log(f"Fout tijdens sync: {e}", "ERROR")
            raise


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Synchroniseer agent artefacten naar een andere workspace',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Voorbeelden:
  # Dry-run
  python scripts-agent-ecosysteem/sync-agents.py --target ../mijn-project --dry-run
  
  # Sync alle agents
  python scripts-agent-ecosysteem/sync-agents.py --target ../mijn-project
  
  # Sync specifieke agents
  python scripts-agent-ecosysteem/sync-agents.py --target ../mijn-project --agents cdm-architect ldm
  
  # Clone eerst een repo
  git clone https://github.com/user/repo.git ../target-workspace
  python scripts-agent-ecosysteem/sync-agents.py --target ../target-workspace
        """
    )
    
    parser.add_argument('--target', required=True,
                       help='Target workspace directory (absoluut of relatief pad)')
    
    parser.add_argument('--agents', nargs='+',
                       help='Specifieke agent namen om te syncen (zonder fase prefix)')
    
    parser.add_argument('--dry-run', action='store_true',
                       help='Toon wat er gekopieerd zou worden zonder te kopiëren')
    
    parser.add_argument('--source', default=None,
                       help='Source workspace directory (default: current directory)')
    
    args = parser.parse_args()
    
    source = Path(args.source) if args.source else Path.cwd()
    target = Path(args.target).resolve()
    
    syncer = AgentSyncer(source, target, dry_run=args.dry_run)
    return syncer.run(agent_names=args.agents)


if __name__ == '__main__':
    sys.exit(main())
