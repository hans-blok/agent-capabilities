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
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
import subprocess


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
        print(f"{color}[{prefix}] {message}{reset}")
    
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
            charters_path = Path(self.local_charter_clone) / "charters.agents"
            # Update local clone
            self._update_git_repo(Path(self.local_charter_clone))
        # Check if charter_root is a GitHub URL
        elif self.charter_root.startswith("https://github.com"):
            # Expect local clone in parent directory
            repo_name = self.charter_root.rstrip('.git').split('/')[-1]
            potential_path = self.repo_root.parent / repo_name / "charters.agents"
            
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
        # Find charters.agents in the path and get the next directory (the phase folder)
        parts = charter_path.parts
        try:
            charters_idx = parts.index("charters.agents")
            if charters_idx + 1 < len(parts):
                # Get the directory after charters.agents (e.g., "a.trigger")
                phase_dir = parts[charters_idx + 1]
                # Handle case where charter file is directly in charters.agents (no phase folder)
                if phase_dir.endswith('.md'):
                    # Try to extract from filename pattern: std.agent.charter.<phase>.<name>.md
                    filename = charter_path.stem  # Without .md
                    parts_name = filename.split('.')
                    if len(parts_name) >= 5 and parts_name[2] == 'charter':
                        # Format: std.agent.charter.<phase>.<name>
                        return parts_name[3]  # The phase part
                    raise ValueError(f"Kan phase niet bepalen uit charter naam: {charter_path.name}")
                return phase_dir
            else:
                raise ValueError(f"Kan phase niet bepalen uit charter pad: {charter_path}")
        except (ValueError, IndexError) as e:
            raise ValueError(f"Kan phase niet bepalen uit charter pad: {charter_path}") from e
    
    def create_build_plan(self) -> Dict:
        """Create a build plan for the agent."""
        charter_path = self.resolve_charter_path()
        phase = self.get_phase_from_charter_path(charter_path)
        agent_id = f"std.{phase}.{self.agent_name}"
        
        # Extract phase prefix (e.g., "d.ontwerp" -> "d")
        phase_prefix = phase.split('.')[0] if '.' in phase else phase[0]
        
        plan = {
            "agentName": self.agent_name,
            "phase": phase,
            "agentId": agent_id,
            "repoRoot": str(self.repo_root.resolve()),
            "charterRoot": self.charter_root,
            "charterPath": str(charter_path),
            "promptPath": str(self.repo_root / "agent-componenten" / "prompts" / f"{phase_prefix}.{self.agent_name}.prompt.md"),
            "runnerPath": str(self.repo_root / "agent-componenten" / "runners" / f"{phase_prefix}.{self.agent_name}.py"),
            "orchestrationPath": str(self.repo_root / "agent-componenten" / "orchestrations" / f"{phase}.{self.agent_name}.orchestration.yaml"),
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
            
            # Test completion
            self.test_agent_completion(self.plan)
            
            # Success message
            self.log(f"Agent build klaar: {self.plan['agentId']}", "SUCCESS")
            print(f" - Prompt:        {self.plan['promptPath']}")
            print(f" - Runner:        {self.plan['runnerPath']}")
            print(f" - Orchestration: {self.plan['orchestrationPath']}")
            print(f" - Build plan:    {self.plan['buildPlanPath']}")
            
            return 0
            
        except Exception as e:
            self.log(f"Fout tijdens agent build: {e}", "ERROR")
            raise


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Maakt (of ververst) agent artefacten op basis van een bestaand charter',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('--agent-name', required=True,
                       help='Naam van de agent (bijv. "founding-hypothesis-owner")')
    
    parser.add_argument('--repo-root', default=None,
                       help='Root directory van de repository (default: current directory)')
    
    parser.add_argument('--charter-root', default='https://github.com/hans-blok/standard.git',
                       help='Charter repository URL of lokaal pad (default: https://github.com/hans-blok/standard.git)')
    
    parser.add_argument('--local-charter-clone', default=None,
                       help='Pad naar lokale clone van charter repository (default: zoekt in parent directory)')
    
    args = parser.parse_args()
    
    maker = AgentMaker(
        agent_name=args.agent_name,
        repo_root=args.repo_root,
        charter_root=args.charter_root,
        local_charter_clone=args.local_charter_clone
    )
    
    return maker.run()


if __name__ == '__main__':
    sys.exit(main())
