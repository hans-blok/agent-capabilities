#!/usr/bin/env python3
"""
make-agent.py

V1 orchestrator: maakt (of ververst) agent artefacten op basis van een bestaand charter.

VOORWAARDEN:
  - Er moet een charter bestaan onder: <repoRoot>/charters.agents/<phase>/std.agent.charter.<phase>.<agentName>.md
    (Phase is bv: a.trigger, b.architectuur, c.specificatie, etc.)

GEBRUIK:
  python scripts-agent-ecosysteem/make-agent.py --agent-name "founding-hypothesis-owner"

Agent: make-agent.py
Versie: 1.0
Datum: 04-01-2026
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
import subprocess
import yaml


class AgentMaker:
    """Creates or refreshes agent artifacts based on an existing charter."""
    
    def __init__(self, agent_name: str, repo_root: Optional[str] = None, 
                 charter_root: str = "https://github.com/hans-blok/standard.git",
                 local_charter_clone: Optional[str] = None):
        """Initialize the agent maker."""
        self.agent_name = agent_name
        self.repo_root = Path(repo_root) if repo_root else Path.cwd()
        self.charter_root = charter_root
        self.local_charter_clone = local_charter_clone
        self.plan = None
    
    def log(self, message: str, prefix: str = "INFO"):
        """Log a message with prefix."""
        colors = {
            "INFO": "\033[96m",      # Cyan
            "SUCCESS": "\033[92m",   # Green
            "WARNING": "\033[93m",   # Yellow
            "ERROR": "\033[91m"      # Red
        }
        reset = "\033[0m"
        color = colors.get(prefix, "")
        # Encode for Windows console
        try:
            print(f"{color}[{prefix}] {message}{reset}")
        except UnicodeEncodeError:
            # Fallback for Windows console encoding issues
            safe_message = message.encode('ascii', 'replace').decode('ascii')
            print(f"{color}[{prefix}] {safe_message}{reset}")
    
    def _update_git_repo(self, repo_path: Path):
        """Update a git repository by pulling latest changes."""
        try:
            self.log(f"Updaten charter repository: {repo_path.name}", "INFO")
            result = subprocess.run(
                ["git", "pull"],
                cwd=str(repo_path),
                capture_output=True,
                text=True,
                timeout=30
            )
            if result.returncode == 0:
                if "Already up to date" not in result.stdout:
                    self.log(f"Charter repository geüpdatet", "SUCCESS")
            else:
                self.log(f"Git pull warning: {result.stderr.strip()}", "WARNING")
        except Exception as e:
            self.log(f"Kon charter repository niet updaten: {e}", "WARNING")
    
    def resolve_charter_path(self) -> Path:
        """Find the charter file for the given agent name."""
        # Check if local clone path is provided
        if self.local_charter_clone:
            charters_path = Path(self.local_charter_clone) / "artefacten" / "3-charters-agents"
            # Update local clone
            self._update_git_repo(Path(self.local_charter_clone))
        # Check if charter_root is a GitHub URL
        elif self.charter_root.startswith("https://github.com"):
            # Expect local clone in parent directory
            repo_name = self.charter_root.rstrip('.git').split('/')[-1]
            potential_path = self.repo_root.parent / repo_name / "artefacten" / "3-charters-agents"
            
            if not potential_path.exists():
                raise FileNotFoundError(
                    f"Charter repository niet gekloond. Voer uit:\n"
                    f"  cd {self.repo_root.parent}\n"
                    f"  git clone {self.charter_root}\n"
                    f"Of specificeer --local-charter-clone pad"
                )
            # Update local clone before using it
            self._update_git_repo(self.repo_root.parent / repo_name)
            charters_path = potential_path
        else:
            # Treat as relative path
            charters_path = self.repo_root / self.charter_root
        
        if not charters_path.exists():
            raise FileNotFoundError(f"CharterRoot niet gevonden: {charters_path}")
        
        # Search for file ending with ".<agentname>.md"
        pattern = f"*.{self.agent_name}.md"
        matches = list(charters_path.rglob(pattern))
        
        if not matches:
            raise FileNotFoundError(
                f"Geen charter gevonden voor AgentName '{self.agent_name}' "
                f"onder {charters_path} (pattern: {pattern})."
            )
        
        return matches[0]
    
    def get_phase_from_charter_path(self, charter_path: Path) -> str:
        """Extract phase from charter path."""
        # Try to extract from filename pattern: std.agent.charter.<phase>.<name>.md
        filename = charter_path.stem  # Without .md
        parts_name = filename.split('.')
        if len(parts_name) >= 5 and parts_name[2] == 'charter':
            # Format: std.agent.charter.<phase>.<name>
            return parts_name[3]  # The phase part
        
        raise ValueError(f"Kan phase niet bepalen uit charter naam: {charter_path.name}")
    
    def validate_phase_from_charter_content(self, charter_path: Path, expected_phase: str) -> bool:
        """Validate phase by reading SAFe Phase Alignment section from charter content."""
        try:
            with open(charter_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Map phase prefixes to SAFe phase names
            phase_mapping = {
                'a': 'A. Trigger',
                'b': 'B. Architectuur',
                'c': 'C. Specificatie',
                'd': 'D. Ontwerp',
                'e': 'E. Bouw',
                'f': 'F. Validatie',
                'g': 'G. Deployment',
                'u': 'U. Utility',
                '0': '0. Setup'
            }
            
            # Get phase prefix
            phase_prefix = expected_phase.split('.')[0] if '.' in expected_phase else expected_phase[0]
            expected_safe_phase = phase_mapping.get(phase_prefix)
            
            if not expected_safe_phase:
                self.log(f"Onbekende fase prefix: {phase_prefix}", "WARNING")
                return True  # Continue anyway
            
            # For utility agents, check for "Utility (U) agent" in the section
            if phase_prefix == 'u':
                if 'Utility (U) agent' in content or 'utility-agent' in content:
                    self.log(f"✓ Charter fase validatie geslaagd: Utility Agent", "SUCCESS")
                    return True
            
            # Check if the expected phase has "✅ Ja" in the SAFe Phase Alignment table
            # Look for pattern like "| B. Architectuur | ✅ Ja"
            pattern = rf'\|\s*{re.escape(expected_safe_phase)}\s*\|[^|]*✅\s*Ja'
            
            if re.search(pattern, content):
                self.log(f"✓ Charter fase validatie geslaagd: {expected_safe_phase}", "SUCCESS")
                return True
            else:
                self.log(f"Charter bevat mogelijk niet de verwachte fase: {expected_safe_phase}", "WARNING")
                self.log(f"  Controleer '## 4. SAFe Phase Alignment' sectie in charter", "WARNING")
                return True  # Continue anyway, maar met waarschuwing
                
        except Exception as e:
            self.log(f"Kon charter inhoud niet valideren: {e}", "WARNING")
            return True  # Continue anyway
    
    def create_build_plan(self) -> Dict:
        """Create a build plan for the agent."""
        charter_path = self.resolve_charter_path()
        phase = self.get_phase_from_charter_path(charter_path)
        
        # Validate phase against charter content
        self.validate_phase_from_charter_content(charter_path, phase)
        
        agent_id = f"std.{phase}.{self.agent_name}"
        
        # Extract phase prefix (e.g., "d.ontwerp" -> "d")
        phase_prefix = phase.split('.')[0] if '.' in phase else phase[0]
        
        # Create charter URL for GitHub reference
        charter_filename = charter_path.name
        charter_url = f"https://github.com/hans-blok/standard/blob/main/artefacten/3-charters-agents/{charter_filename}"
        
        plan = {
            "agentName": self.agent_name,
            "phase": phase,
            "agentId": agent_id,
            "repoRoot": str(self.repo_root.resolve()),
            "charterRoot": self.charter_root,
            "charterPath": str(charter_path),
            "charterUrl": charter_url,
            "promptPath": str(self.repo_root / "agent-componenten" / "prompts" / f"{phase_prefix}.{self.agent_name}.prompt.md"),
            "runnerPath": str(self.repo_root / "agent-componenten" / "runners" / f"{phase_prefix}.{self.agent_name}.py"),
            "orchestrationPath": str(self.repo_root / "agent-componenten" / "orchestrations" / f"{phase}.{self.agent_name}.orchestration.yaml"),
            "agentDefinitionPath": str(self.repo_root / "agent-componenten" / "agents" / f"{phase_prefix}.{self.agent_name}.agent.md"),
            "outputRoot": "<project-workspace>/artefacten",
            "buildPlanPath": str(self.repo_root / "agent-componenten" / "buildplans" / f"{phase_prefix}.{self.agent_name}.json"),
            "qualityGates": [
                "Nederlands B1",
                "Geen technische implementatiedetails in prompt",
                "Max 3 aannames (indien van toepassing)",
                "Output is Markdown"
            ],
            "runtime": {
                "llmProvider": "anthropic",
                "model": "claude-sonnet",
                "adapter": "Invoke-LLM (stub in runner)"
            },
            "generatedOn": datetime.now().isoformat()
        }
        
        return plan
    
    def write_plan_json(self, plan: Dict):
        """Write the build plan to a JSON file."""
        plan_path = Path(plan["buildPlanPath"])
        plan_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(plan_path, 'w', encoding='utf-8') as f:
            json.dump(plan, f, indent=2, ensure_ascii=False)
        
        self.log(f"Build plan geschreven naar: {plan_path}")
    
    def invoke_builder(self, script_name: str, plan_path: str):
        """Invoke a builder script."""
        scripts_dir = self.repo_root / "scripts"
        script_path = scripts_dir / script_name
        
        if not script_path.exists():
            raise FileNotFoundError(f"Builder script ontbreekt: {script_path}")
        
        self.log(f"Aanroepen builder: {script_name}")
        
        # Call Python builder
        result = subprocess.run(
            [sys.executable, str(script_path), "--plan-path", plan_path],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            self.log(f"Builder fout: {result.stderr}", "ERROR")
            raise RuntimeError(f"Builder {script_name} gefaald met code {result.returncode}")
        
        if result.stdout:
            print(result.stdout)
    
    def test_agent_completion(self, plan: Dict):
        """Test that all required agent files exist."""
        required_paths = [
            plan["promptPath"],
            plan["runnerPath"],
            plan["orchestrationPath"],
            plan["buildPlanPath"]
        ]
        
        missing = [p for p in required_paths if not Path(p).exists()]
        
        if missing:
            missing_str = "\n- ".join(missing)
            raise FileNotFoundError(
                f"Agent completion faalt. Ontbrekende bestanden:\n- {missing_str}"
            )
    
    def run(self):
        """Execute the agent creation process."""
        try:
            self.log(f"Starten agent build voor: {self.agent_name}")
            
            # Create build plan
            self.plan = self.create_build_plan()
            self.write_plan_json(self.plan)
            
            # Invoke builders
            self.invoke_builder("prompt-builder.py", self.plan["buildPlanPath"])
            self.invoke_builder("runner-builder.py", self.plan["buildPlanPath"])
            self.invoke_builder("orchestration-builder.py", self.plan["buildPlanPath"])
            
            # Generate agent definition
            self.generate_agent_definition()
            
            # Test completion
            self.test_agent_completion(self.plan)
            
            # Success message
            self.log(f"Agent build klaar: {self.plan['agentId']}", "SUCCESS")
            print(f" - Prompt:        {self.plan['promptPath']}")
            print(f" - Runner:        {self.plan['runnerPath']}")
            print(f" - Orchestration: {self.plan['orchestrationPath']}")
            print(f" - Agent def:     {self.plan['agentDefinitionPath']}")
            print(f" - Build plan:    {self.plan['buildPlanPath']}")
            
            return 0
        
        except Exception as e:
            self.log(f"Fout tijdens agent build: {e}", "ERROR")
            raise
    
    def generate_agent_definition(self):
        """Generate agent definition markdown file."""
        self.log("Genereren agent definitie...")
        
        agent_def_path = Path(self.plan['agentDefinitionPath'])
        agent_def_path.parent.mkdir(parents=True, exist_ok=True)
        
        agent_id = self.plan['agentId']
        agent_name = self.plan['agentName']
        charter_url = self.plan['charterUrl']
        runner_filename = Path(self.plan['runnerPath']).name
        
        content = f"""# {agent_name}

