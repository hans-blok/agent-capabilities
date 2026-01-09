#!/usr/bin/env python3
"""
run-layout-optimizer.py

Script om de Layout Optimizer agent te starten.
Dit script roept de u05.layout-optimizer runner aan met de juiste parameters.

Gebruik:
  python scripts/run-layout-optimizer.py --input graph-spec.yaml --direction LR --format mermaid
  python scripts/run-layout-optimizer.py --input workspace.dsl --format structurizr
  python scripts/run-layout-optimizer.py --input diagram.puml --format plantuml --minimize-crossings
"""

import argparse
import sys
from pathlib import Path
import subprocess


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Start de Layout Optimizer agent voor diagram layout optimalisatie',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Voorbeelden:
  # Optimaliseer een Graph Spec (YAML)
  python scripts/run-layout-optimizer.py --input graph-spec.yaml --direction LR --format mermaid
  
  # Optimaliseer een Structurizr DSL
  python scripts/run-layout-optimizer.py --input workspace.dsl --format structurizr
  
  # Optimaliseer een PlantUML diagram
  python scripts/run-layout-optimizer.py --input diagram.puml --format plantuml
  
  # Optimaliseer met specifieke doelen
  python scripts/run-layout-optimizer.py --input graph.yaml --minimize-crossings --avoid-back-edges

Output:
  - Geoptimaliseerde Graph Spec: <input>-optimized.yaml
  - Renderbaar diagram: <input>-optimized.<format>
  - Layout report: layout-report.md
"""
    )
    
    parser.add_argument(
        '--input',
        required=True,
        help='Input bestand (Graph Spec YAML, Mermaid, PlantUML, DOT, of Structurizr DSL)'
    )
    
    parser.add_argument(
        '--format',
        choices=['mermaid', 'plantuml', 'dot', 'structurizr', 'graphspec'],
        default='graphspec',
        help='Output formaat (default: graphspec)'
    )
    
    parser.add_argument(
        '--direction',
        choices=['TB', 'LR'],
        help='Layout richting: TB (Top-to-Bottom) of LR (Left-to-Right)'
    )
    
    parser.add_argument(
        '--minimize-crossings',
        action='store_true',
        help='Prioriteit op minimaliseren van kruisende lijnen'
    )
    
    parser.add_argument(
        '--avoid-back-edges',
        action='store_true',
        help='Vermijd terugpijlen in directed graphs'
    )
    
    parser.add_argument(
        '--max-iterations',
        type=int,
        default=5,
        help='Maximaal aantal optimalisatie iteraties (default: 5)'
    )
    
    parser.add_argument(
        '--output-dir',
        default='artefacten/diagrams',
        help='Output directory voor gegenereerde bestanden (default: artefacten/diagrams)'
    )
    
    parser.add_argument(
        '--verbose',
        action='store_true',
        help='Verbose logging'
    )
    
    args = parser.parse_args()
    
    # Validate input file
    input_path = Path(args.input)
    if not input_path.exists():
        print(f"[ERROR] Input bestand niet gevonden: {args.input}")
        return 1
    
    # Prepare runner command
    repo_root = Path(__file__).parent.parent
    runner_path = repo_root / "agent-componenten" / "runners" / "u05.layout-optimizer.py"
    
    if not runner_path.exists():
        print(f"[ERROR] Layout Optimizer runner niet gevonden: {runner_path}")
        return 1
    
    # Build command
    cmd = [
        sys.executable,
        str(runner_path),
        '--input-files', str(input_path.resolve())
    ]
    
    # Add optional parameters as JSON metadata
    metadata = {
        'format': args.format,
        'max_iterations': args.max_iterations,
        'output_dir': args.output_dir,
        'constraints': {
            'minimize_crossings': args.minimize_crossings,
            'avoid_back_edges': args.avoid_back_edges
        }
    }
    
    if args.direction:
        metadata['direction'] = args.direction
    
    if args.verbose:
        metadata['verbose'] = True
    
    # Pass metadata as JSON string
    import json
    cmd.extend(['--metadata', json.dumps(metadata)])
    
    # Execute runner
    print(f"[INFO] Starten Layout Optimizer...")
    print(f"[INFO] Input: {input_path.name}")
    print(f"[INFO] Output formaat: {args.format}")
    if args.direction:
        print(f"[INFO] Richting: {args.direction}")
    
    try:
        result = subprocess.run(cmd, check=True)
        print(f"\n[SUCCESS] Layout optimalisatie voltooid")
        print(f"[INFO] Check {args.output_dir}/ voor output bestanden")
        return result.returncode
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] Layout optimalisatie gefaald: {e}")
        return e.returncode
    except Exception as e:
        print(f"[ERROR] Onverwachte fout: {e}")
        return 1


if __name__ == '__main__':
    sys.exit(main())
