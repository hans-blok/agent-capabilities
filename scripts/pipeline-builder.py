#!/usr/bin/env python3
"""
pipeline-builder.py

Genereert platform-specifieke CI/CD pipelines voor agents.
Vertaalt platform-agnostische pipeline definities naar GitHub Actions, GitLab CI, etc.

GEBRUIK:
  python scripts/pipeline-builder.py --agent-name "founding-hypothesis-owner" --platforms github-actions,gitlab-ci
  python scripts/pipeline-builder.py --regenerate-all --platforms github-actions,gitlab-ci

Agent: pipeline-builder (u94)
Versie: 1.0
Datum: 09-01-2026
"""

import argparse
import sys
from pathlib import Path
from typing import Dict, List
import yaml


class PipelineGenerator:
    """Base class voor platform-specifieke pipeline generators."""
    
    def translate(self, definition: Dict) -> str:
        """Vertaal platform-agnostische definitie naar platform-specifiek."""
        raise NotImplementedError("Subclasses moeten translate() implementeren")

    def _steps_to_script(self, steps: List[Dict]) -> List[str]:
        """Extract script lines from pipeline steps."""
        script_lines = []
        for step in steps:
            action = step.get('action')
            if action == 'run':
                script_lines.extend(step.get('command', '').strip().split('\n'))
        return script_lines


class GitHubActionsGenerator(PipelineGenerator):
    """Genereert een GitHub Actions workflow."""
    
    def translate(self, definition: Dict) -> str:
        """Generate GitHub Actions YAML."""
        steps = []
        
        for step in definition.get('steps', []):
            action = step.get('action')
            step_id = step.get('id')
            
            if action == 'checkout':
                steps.append({
                    'name': step_id,
                    'uses': 'actions/checkout@v4'
                })
            elif action == 'setup-python':
                steps.append({
                    'name': step_id,
                    'uses': 'actions/setup-python@v5',
                    'with': step.get('with')
                })
            elif action == 'run':
                steps.append({
                    'name': step_id,
                    'run': step.get('command')
                })
            elif action == 'upload-artifact':
                steps.append({
                    'name': step_id,
                    'uses': 'actions/upload-artifact@v4',
                    'with': step.get('with')
                })

        workflow = {
            'name': definition.get('name'),
            'on': {
                'workflow_dispatch': {
                    'inputs': definition.get('trigger', {}).get('inputs', {})
                }
            },
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
    
    def translate(self, definition: Dict) -> str:
        """Generate GitLab CI YAML."""
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


class PipelineBuilder:
    """Bouwt platform-specifieke pipelines voor agents."""
    
    def __init__(self, repo_root: Path = None):
        """Initialize the pipeline builder."""
        self.repo_root = repo_root or Path.cwd()
        self.definitions_dir = self.repo_root / 'agent-componenten' / 'pipelines' / 'definitions'
        self.output_dir = self.repo_root / 'agent-componenten' / 'pipelines' / 'generated'
    
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
        print(f"{color}[{prefix}] {message}{reset}")
    
    def generate_for_agent(self, agent_name: str, phase: str, platforms: List[str]):
        """Genereert platform-specifieke pipelines voor een agent."""
        definition_path = self.definitions_dir / f"{phase}.{agent_name}.pipeline.yml"
        
        if not definition_path.exists():
            self.log(f"Geen pipeline definitie gevonden voor {agent_name} op {definition_path}", "WARNING")
            return False

        with open(definition_path, 'r', encoding='utf-8') as f:
            definition = yaml.safe_load(f)

        success = True
        for platform in platforms:
            if platform not in PLATFORM_GENERATORS:
                self.log(f"Geen generator voor platform '{platform}'. Overgeslagen.", "WARNING")
                continue
            
            try:
                generator = PLATFORM_GENERATORS[platform]()
                platform_yaml = generator.translate(definition['pipeline'])
                
                ext = 'workflow.yml' if platform == 'github-actions' else 'gitlab-ci.yml'
                output_path = self.output_dir / platform / f"{phase}.{agent_name}.{ext}"
                output_path.parent.mkdir(parents=True, exist_ok=True)
                
                with open(output_path, 'w', encoding='utf-8') as f:
                    f.write(platform_yaml)
                
                self.log(f"Generated {platform} pipeline: {output_path.relative_to(self.repo_root)}", "SUCCESS")
            except Exception as e:
                self.log(f"Fout bij genereren {platform} pipeline voor {agent_name}: {e}", "ERROR")
                success = False
        
        return success
    
    def regenerate_all(self, platforms: List[str]):
        """Regenereert alle pipelines voor de opgegeven platforms."""
        if not self.definitions_dir.exists():
            self.log(f"Pipeline definitions directory niet gevonden: {self.definitions_dir}", "ERROR")
            return False
        
        definition_files = list(self.definitions_dir.glob('*.pipeline.yml'))
        
        if not definition_files:
            self.log(f"Geen pipeline definities gevonden in {self.definitions_dir}", "WARNING")
            return True
        
        self.log(f"Gevonden {len(definition_files)} pipeline definitie(s)", "INFO")
        
        success_count = 0
        for definition_file in definition_files:
            # Parse filename: <phase>.<name>.pipeline.yml
            parts = definition_file.stem.split('.')
            if len(parts) < 3:
                self.log(f"Ongeldige bestandsnaam: {definition_file.name}", "WARNING")
                continue
            
            phase = parts[0]
            # Handle names with dots (e.g., d1.service-architect)
            agent_name = '.'.join(parts[1:-1])  # Everything between phase and 'pipeline'
            
            if self.generate_for_agent(agent_name, phase, platforms):
                success_count += 1
        
        self.log(f"Succesvol {success_count}/{len(definition_files)} pipeline(s) gegenereerd", "SUCCESS")
        return success_count == len(definition_files)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Genereert platform-specifieke CI/CD pipelines voor agents',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Voorbeelden:
  # Genereer pipelines voor specifieke agent
  python scripts/pipeline-builder.py --agent-name founding-hypothesis-owner --phase a1 --platforms github-actions,gitlab-ci
  
  # Regenereer alle pipelines
  python scripts/pipeline-builder.py --regenerate-all --platforms github-actions,gitlab-ci
"""
    )
    
    parser.add_argument(
        "--agent-name",
        help="De naam van de agent (zonder fase prefix)"
    )
    parser.add_argument(
        "--phase",
        help="De fase van de agent (bijv. 'a1', 'd2', 'u05')"
    )
    parser.add_argument(
        "--platforms",
        default="github-actions,gitlab-ci",
        help="Comma-separated lijst van pipeline platforms (default: github-actions,gitlab-ci)"
    )
    parser.add_argument(
        "--regenerate-all",
        action="store_true",
        help="Regenereer alle pipelines voor de opgegeven platforms"
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        help="Root directory van de repository (default: current directory)"
    )
    
    args = parser.parse_args()
    
    # Converteer platforms string naar lijst
    platforms_list = [p.strip() for p in args.platforms.split(',')]
    
    # Initialize builder
    builder = PipelineBuilder(repo_root=args.repo_root)
    
    # Regenerate all or single agent
    if args.regenerate_all:
        success = builder.regenerate_all(platforms_list)
        return 0 if success else 1
    
    # Single agent mode
    if not args.agent_name or not args.phase:
        parser.error("--agent-name en --phase zijn vereist, tenzij --regenerate-all wordt gebruikt.")
    
    success = builder.generate_for_agent(args.agent_name, args.phase, platforms_list)
    return 0 if success else 1


if __name__ == '__main__':
    sys.exit(main())
