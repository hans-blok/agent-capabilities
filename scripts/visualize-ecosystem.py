#!/usr/bin/env python3
"""
visualize-ecosystem.py

Gebruikt de C4-modelleur om het agent-ecosysteem te visualiseren.
Genereert C4 diagrammen op Context, Container en Component niveau.

GEBRUIK:
  python scripts/visualize-ecosystem.py
  python scripts/visualize-ecosystem.py --level context
  python scripts/visualize-ecosystem.py --level all

Agent: visualize-ecosystem.py
Versie: 1.0
Datum: 09-01-2026
"""

import argparse
import sys
from pathlib import Path

def log(message: str, prefix: str = "INFO"):
    """Log een bericht."""
    colors = {
        "INFO": "\033[96m",
        "SUCCESS": "\033[92m",
        "WARNING": "\033[93m",
        "ERROR": "\033[91m"
    }
    reset = "\033[0m"
    color = colors.get(prefix, "")
    print(f"{color}[{prefix}] {message}{reset}")

def get_ecosystem_context() -> str:
    """Bouw de context beschrijving van het agent-ecosysteem."""
    return """# Agent-Capabilities Ecosysteem

## Overzicht
Dit ecosysteem bouwt, beheert en distribueert agents volgens SAFe Development Value Stream principes.

## Kerncomponenten

### 1. Charters (standard repository)
- **Locatie**: c:\\gitrepo\\standard\\artefacten\\3-charters-agents\\
- **Functie**: Single source of truth voor agent definities
- **Naamgeving**: std.agent.charter.<fase>.<naam>.md
- **Fases**: a (Trigger), b (Architectuur), c (Specificatie), d (Ontwerp), e (Bouw), f (Validatie), g (Deploy), u (Utility)

### 2. Agent-Capabilities (deze workspace)
- **Locatie**: c:\\gitrepo\\agent-capabilities\\
- **Functie**: Agent component generator en distributie hub

#### 2.1 Scripts
- **make-agent.py**: Genereert componenten vanuit charter (met auto git pull)
- **fetch-agents.py**: Distribueert agents naar project workspaces
- **visualize-ecosystem.py**: Genereert C4 diagrammen van ecosysteem

#### 2.2 Agent Componenten
**Prompts** (agent-componenten/prompts/):
- Minimale instructie files
- Refereren naar charter
- Format: <fase>.<naam>.prompt.md

**Runners** (agent-componenten/runners/):
- Python executables
- CLI interface
- Format: <fase>.<naam>.py

**Orchestrations** (agent-componenten/orchestrations/):
- YAML configuraties
- Workflow definities
- Format: <fase>.<naam>.orchestration.yaml

**Buildplans** (agent-componenten/buildplans/):
- JSON metadata
- Traceerbaarheid (charter path, URLs)
- Format: <fase>.<naam>.json

**Pipelines** (agent-componenten/pipelines/):
- definitions/: Platform-agnostisch (source of truth)
- generated/: Platform-specifiek (disposable)
  - github-actions/
  - gitlab-ci/
  - azure-pipelines/

**Agents** (agent-componenten/agents/):
- Agent definitie documenten
- Samenvatting van charter
- Format: <fase>.<naam>.agent.md

### 3. Project Workspaces
- **Voorbeelden**: c:\\gitrepo\\mak-ea\\
- **Functie**: Executie omgeving voor agents
- **Structuur**:
  - .github/prompts/: Gesyncte prompts
  - .github/workflows/: Platform-specifieke pipelines
  - agent-componenten/: Gesyncte componenten
  - artefacten/: Output van agents

## Workflows

### Agent Lifecycle
1. **Charter schrijven** in standard repository
2. **make-agent.py uitvoeren** in agent-capabilities
   - Leest charter (auto git pull)
   - Extraheert fase uit bestandsnaam
   - Valideert fase tegen charter inhoud
   - Genereert componenten met fase prefix
3. **Componenten committen** naar agent-capabilities
4. **fetch-agents.py uitvoeren** in project workspace
   - Kloont agent-capabilities
   - Kopieert alle componenten
   - Kopieert platform-specifieke pipelines
   - Kopieert workflow pipelines
5. **Agent gebruiken** in project

### Pipeline Generation
1. **Platform-agnostische definitie** schrijven in definitions/
2. **make-agent.py --regenerate-all-pipelines** uitvoeren
3. **Generator translates** naar platform-specifieke templates
4. **Generated pipelines** worden gedistribueerd via fetch-agents.py

## SAFe DVS Fases

**a (Trigger)**:
- a1: founding-hypothesis-owner
- a2: business-case-analyst

**b (Architectuur)**:
- b1: cdm-architect

**c (Specificatie)**:
- c2: logisch-data-modelleur
- c3: schema-custodian

**d (Ontwerp)**:
- d1: service-architect
- d2: technisch-data-modelleur

**e (Bouw)**:
- e1: ddl-dba

**u (Utility)**:
- u01: workspace-moeder
- u03: c4-modelleur
- u04: md-to-archi-xml
- u90: make-agent
- u91: prompt-builder
- u92: runner-builder
- u93: orchestration-builder
- u94: pipeline-bouwer

## Governance Principes

1. **Charter-first**: Charters zijn single source of truth
2. **Git pull mandatory**: Altijd pull voor charter access
3. **Idempotency**: Veilig regenereren van componenten
4. **Explicit over implicit**: Alles traceerbaar
5. **Flat file structure**: Fase-prefixen voor schaalbaarheid
6. **Platform-agnostic**: Definitie layer gescheiden van implementatie
7. **Separation of concerns**: standard/ (def), agent-capabilities/ (gen), workspaces/ (exec)

## Leren in het Ecosysteem

**Evolutionair leren principes**:
- Experience Packages: succesvolle toepassingen als ervaringspakketten
- Selectie boven training: evalueer composities, elimineer slechte, promoot goede
- Meta-agents: herkennen eerdere cases, stellen composities voor
- Institutionalisering: verankeren in artefacten en governance

"""

