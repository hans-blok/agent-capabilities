#!/usr/bin/env python3
"""
run-workflow.py

Orchestreert een workflow van meerdere agents in sequence.
Met 1 commando een founding hypothesis schrijven en een CDM maken.

GEBRUIK:
  python scripts/run-workflow.py --workflow hypothesis-to-cdm --input "Een platform voor online cursussen"
  python scripts/run-workflow.py --workflow hypothesis-to-cdm --input-file concept.txt --output-dir ./output

Workflow: hypothesis-to-cdm
  1. Founding Hypothesis Owner (a1) - schrijft founding hypothesis
  2. CDM Architect (b1) - maakt canonical data model op basis van hypothesis

Agent: workflow-orchestrator (u96)
Versie: 1.0
Datum: 09-01-2026
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime


class WorkflowOrchestrator:
    """Orchestreert workflows van meerdere agents."""
    
    def __init__(self, repo_root: Path = None, output_dir: Path = None):
        """Initialize the workflow orchestrator."""
        self.repo_root = repo_root or Path.cwd()
        self.output_dir = output_dir or (self.repo_root / "output" / "workflows")
        self.runners_dir = self.repo_root / "agent-componenten" / "runners"
    
    def log(self, message: str, prefix: str = "INFO"):
        """Log a message with prefix."""
        colors = {
            "INFO": "\033[96m",      # Cyan
            "SUCCESS": "\033[92m",   # Green
            "WARNING": "\033[93m",   # Yellow
            "ERROR": "\033[91m",     # Red
            "STEP": "\033[95m"       # Magenta
        }
        reset = "\033[0m"
        color = colors.get(prefix, "")
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"{color}[{timestamp}] [{prefix}] {message}{reset}")
    
    def run_agent(self, agent_phase: str, agent_name: str, input_file: Path, 
                  output_file: Path) -> bool:
        """Run a single agent with input and capture output."""
        runner_file = f"{agent_phase}.{agent_name}.py"
        runner_path = self.runners_dir / runner_file
        
        if not runner_path.exists():
            self.log(f"Runner niet gevonden: {runner_path}", "ERROR")
            return False
        
        self.log(f"Uitvoeren: {agent_name}", "STEP")
        self.log(f"  Input:  {input_file.name}", "INFO")
        self.log(f"  Output: {output_file.name}", "INFO")
        
        try:
            # Run agent runner with input file
            result = subprocess.run(
                [sys.executable, str(runner_path), 
                 "--input-files", str(input_file),
                 "--output-file", str(output_file)],
                capture_output=True,
                text=True,
                timeout=300  # 5 minutes timeout
            )
            
            # Always log stdout/stderr for debugging
            if result.stdout:
                print(result.stdout)
            
            if result.returncode != 0:
                self.log(f"Agent gefaald met exit code {result.returncode}", "ERROR")
                if result.stderr:
                    print(result.stderr)
                return False
            
            if not output_file.exists():
                self.log(f"Output bestand niet aangemaakt: {output_file}", "ERROR")
                return False
            
            # Read and log excerpt
            with open(output_file, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.split('\n')
                self.log(f"✓ Output gegenereerd: {len(lines)} regels, {len(content)} tekens", "SUCCESS")
            
            return True
            
        except subprocess.TimeoutExpired:
            self.log(f"Agent timeout na 5 minuten", "ERROR")
            return False
        except Exception as e:
            self.log(f"Fout bij uitvoeren agent: {e}", "ERROR")
            return False
    
    def run_hypothesis_to_cdm(self, initial_input: str) -> bool:
        """
        Workflow: Founding Hypothesis → CDM
        
        1. Founding Hypothesis Owner: concept → founding hypothesis
        2. CDM Architect: founding hypothesis → canonical data model
        """
        workflow_id = f"hypothesis-to-cdm-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        workflow_dir = self.output_dir / workflow_id
        workflow_dir.mkdir(parents=True, exist_ok=True)
        
        self.log("=" * 70, "INFO")
        self.log(f"WORKFLOW: Founding Hypothesis → CDM", "INFO")
        self.log(f"ID: {workflow_id}", "INFO")
        self.log(f"Output: {workflow_dir.relative_to(self.repo_root)}", "INFO")
        self.log("=" * 70, "INFO")
        
        # Create initial input file
        input_file = workflow_dir / "0-initial-concept.txt"
        with open(input_file, 'w', encoding='utf-8') as f:
            f.write(initial_input)
        self.log(f"Initial input opgeslagen: {input_file.name}", "INFO")
        
        # Step 1: Founding Hypothesis Owner
        self.log("", "INFO")
        self.log("STAP 1/2: Founding Hypothesis Owner", "STEP")
        self.log("-" * 70, "INFO")
        hypothesis_file = workflow_dir / "1-founding-hypothesis.md"
        if not self.run_agent("a1", "founding-hypothesis-owner", input_file, hypothesis_file):
            return False
        
        # Step 2: CDM Architect
        self.log("", "INFO")
        self.log("STAP 2/2: CDM Architect", "STEP")
        self.log("-" * 70, "INFO")
        cdm_file = workflow_dir / "2-canonical-data-model.md"
        if not self.run_agent("b1", "cdm-architect", hypothesis_file, cdm_file):
            return False
        
        # Create workflow summary
        summary_file = workflow_dir / "workflow-summary.json"
        summary = {
            "workflow": "hypothesis-to-cdm",
            "workflow_id": workflow_id,
            "timestamp": datetime.now().isoformat(),
            "initial_input_preview": initial_input[:200] + ("..." if len(initial_input) > 200 else ""),
            "steps": [
                {
                    "step": 1,
                    "agent": "founding-hypothesis-owner",
                    "phase": "a1",
                    "input": str(input_file.name),
                    "output": str(hypothesis_file.name),
                    "description": "Schrijft founding hypothesis op basis van initieel concept"
                },
                {
                    "step": 2,
                    "agent": "cdm-architect",
                    "phase": "b1",
                    "input": str(hypothesis_file.name),
                    "output": str(cdm_file.name),
                    "description": "Maakt canonical data model op basis van hypothesis"
                }
            ],
            "artifacts": {
                "0_initial_input": str(input_file.name),
                "1_founding_hypothesis": str(hypothesis_file.name),
                "2_canonical_data_model": str(cdm_file.name),
                "summary": str(summary_file.name)
            }
        }
        
        with open(summary_file, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2, ensure_ascii=False)
        
        self.log("", "INFO")
        self.log("=" * 70, "SUCCESS")
        self.log("WORKFLOW VOLTOOID!", "SUCCESS")
        self.log("=" * 70, "SUCCESS")
        self.log("", "INFO")
        self.log("Gegenereerde artefacten:", "INFO")
        self.log(f"  📝 {hypothesis_file.name}", "INFO")
        self.log(f"  📊 {cdm_file.name}", "INFO")
        self.log(f"  📋 {summary_file.name}", "INFO")
        self.log("", "INFO")
        self.log(f"Volledige output: {workflow_dir}", "INFO")
        
        return True


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Orchestreert workflows van meerdere agents',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Workflows:
  hypothesis-to-cdm    Van concept naar founding hypothesis en CDM
  
Voorbeelden:
  # Met directe input
  python scripts/run-workflow.py --workflow hypothesis-to-cdm --input "Een platform voor online cursussen"
  
  # Met input file
  python scripts/run-workflow.py --workflow hypothesis-to-cdm --input-file concept.txt
  
  # Met custom output directory
  python scripts/run-workflow.py --workflow hypothesis-to-cdm --input "..." --output-dir ./output
"""
    )
    
    parser.add_argument(
        "--workflow",
        required=True,
        choices=["hypothesis-to-cdm"],
        help="De workflow om uit te voeren"
    )
    parser.add_argument(
        "--input",
        help="Directe input voor de workflow"
    )
    parser.add_argument(
        "--input-file",
        type=Path,
        help="Pad naar input bestand"
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        help="Output directory voor workflow artifacts (default: output/workflows/)"
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        help="Root directory van de repository (default: current directory)"
    )
    
    args = parser.parse_args()
    
    # Validate input
    if not args.input and not args.input_file:
        parser.error("--input of --input-file is vereist")
    
    # Read input
    if args.input_file:
        if not args.input_file.exists():
            print(f"[\033[91mERROR\033[0m] Input bestand niet gevonden: {args.input_file}")
            return 1
        with open(args.input_file, 'r', encoding='utf-8') as f:
            initial_input = f.read()
    else:
        initial_input = args.input
    
    # Initialize orchestrator
    orchestrator = WorkflowOrchestrator(
        repo_root=args.repo_root,
        output_dir=args.output_dir
    )
    
    # Run workflow
    if args.workflow == "hypothesis-to-cdm":
        success = orchestrator.run_hypothesis_to_cdm(initial_input)
        return 0 if success else 1
    
    return 1


if __name__ == '__main__':
    sys.exit(main())