**Agent ID:** `{agent_id}`

## Beschrijving
Deze agent is gegenereerd vanuit het charter in de standard repository.

## Charter
Voor de volledige specificatie, zie: [{charter_url}]({charter_url})

## Componenten
- **Prompt:** Minimale prompt met charter referentie
- **Runner:** Python script voor command-line executie
- **Orchestration:** YAML configuratie voor workflow
- **Build Plan:** JSON metadata voor regeneratie

## Gebruik
Activeer via:
- Command line: `python agent-componenten/runners/{runner_filename}`
- Als workspace agent (na sync)
"""
        
        with open(agent_def_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        self.log(f"Agent definitie geschreven: {agent_def_path.relative_to(self.repo_root)}")


# Pipeline Generation
# -------------------

class PipelineGenerator:
    """Base class voor platform-specifieke pipeline generators."""
    def translate(self, definition: dict) -> str:
        """Vertaal platform-agnostische definitie naar platform-specifiek."""
        raise NotImplementedError

    def _steps_to_script(self, steps: list) -> list:
        script_lines = []
        for step in steps:
            action = step.get('action')
            if action == 'run':
                script_lines.extend(step.get('command', '').strip().split('\n'))
        return script_lines

class GitHubActionsGenerator(PipelineGenerator):
    """Genereert een GitHub Actions workflow."""
    def translate(self, definition: dict) -> str:
        import yaml
        
        steps = []
        for step in definition.get('steps', []):
            action = step.get('action')
            step_id = step.get('id')
            
            if action == 'checkout':
                steps.append({'name': step_id, 'uses': 'actions/checkout@v4'})
            elif action == 'setup-python':
                steps.append({
                    'name': step_id, 
                    'uses': 'actions/setup-python@v5', 
                    'with': step.get('with')
                })
            elif action == 'run':
                steps.append({'name': step_id, 'run': step.get('command')})
            elif action == 'upload-artifact':
                steps.append({
                    'name': step_id, 
                    'uses': 'actions/upload-artifact@v4', 
                    'with': step.get('with')
                })

        workflow = {
            'name': definition.get('name'),
            'on': {'workflow_dispatch': {'inputs': definition.get('trigger', {}).get('inputs', {})}},
            'jobs': {
                'run-agent': {
                    'runs-on': definition.get('environment', {}).get('runner', 'ubuntu-latest'),
                    'steps': steps
                }
            }
        }
        
        # Add notifications if defined
        notifications = definition.get('notifications', {})
        if 'on-failure' in notifications and 'slack' in notifications['on-failure']:
            slack_config = notifications['on-failure']['slack']
            workflow['jobs']['run-agent']['steps'].append({
                'name': 'Notify on Failure',
                'if': 'failure()',
                'uses': 'slackapi/slack-github-action@v1.25.0',
                'with': {
                    'channel-id': slack_config.get('channel'),
                    'slack-message': slack_config.get('message')
                }
            })

        return yaml.dump(workflow, sort_keys=False, indent=2)

class GitLabCIGenerator(PipelineGenerator):
    """Genereert een GitLab CI pipeline."""
    def translate(self, definition: dict) -> str:
        import yaml

        script = self._steps_to_script(definition.get('steps', []))
        
        job_name = definition.get('name', 'agent-job').lower().replace(' ', '-')
        
        pipeline = {
            job_name: {
                'stage': 'agent',
                'image': f"python:{definition.get('environment', {}).get('python-version', '3.11')}",
                'rules': [{'if': '$CI_PIPELINE_SOURCE == "web"'}],
                'script': script
            }
        }
        
        # Artifacts
        for step in definition.get('steps', []):
            if step.get('action') == 'upload-artifact':
                pipeline[job_name]['artifacts'] = {
                    'name': step.get('with', {}).get('name'),
                    'paths': [step.get('with', {}).get('path')]
                }
        
        # Notifications
        notifications = definition.get('notifications', {})
        if 'on-failure' in notifications and 'slack' in notifications['on-failure']:
            slack_config = notifications['on-failure']['slack']
            pipeline[job_name]['after_script'] = [
                f"if [ $CI_JOB_STATUS == 'failed' ]; then "
                f"apk add --no-cache curl; "
                f"curl -X POST -H 'Content-type: application/json' "
                f"--data '{{\"text\":\"{slack_config.get('message')}\"}}' "
                f"$SLACK_WEBHOOK_URL; "
                f"fi"
            ]

        return yaml.dump(pipeline, sort_keys=False, indent=2)

PLATFORM_GENERATORS = {
    'github-actions': GitHubActionsGenerator,
    'gitlab-ci': GitLabCIGenerator,
}

def generate_pipelines_for_agent(agent_name: str, phase: str, repo_root: Path, platforms: list):
    """Genereert platform-specifieke pipelines voor een agent."""
    import yaml
    definition_path = repo_root / 'agent-componenten' / 'pipelines' / 'definitions' / f"{phase}.{agent_name}.pipeline.yml"
    
    if not definition_path.exists():
        print(f"[\033[93mWARNING\033[0m] Geen pipeline definitie gevonden voor {agent_name} op {definition_path}")
        return

    with open(definition_path, 'r') as f:
        definition = yaml.safe_load(f)

    for platform in platforms:
        if platform not in PLATFORM_GENERATORS:
            print(f"[\033[93mWARNING\033[0m] Geen generator voor platform '{platform}'. Overgeslagen.")
            continue
        
        generator = PLATFORM_GENERATORS[platform]()
        platform_yaml = generator.translate(definition['pipeline'])
        
        ext = 'workflow.yml' if platform == 'github-actions' else 'gitlab-ci.yml'
        output_path = repo_root / 'agent-componenten' / 'pipelines' / 'generated' / platform / f"{phase}.{agent_name}.{ext}"
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(platform_yaml)
        
        print(f"[\033[92mSUCCESS\033[0m] Generated {platform} pipeline for {agent_name}")

def regenerate_all_pipelines(repo_root: Path, platforms: list):
    """Regenereert alle pipelines voor de opgegeven platforms."""
    definitions_dir = repo_root / 'agent-componenten' / 'pipelines' / 'definitions'
    for definition_file in definitions_dir.glob('*.yml'):
        parts = definition_file.stem.split('.')
        phase = parts[0]
        agent_name = ".".join(parts[1:-1]) # Handle names with dots
        generate_pipelines_for_agent(agent_name, phase, repo_root, platforms)


# -------------------


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Maakt (of ververst) agent artefacten op basis van een bestaand charter',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument("--agent-name", help="De naam van de agent (bv. 'founding-hypothesis-owner').")
    parser.add_argument("--platforms", help="Comma-separated lijst van pipeline platforms om te genereren (bv. github-actions,gitlab-ci).", default="github-actions,gitlab-ci")
    parser.add_argument("--regenerate-all-pipelines", action="store_true", help="Regenereer alle pipelines voor de opgegeven platforms.")
    
    args = parser.parse_args()

    # Converteer platforms string naar lijst
    platforms_list = [p.strip() for p in args.platforms.split(',')]

    if args.regenerate_all_pipelines:
        repo_root = Path.cwd()
        regenerate_all_pipelines(repo_root, platforms_list)
        print("[\033[92mSUCCESS\033[0m] Alle pipelines zijn opnieuw gegenereerd.")
        sys.exit(0)

    if not args.agent_name:
        parser.error("--agent-name is vereist, tenzij --regenerate-all-pipelines wordt gebruikt.")

    
    maker = AgentMaker(
        agent_name=args.agent_name
    )
    
    return maker.run()


if __name__ == '__main__':
    sys.exit(main())


# Pipeline Generation
# -------------------

class PipelineGenerator:
    """Base class voor platform-specifieke pipeline generators."""
    def translate(self, definition: dict) -> str:
        """Vertaal platform-agnostische definitie naar platform-specifiek."""
        raise NotImplementedError

    def _steps_to_script(self, steps: list) -> list:
        script_lines = []
        for step in steps:
            action = step.get('action')
            if action == 'run':
                script_lines.extend(step.get('command', '').strip().split('\n'))
        return script_lines

class GitHubActionsGenerator(PipelineGenerator):
    """Genereert een GitHub Actions workflow."""
    def translate(self, definition: dict) -> str:
        import yaml
        
        steps = []
        for step in definition.get('steps', []):
            action = step.get('action')
            step_id = step.get('id')
            
            if action == 'checkout':
                steps.append({'name': step_id, 'uses': 'actions/checkout@v4'})
            elif action == 'setup-python':
                steps.append({
                    'name': step_id, 
                    'uses': 'actions/setup-python@v5', 
                    'with': step.get('with')
                })
            elif action == 'run':
                steps.append({'name': step_id, 'run': step.get('command')})
            elif action == 'upload-artifact':
                steps.append({
                    'name': step_id, 
                    'uses': 'actions/upload-artifact@v4', 
                    'with': step.get('with')
                })

        workflow = {
            'name': definition.get('name'),
            'on': {'workflow_dispatch': {'inputs': definition.get('trigger', {}).get('inputs', {})}},
            'jobs': {
                'run-agent': {
                    'runs-on': definition.get('environment', {}).get('runner', 'ubuntu-latest'),
                    'steps': steps
                }
            }
        }
        
        # Add notifications if defined
        notifications = definition.get('notifications', {})
        if 'on-failure' in notifications and 'slack' in notifications['on-failure']:
            slack_config = notifications['on-failure']['slack']
            workflow['jobs']['run-agent']['steps'].append({
                'name': 'Notify on Failure',
                'if': 'failure()',
                'uses': 'slackapi/slack-github-action@v1.25.0',
                'with': {
                    'channel-id': slack_config.get('channel'),
                    'slack-message': slack_config.get('message')
                }
            })

        return yaml.dump(workflow, sort_keys=False, indent=2)

class GitLabCIGenerator(PipelineGenerator):
    """Genereert een GitLab CI pipeline."""
    def translate(self, definition: dict) -> str:
        import yaml

        script = self._steps_to_script(definition.get('steps', []))
        
        job_name = definition.get('name', 'agent-job').lower().replace(' ', '-')
        
        pipeline = {
            job_name: {
                'stage': 'agent',
                'image': f"python:{definition.get('environment', {}).get('python-version', '3.11')}",
                'rules': [{'if': '$CI_PIPELINE_SOURCE == "web"'}],
                'script': script
            }
        }
        
        # Artifacts
        for step in definition.get('steps', []):
            if step.get('action') == 'upload-artifact':
                pipeline[job_name]['artifacts'] = {
                    'name': step.get('with', {}).get('name'),
                    'paths': [step.get('with', {}).get('path')]
                }
        
        # Notifications
        notifications = definition.get('notifications', {})
        if 'on-failure' in notifications and 'slack' in notifications['on-failure']:
            slack_config = notifications['on-failure']['slack']
            pipeline[job_name]['after_script'] = [
                f"if [ $CI_JOB_STATUS == 'failed' ]; then "
                f"apk add --no-cache curl; "
                f"curl -X POST -H 'Content-type: application/json' "
                f"--data '{{\"text\":\"{slack_config.get('message')}\"}}' "
                f"$SLACK_WEBHOOK_URL; "
                f"fi"
            ]

        return yaml.dump(pipeline, sort_keys=False, indent=2)

PLATFORM_GENERATORS = {
    'github-actions': GitHubActionsGenerator,
    'gitlab-ci': GitLabCIGenerator,
}

def generate_pipelines_for_agent(agent_name: str, phase: str, repo_root: Path, platforms: list):
    """Genereert platform-specifieke pipelines voor een agent."""
    import yaml
    definition_path = repo_root / 'agent-componenten' / 'pipelines' / 'definitions' / f"{phase}.{agent_name}.pipeline.yml"
    
    if not definition_path.exists():
        print(f"[\033[93mWARNING\033[0m] Geen pipeline definitie gevonden voor {agent_name} op {definition_path}")
        return

    with open(definition_path, 'r') as f:
        definition = yaml.safe_load(f)

    for platform in platforms:
        if platform not in PLATFORM_GENERATORS:
            print(f"[\033[93mWARNING\033[0m] Geen generator voor platform '{platform}'. Overgeslagen.")
            continue
        
        generator = PLATFORM_GENERATORS[platform]()
        platform_yaml = generator.translate(definition['pipeline'])
        
        ext = 'workflow.yml' if platform == 'github-actions' else 'gitlab-ci.yml'
        output_path = repo_root / 'agent-componenten' / 'pipelines' / 'generated' / platform / f"{phase}.{agent_name}.{ext}"
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(platform_yaml)
        
        print(f"[\033[92mSUCCESS\033[0m] Generated {platform} pipeline for {agent_name}")

def regenerate_all_pipelines(repo_root: Path, platforms: list):
    """Regenereert alle pipelines voor de opgegeven platforms."""
    definitions_dir = repo_root / 'agent-componenten' / 'pipelines' / 'definitions'
    for definition_file in definitions_dir.glob('*.yml'):
        parts = definition_file.stem.split('.')
        phase = parts[0]
        agent_name = parts[1]
        generate_pipelines_for_agent(agent_name, phase, repo_root, platforms)

# -------------------
