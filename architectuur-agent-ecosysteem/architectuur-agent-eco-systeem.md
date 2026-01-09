# Architectuur: Agent Ecosysteem

## 1. Inleiding

Dit document beschrijft de **software-architectuur van het Agent Ecosysteem** — het systeem dat we bouwen om software te specificeren, ontwerpen, bouwen en valideren met AI-agents.

**Belangrijke scheiding**:
1. **Dit document** beschrijft WAT we bouwen (de architectuur van het ecosysteem zelf).
2. Het `stappenplan-opbouw-ecosysteem.md` beschrijft HOE we het bouwen.

Deze architectuur beschrijft de **statische structuur** van het ecosysteem: systemen, containers, componenten en hun onderlinge relaties.

---

## 2. System Context

Het Agent Ecosysteem heeft interacties met externe systemen:

### Externe Actors

**Gebruiker**: Geeft natuurlijke taal opdrachten aan het ecosysteem via de VS Code chat (bijv. met `/find`, `/generate`). Verwacht werkende artefacten (specificaties, ontwerpen, code, tests).

**LLM Provider**: Levert AI inference capabilities (Gemini, GPT-4, etc.). Het ecosysteem is model-agnostisch.

**GitHub**: 
- **`standards` Repository**: Bevat de centrale governance, charters en agent-definities.
- **Project Repository**: Bevat de per project gegenereerde artefacten.

---

## 3. Container Diagram

Het Agent Ecosysteem bestaat uit **2 primaire containers** (logische groeperingen):

1. **`standards` Repository** - Centrale governance, charters, en agent-definities.
2. **Project Workspace** - Gegenereerde artefacten per project.

### Container: `standards` Repository

**Type**: Git Repository  
**Locatie**: `github.com/org/standards/`

**Verantwoordelijkheid**: Bevat alle governance, kwaliteitsregels, agent-definities en charters voor het gehele ecosysteem. Dit is de "single source of truth".

**Structuur**:
```
standards/
├── .github/
│   ├── agents/
│   │   ├── std.moeder-standaard.agent.md
│   │   └── ...
│   └── prompts/
│       ├── std.moeder-standaard.prompt.md
│       └── ...
├── governance/
│   ├── constitutie.md
│   ├── gedragscode.md
│   └── beleid.md
├── charters.agents/
│   ├── std.agent.charter.c.feature-analist.md
│   └── ...
├── charters.fases/
│   ├── std.fase.charter.c.specificatie.md
│   └── ...
└── templates/
    ├── agent.charter.template.md
    └── fase.charter.template.md
```

**Kenmerken**:
- **Centraal Beheerd**: Alle agents en regels worden hier gedefinieerd.
- **Read-only voor Projecten**: Project-workspaces lezen hieruit, maar schrijven hier niet naar.
- **Bindend**: De inhoud is bindend voor alle agents in alle projecten.
- **Hiërarchie**: Constitutie > Gedragscode > Beleid > Fase Charters > Agent Charters.
- **Agent-definities**: De `.github/` map bevat de uitvoerbare prompts die agents activeren.


---

## 5. Component Diagram: Agent-Capabilities

**Type**: Git Repository  
**Locatie**: `github.com/org/project-name/`

**Verantwoordelijkheid**: Bevat alle gegenereerde artefacten voor een specifiek project.

**Structuur**:
```
project-name/
├── specs/
│   ├── features/
│   ├── user-stories/
│   └── datamodel.md
├── designs/
│   ├── adr/
│   ├── api-contracts/
│   └── solution-design.md
├── src/
│   └── (gegenereerde code)
├── tests/
│   └── (test cases)
└── docs/
    └── (technische documentatie)
```

**Kenmerken**:
- Per project een aparte repository
- Agents schrijven EN lezen uit workspace (artefact-flow tussen fases)
- Versioned (Git) voor traceerbaarheid
- Input voor volgende fase = output van vorige fase

---

## 4. Component Diagram: GitHub Standards

De GitHub Standards container bevat 6 componenten:

1. **Constitutie** - Universele principes
2. **Beleid** - Repository-specifieke regels
3. **Agent Charters** - Operationele bevoegdheden per agent
4. **Fase Charters** - Kwaliteitseisen per SAFe-fase
5. **Delivery Framework** - SAFe Development Value Stream (A-G+U fases)
6. **Templates** - Charter templates

