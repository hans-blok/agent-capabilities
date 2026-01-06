#!/usr/bin/env python3
"""
0.orchestration-builder.py

Builder voor agent orchestration configuratie op basis van charter.

GEBRUIK:
  python 0.orchestration-builder.py --plan-path artefacten/_buildplans/std.a.trigger.founding-hypothesis-owner.json

Versie: 1.0
Datum: 04-01-2026
"""

import argparse
import json
import sys
from pathlib import Path
from datetime import datetime
import yaml


def log(message: str, prefix: str = "INFO"):
    """Log a message with prefix."""
    colors = {
        "INFO": "\033[96m",
        "SUCCESS": "\033[92m",
        "WARNING": "\033[93m",
        "ERROR": "\033[91m"
    }
    reset = "\033[0m"
    color = colors.get(prefix, "")
    print(f"{color}[{prefix}] {message}{reset}")


def load_plan(plan_path: Path) -> dict:
    """Load the build plan JSON."""
    if not plan_path.exists():
        raise FileNotFoundError(f"Build plan niet gevonden: {plan_path}")
    
    with open(plan_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def generate_orchestration(plan: dict) -> dict:
    """Generate orchestration configuration."""
    timestamp = datetime.now().strftime('%Y-%m-%d')
    
    orchestration = {
        'agent': {
            'id': plan['agentId'],
            'name': plan['agentName'],
            'phase': plan['phase'],
            'version': '1.0',
            'generated': timestamp
        },
        'charter': {
            'path': plan['charterPath'],
            'location': f"https://github.com/hans-blok/standard/blob/main/charters.agents/{plan['phase']}/std.agent.charter.{plan['phase']}.{plan['agentName']}.md"
        },
        'artifacts': {
            'prompt': plan['promptPath'],
            'runner': plan['runnerPath'],
            'outputRoot': plan['outputRoot']
        },
        'runtime': plan['runtime'],
        'qualityGates': plan['qualityGates'],
        'workflow': {
            'steps': [
                {
                    'id': 1,
                    'name': 'Valideer Input',
                    'description': 'Controleer dat alle vereiste input bestanden aanwezig zijn'
                },
                {
                    'id': 2,
                    'name': 'Lees Charter',
                    'description': 'Laad charter en prompt definitie'
                },
                {
                    'id': 3,
                    'name': 'Voer Agent Uit',
                    'description': 'Roep LLM aan met prompt en input'
                },
                {
                    'id': 4,
                    'name': 'Genereer Output',
                    'description': 'Schrijf output naar bestand in outputRoot'
                },
                {
                    'id': 5,
                    'name': 'Valideer Kwaliteit',
                    'description': 'Controleer output tegen quality gates'
                }
            ]
        },
        'metadata': {
            'created': timestamp,
            'buildPlan': plan['buildPlanPath']
        }
    }
    
    return orchestration


def write_orchestration(orch_path: Path, content: dict):
    """Write the orchestration YAML file."""
    orch_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(orch_path, 'w', encoding='utf-8') as f:
        yaml.dump(content, f, default_flow_style=False, allow_unicode=True, sort_keys=False)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='Builder voor agent orchestration configuratie')
    parser.add_argument('--plan-path', required=True, help='Pad naar build plan JSON')
    
    args = parser.parse_args()
    
    try:
        plan_path = Path(args.plan_path)
        log(f"Laden build plan: {plan_path}")
        
        plan = load_plan(plan_path)
        
        log("Genereren orchestration configuratie...")
        orch_config = generate_orchestration(plan)
        
        orch_path = Path(plan['orchestrationPath'])
        log(f"Schrijven orchestration: {orch_path}")
        write_orchestration(orch_path, orch_config)
        
        log(f"Orchestration builder voltooid voor: {plan['agentName']}", "SUCCESS")
        return 0
        
    except Exception as e:
        log(f"Fout in orchestration-builder: {e}", "ERROR")
        return 1


if __name__ == '__main__':
    sys.exit(main())
