# Agent Ecosysteem - C4 Component Diagram

# Agent-Capabilities Ecosysteem

## Overzicht
Dit ecosysteem bouwt, beheert en distribueert agents volgens SAFe Development Value Stream principes.

## Kerncomponenten

### 1. Charters (standard repository)
- **Locatie**: c:\gitrepo\standard\artefacten\3-charters-agents\
- **Functie**: Single source of truth voor agent definities
- **Naamgeving**: std.agent.charter.<fase>.<naam>.md
- **Fases**: a (Trigger), b (Architectuur), c (Specificatie), d (Ontwerp), e (Bouw), f (Validatie), g (Deploy), u (Utility)

### 2. Agent-Capabilities (deze workspace)
- **Locatie**: c:\gitrepo\agent-capabilities\
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
- **Voorbeelden**: c:\gitrepo\mak-ea\
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



## Component Diagram

```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Component.puml

' TODO: Genereer met C4-modelleur LLM aanroep
' Dit is een placeholder

@enduml
```

---
*Gegenereerd door: visualize-ecosystem.py*
*Datum: 1767946948.4705524*