**Governance Hierarchie**:
1. **Constitutie** — Absoluut, universeel, bindend
2. **Beleid** — Context-specifiek (bijv. Nederlands B1)
3. **Delivery Framework** — SAFe proces-definitie (A-G+U fases)
4. **Fase Charters** — Kwaliteitseisen per fase
5. **Agent Charters** — Operationele bevoegdheden

**Delivery Framework** (component binnen Standards):
- **Type**: Markdown bestand (`governance/delivery-framework.md`)
- **Verantwoordelijkheid**: Definieert SAFe Development Value Stream fases
- **Fases**: A (Trigger), B (Architectuur), C (Specificatie), D (Ontwerp), E (Bouw), F (Validatie), G (Deployment), U (Utility)
- **Kenmerken**: 
  - Fase-definities met doel en verantwoordelijkheden
  - Entry/exit criteria per fase
  - Lineaire flow (A→B→C→D→E→F→G) met feedback loops
  - Utility (U) staat los van lineaire flow
  - Basis voor fase-charters

---

## 5. Component Diagram: GitHub Agent-Capabilities

De GitHub Agent-Capabilities workspace bevat agents georganiseerd per SAFe-fase:

**Meta-agents (Ecosysteem-bouwers, U90-99)**:
- **Moeder Agent Capabilities (u00)** - Agent factory, charter designer, orchestrator voor deze workspace
- **Agent Charter Schrijver (u90)** - Schrijft normatieve agent-charters conform agent-charter-normering.md
- **make-agent.py (u90)** - Genereert agent-componenten (prompts, runners, orchestrations) vanuit charters
- **prompt-builder.py (u91)** - Genereert minimale prompts met charter-referentie
- **runner-builder.py (u92)** - Genereert Python runner scripts
- **orchestration-builder.py (u93)** - Genereert orchestration YAML configuraties
- **pipeline-bouwer (u94)** - Genereert CI/CD pipeline templates

**Moeder Workspace (u01)**:
- **Moeder Workspace** - Waarborgt workspace-architectuur compliance, Git/VS Code configuratie

**Fase Agents** (A-G):
- Exact 1 fase per agent-groep
- Single Responsibility per agent
- Lezen charter voor uitvoering
- Schrijven artefacten naar Project Workspace
- Voorbeelden: founding-hypothesis-owner (a1), cdm-architect (b1), logisch-data-modelleur (c2), service-architect (d1)

**Utility Agents** (U01-89):
- Geen fase-binding
- Cross-cutting concerns
- Voorbeelden: C4-modelleur (u03), Layout Optimizer (u05), MD-to-Archimate-XML (u04)

**Architectuur Principe**: 
- **Charter Writer leeft ALLEEN in agent-capabilities**: Dit is een workspace-specifieke meta-agent
- **Alle andere charters leven in standard repository**: Single source of truth principe
- **Separation of concerns**: standard/ (definities), agent-capabilities/ (generator), project-workspaces/ (executie)

---