def generate_c4_diagrams(level: str = "all"):
    """Genereer C4 diagrammen van het ecosysteem."""
    repo_root = Path.cwd()
    output_dir = repo_root / "architectuur-agent-ecosysteem" / "c4-diagrams"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # C4 modelleur runner
    runner_path = repo_root / "agent-componenten" / "runners" / "u03.c4-modelleur.py"
    
    if not runner_path.exists():
        log(f"C4-modelleur runner niet gevonden: {runner_path}", "ERROR")
        log("Voer eerst uit: python scripts/make-agent.py --agent-name c4-modelleur", "INFO")
        return False
    
    context = get_ecosystem_context()
    
    levels = []
    if level == "all":
        levels = ["context", "container", "component"]
    else:
        levels = [level]
    
    log(f"Genereren C4 diagrammen: {', '.join(levels)}")
    
    for c4_level in levels:
        output_file = output_dir / f"agent-ecosystem-{c4_level}.md"
        
        log(f"Genereren {c4_level} diagram...")
        
        # Roep C4-modelleur aan
        # TODO: Implementeer LLM aanroep met prompt + context
        # Voor nu: placeholder
        
        placeholder_content = f"""# Agent Ecosysteem - C4 {c4_level.title()} Diagram

{context}

## {c4_level.title()} Diagram

```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_{c4_level.title()}.puml

' TODO: Genereer met C4-modelleur LLM aanroep
' Dit is een placeholder

@enduml
```

---
*Gegenereerd door: visualize-ecosystem.py*
*Datum: {Path(__file__).stat().st_mtime}*
"""
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(placeholder_content)
        
        log(f"Geschreven: {output_file.relative_to(repo_root)}", "SUCCESS")
    
    log(f"C4 diagrammen gegenereerd in: {output_dir.relative_to(repo_root)}", "SUCCESS")
    log("", "INFO")
    log("VOLGENDE STAPPEN:", "INFO")
    log("1. Implementeer LLM integratie in dit script", "INFO")
    log("2. Of roep handmatig de C4-modelleur aan met deze context", "INFO")
    log("3. Gebruik de gegenereerde PlantUML code in ArchiMate tools", "INFO")
    
    return True

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Visualiseer het agent-ecosysteem met C4 diagrammen',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        '--level',
        choices=['context', 'container', 'component', 'all'],
        default='all',
        help='Welk C4 niveau te genereren (default: all)'
    )
    
    args = parser.parse_args()
    
    log("Starten ecosysteem visualisatie...")
    
    success = generate_c4_diagrams(args.level)
    
    return 0 if success else 1

if __name__ == '__main__':
    sys.exit(main())
