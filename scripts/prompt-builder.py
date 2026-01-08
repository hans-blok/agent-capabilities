#!/usr/bin/env python3
"""
prompt-builder.py

Builder voor agent prompt bestanden op basis van charter.

GEBRUIK:
  python prompt-builder.py --plan-path artefacten/_buildplans/std.a.trigger.founding-hypothesis-owner.json

Versie: 1.0
Datum: 04-01-2026
"""

import argparse
import json
import sys
from pathlib import Path
from datetime import datetime


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


def read_charter(charter_path: Path) -> str:
    """Read the charter content."""
    if not charter_path.exists():
        raise FileNotFoundError(f"Charter niet gevonden: {charter_path}")
    
    with open(charter_path, 'r', encoding='utf-8') as f:
        return f.read()


def generate_prompt(plan: dict, charter_content: str) -> str:
    """Generate minimal prompt with agent reference."""
    agent_id = plan['agentId']
    charter_url = plan.get('charterUrl', plan['charterPath'])  # Use URL if available, fallback to path
    
    prompt = f"""---
agent: {agent_id}
---

We scheiden agents en prompts voor schaalbaarheid.
Charter: {charter_url}
"""
    
    return prompt


def _extract_charter_sections(charter: str) -> dict:
    """Extract key sections from charter markdown."""
    sections = {}
    lines = charter.split('\n')
    current_section = None
    current_content = []
    
    for line in lines:
        # Detect section headers (## heading)
        if line.startswith('## '):
            # Save previous section
            if current_section:
                sections[current_section] = '\n'.join(current_content).strip()
            
            # Start new section
            header = line[3:].strip().lower()
            if 'doel' in header:
                current_section = 'doel'
            elif 'scope' in header:
                current_section = 'scope'
            elif 'input' in header:
                current_section = 'input'
            elif 'output' in header:
                current_section = 'output'
            elif 'werkwijze' in header or 'werking' in header:
                current_section = 'werkwijze'
            elif 'bevoegdheid' in header:
                current_section = 'bevoegdheden'
            else:
                current_section = None
            
            current_content = []
        elif current_section:
            current_content.append(line)
    
    # Save last section
    if current_section:
        sections[current_section] = '\n'.join(current_content).strip()
    
    return sections


def write_prompt(prompt_path: Path, content: str):
    """Write the prompt file."""
    prompt_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(prompt_path, 'w', encoding='utf-8') as f:
        f.write(content)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='Builder voor agent prompt bestanden')
    parser.add_argument('--plan-path', required=True, help='Pad naar build plan JSON')
    
    args = parser.parse_args()
    
    try:
        plan_path = Path(args.plan_path)
        log(f"Laden build plan: {plan_path}")
        
        plan = load_plan(plan_path)
        charter_path = Path(plan['charterPath'])
        
        log(f"Lezen charter: {charter_path}")
        charter_content = read_charter(charter_path)
        
        log("Genereren prompt...")
        prompt_content = generate_prompt(plan, charter_content)
        
        prompt_path = Path(plan['promptPath'])
        log(f"Schrijven prompt: {prompt_path}")
        write_prompt(prompt_path, prompt_content)
        
        log(f"Prompt builder voltooid voor: {plan['agentName']}", "SUCCESS")
        return 0
        
    except Exception as e:
        log(f"Fout in prompt-builder: {e}", "ERROR")
        return 1


if __name__ == '__main__':
    sys.exit(main())