## 6. Data Flow: Feature Specificatie (Voorbeeld)
sequenceDiagram
    participant User
    participant Moeder as Moeder Agent
    participant Standards
    participant FaseC as Fase C Agent (Feature-Analist)
    participant Workspace as Project Workspace
    
    User->>Moeder: "Specificeer feature: Gebruikersbeheer"
    Moeder->>Standards: Lees agent charter (feature-analist)
    Moeder->>FaseC: Activeer Feature-Analist
    
    FaseC->>Standards: Lees fase charter (Specificatie)
    FaseC->>Workspace: Lees datamodel (uit Fase B)
    FaseC->>FaseC: Analyseer, stel vragen, schrijf user stories (INVEST, BDD)
    FaseC->>Workspace: Schrijf feature-spec.md
    FaseC->>Workspace: Schrijf user-stories/*.md
    
    FaseC->>User: Levert artefacten + validatie (13 quality gates)
```

**Artefact Flow**:
- Fase B (Architectuur) levert: Datamodel, ADR's
- Fase C (Specificatie) leest datamodel, schrijft features en user stories
- Fase D (Ontwerp) leest features, schrijft solution design

---

## 7. Deployment View

Het Agent Ecosysteem draait in een gedistribueerde omgeving:

**GitHub Platform**:
- `standards/` repository (GitHub Standards container)
- `project-name/` repository (Project Workspace container)

**Lokale Machine** (Developer Workstation):
- VS Code met GitHub Copilot Extension
- Lokale Git clone van standards repository
- Lokale Git clone van project repository

**Cloud** (AI Provider):
- Claude/GPT-4 LLM API

**Interacties**:

## 7. Deployment View

Het Agent Ecosysteem draait in een gedistribueerde omgeving:

**GitHub Platform**:
- `standards/` repository (GitHub Standards container)
- `project-name/` repository (Project Workspace container)

**Lokale Machine** (Developer Workstation):
- VS Code met GitHub Copilot Extension
- Lokale Git clone van standards repository
- Lokale Git clone van project repository

**Cloud** (AI Provider):
- Claude/GPT-4 LLM API

**Interacties**:
- VS Code leest charters via Git clone/pull
- VS Code schrijft artefacten via Git commit/push
- VS Code gebruikt LLM API voor agent inferentie

**Runtime Environment**: VS Code met GitHub Copilot (of equivalent)  
**Standards**: Git-gebaseerd, lokaal gecached  
**Workspace**: Git-gebaseerd, per project  
**LLM**: Cloud API (model-agnostisch)

---

## 8. Architectuurprincipes

### 8.1 Separation of Concerns

**Regels** (Standards) ≠ **Proces** (Framework) ≠ **Data** (Workspace)

- Standards: Wat mag en wat niet
- Framework: Wanneer gebeurt wat
- Workspace: Waarmee wordt gewerkt

Geen mixing van verantwoordelijkheden.

### 8.2 Charter-First

Geen agent zonder volledig charter. Charter definieert:
- Doel, scope, grenzen
- Inputs, outputs
- Kwaliteitscriteria
- Anti-patterns

### 8.3 Single Responsibility

Elke agent heeft exact 1 primaire verantwoordelijkheid. Bij groei: splitsen, niet uitbreiden.

### 8.4 Artefact-Driven

Alle communicatie via expliciete artefacten (Markdown, code). Geen gedeelde state, geen impliciete context.

### 8.5 Git as Source of Truth

Alle governance, agents en artefacten zijn Git-versioned voor traceerbaarheid en rollback.

---

## 9. Kwaliteitsattributen

### Schaalbaarheid
- Nieuwe agents toevoegen zonder bestaande agents aan te passen
- Nieuwe fases toevoegen door framework uit te breiden
- Nieuwe projecten = nieuwe workspace repository

### Auditbaarheid
- Elke agent-actie is herleidbaar naar charter
- Elke artefact is Git-versioned
- Governance hierarchie is expliciet

### Evoluerbaarheid
- Agents aanpassen door charter te updaten
- Agent-scope verkleinen door opsplitsing
- Framework uitbreiden door nieuwe fases

### Automatiseerbaarheid
- Agents zijn script-activeerbaar
- Validatie is automatisch (quality gates)
- End-to-end generatie mogelijk

---

## 10. Belangrijke Beslissingen

### ADR: Git Repository als Container

**Besluit**: Standards, Agent-Capabilities en Project Workspace zijn Git repositories (niet runtime componenten).

**Rationale**: 
- Versioning is cruciaal voor governance
- Git is universeel toegankelijk
- Traceerbaarheid out-of-the-box
- Simpele deployment (clone)

**Alternatieven overwogen**: Database, object store, wiki

### ADR: Moeder Agent is GEEN Runtime Container

**Besluit**: Moeder Agent is een Meta-agent (capability), geen persistente orchestrator.

**Rationale**:
- Agent Ecosysteem is een **generator-systeem**, niet een runtime platform
- Moeder Agent activeert andere agents, maar is zelf niet persistent
- Vergelijk: Een ontwikkelteam bouwt een applicatie, maar is geen onderdeel van de applicatie-architectuur

**Implicatie**: Architectuurdiagrammen tonen ALLEEN wat we bouwen (repositories, artefacten), NIET hoe we het bouwen (meta-agents).

### ADR: SAFe als Delivery Framework

**Besluit**: Gebruik SAFe Development Value Stream fases (A-G+U).

**Rationale**:
- Bewezen framework voor enterprise software delivery
- Explicite fases met duidelijke verantwoordelijkheden
- Ondersteunt kwaliteit en compliance
- Breed geaccepteerd in de industrie

---

## Conclusie

Deze architectuur beschrijft **wat we bouwen**: een ecosysteem van repositories (Standards, Agent-Capabilities, Project Workspace) die samen een governanced agent-platform vormen.

**Volgende stap**: Beschrijf **hoe we het bouwen** in een apart document (stappenplan/value stream voor het opzetten van het ecosysteem).
