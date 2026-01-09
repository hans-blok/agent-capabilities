#!/usr/bin/env python3
"""
runner-builder.py

Builder voor agent runner scripts op basis van charter.

GEBRUIK:
  python runner-builder.py --plan-path artefacten/_buildplans/std.a.trigger.founding-hypothesis-owner.json

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


def generate_runner(plan: dict) -> str:
    """Generate runner script content."""
    agent_name = plan['agentName']
    phase = plan['phase']
    timestamp = datetime.now().strftime('%Y-%m-%d')
    
    runner = f'''#!/usr/bin/env python3
"""
{agent_name}.py

Runner script voor {agent_name} agent.

Agent: {plan['agentId']}
Fase: {phase}
Charter: {plan['charterPath']}
Gegenereerd: {timestamp}
"""

import argparse
import json
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional


class {agent_name.replace('-', '_').title().replace('_', '')}Agent:
    """Agent implementation for {agent_name}."""
    
    def __init__(self, args):
        """Initialize the agent."""
        self.args = args
        self.output_root = Path("{plan['outputRoot']}")
        self.charter_path = Path("{plan['charterPath']}")
    
    def log(self, message: str, msg_type: str = "INFO"):
        """Log a message."""
        colors = {{
            "INFO": "\\033[96m",
            "SUCCESS": "\\033[92m",
            "WARNING": "\\033[93m",
            "ERROR": "\\033[91m"
        }}
        reset = "\\033[0m"
        color = colors.get(msg_type, "")
        print(f"{{color}}[{{msg_type}}] {{message}}{{reset}}")
    
    def validate_inputs(self):
        """Validate input files."""
        valid_files = []
        for file_path in self.args.input_files:
            path = Path(file_path)
            if path.exists():
                valid_files.append(str(path.resolve()))
                self.log(f"Input bestand toegevoegd: {{file_path}}")
            else:
                self.log(f"Bestand niet gevonden: {{file_path}}", "WARNING")
        
        if not valid_files:
            raise ValueError("Geen geldige input bestanden gevonden")
        
        self.args.input_files = valid_files
    
    def run(self) -> Dict:
        """Execute the agent logic."""
        try:
            self.log(f"Starten {{agent_name}} agent...")
            
            # Validate inputs
            self.validate_inputs()
            
            # PLACEHOLDER: Hier zou de daadwerkelijke agent logic komen
            # Dit zou typisch een LLM call zijn met de prompt uit {plan['promptPath']}
            
            self.log("LET OP: Dit is een placeholder runner", "WARNING")
            self.log("De daadwerkelijke agent-logica zou hier via LLM gebeuren", "WARNING")
            
            # Generate output
            output_file = self.output_root / f"{{agent_name}}-{{datetime.now().strftime('%Y%m%d-%H%M%S')}}.md"
            output_file.parent.mkdir(parents=True, exist_ok=True)
            
            output_content = f"""# {{agent_name}} Output

**Gegenereerd**: {{datetime.now().isoformat()}}
**Input bestanden**: {{', '.join(self.args.input_files)}}

## PLACEHOLDER

Dit is placeholder output. De daadwerkelijke output zou gegenereerd worden
door de LLM op basis van:
- Charter: {{self.charter_path}}
- Prompt: {plan['promptPath']}
- Input bestanden
"""
            
            output_file.write_text(output_content, encoding='utf-8')
            self.log(f"Output geschreven naar: {{output_file}}", "SUCCESS")
            
            return {{
                'status': 'Success',
                'output_file': str(output_file),
                'timestamp': datetime.now().isoformat()
            }}
            
        except Exception as e:
            self.log(f"Fout tijdens agent uitvoering: {{e}}", "ERROR")
            raise


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Runner voor {agent_name} agent',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('-i', '--input-files', required=True, nargs='+',
                       help='Input bestanden voor de agent')
    
    parser.add_argument('-o', '--output-file', 
                       help='Output bestand pad (optioneel)')
    
    parser.add_argument('-v', '--verbose', action='store_true',
                       help='Uitgebreide output')
    
    args = parser.parse_args()
    
    agent = {agent_name.replace('-', '_').title().replace('_', '')}Agent(args)
    result = agent.run()
    
    return 0 if result['status'] == 'Success' else 1


if __name__ == '__main__':
    sys.exit(main())
'''
    
    return runner


def write_runner(runner_path: Path, content: str):
    """Write the runner script."""
    runner_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(runner_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    # Make executable on Unix
    try:
        runner_path.chmod(0o755)
    except:
        pass


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='Builder voor agent runner scripts')
    parser.add_argument('--plan-path', required=True, help='Pad naar build plan JSON')
    
    args = parser.parse_args()
    
    try:
        plan_path = Path(args.plan_path)
        log(f"Laden build plan: {plan_path}")
        
        plan = load_plan(plan_path)
        
        log("Genereren runner script...")
        runner_content = generate_runner(plan)
        
        runner_path = Path(plan['runnerPath'])
        log(f"Schrijven runner: {runner_path}")
        write_runner(runner_path, runner_content)
        
        log(f"Runner builder voltooid voor: {plan['agentName']}", "SUCCESS")
        return 0
        
    except Exception as e:
        log(f"Fout in runner-builder: {e}", "ERROR")
        return 1


if __name__ == '__main__':
    sys.exit(main())
