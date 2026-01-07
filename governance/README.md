# Governance - Agent-Capabilities Workspace

Deze workspace bevat **herbruikbare agent-componenten** voor het SAFe Development Value Stream ecosysteem.

## Scope van deze Workspace

### Wat doen we WEL
- **Agent-componenten definiëren**: Prompts, runners, orchestrations, buildplans voor herbruikbare agents
- **Agent-maker scripts**: Tooling om agents te genereren vanuit charters (standard repository)
- **Sync mechanisme**: Scripts om agent-componenten te distribueren naar project workspaces
- **Governance documenteren**: Principes en regels voor agent-ontwikkeling
- **Theoretische onderbouwing**: Documentatie over het agent-ecosysteem

### Wat doen we NIET
- **Artefacten produceren**: Geen output zoals CDM, LDM, specificaties (dat gebeurt in project workspaces)
- **Agents uitvoeren**: Agents worden uitgevoerd in project workspaces, niet hier
- **Project-specifieke configuratie**: Geen project-specifieke settings of data
- **Business content**: Geen business requirements, designs of implementaties

## Principes

### 1. Separation of Concerns
- **Agents (charters)**: Gedefinieerd in standard repository (`c:\gitrepo\standard`)
- **Agent-componenten**: Gegenereerd en opgeslagen in deze workspace
- **Project workspaces**: Ontvangen components via sync, voeren agents uit, produceren artefacten

### 2. Single Source of Truth
- **Charters** zijn de source of truth voor agent-definities
- **prompt-builder.py** genereert minimale prompts (alleen agent-referentie)
- Prompts bevatten GEEN uitgebreide instructies - die staan in charters

### 3. Schaalbaarheid
- Minimale prompts zorgen voor snelle sync en updates
- Components zijn herbruikbaar across projects
- Charter-updates propageren automatisch bij agent-regeneratie

### 4. Naming Conventions
- Fase-prefix: `a.`, `b.`, `c.`, `d.`, `u.` (lowercase)
- Agent-naam: kebab-case (bijv. `logisch-data-modelleur`)
- Agent-ID: `std.<fase>.<agent-naam>` (bijv. `std.c.logisch-data-modelleur`)
- Bestanden: `<fase>.<agent-naam>.<type>` (bijv. `c.logisch-data-modelleur.prompt.md`)

## Directorystructuur

```
agent-capabilities/
├── governance/                    # Dit bestand - workspace-specifiek beleid
├── scripts-agent-ecosysteem/      # Maker en sync scripts
│   ├── make-agent.py             # Genereert agents vanuit charters
│   ├── sync-agents.py            # Distribueert components naar projects
│   ├── prompt-builder.py         # Genereert minimale prompts
│   ├── runner-builder.py         # Genereert runner scripts
│   └── orchestration-builder.py  # Genereert orchestration configs
├── agent-componenten/            # Generated components
│   ├── prompts/                  # Minimale prompt references
│   ├── runners/                  # Python execution scripts
│   ├── orchestrations/           # YAML workflow configs
│   └── buildplans/               # JSON build metadata
├── .github/
│   └── copilot/
│       └── agents.yaml           # Agent aliases voor Copilot
├── desc-agents/                  # Agent beschrijvingen (documentatie)
├── theorie/                      # Theoretische onderbouwing
└── templates/                    # Templates voor nieuwe agents
```

## Workflow: Agent Toevoegen

### 1. Charter Schrijven (in standard repository)
```bash
# Locatie: c:\gitrepo\standard\charters.agents\
# Naam: std.agent.charter.<fase>.<agent-naam>.md
```

### 2. Agent Genereren
```bash
cd c:\gitrepo\agent-capabilities\scripts-agent-ecosysteem
python make-agent.py --agent-name <agent-naam> --local-charter-clone "c:\gitrepo\standard"
```

Dit genereert:
- `agent-componenten/prompts/<fase>.<agent-naam>.prompt.md`
- `agent-componenten/runners/<fase>.<agent-naam>.py`
- `agent-componenten/orchestrations/<fase>.<agent-naam>.orchestration.yaml`
- `agent-componenten/buildplans/std.<fase>.<agent-naam>.json`

### 3. Sync naar Project Workspaces
```bash
python sync-agents.py --target <project-workspace>
```

Kopieert:
- Prompts → `<project>/.github/prompts/`
- Runners → `<project>/agent-componenten/runners/`
- Orchestrations → `<project>/agent-componenten/orchestrations/`
- agents.yaml → `<project>/.github/copilot/agents.yaml`

## Kwaliteitscriteria

### Voor Charters (in standard repository)
- Helder gedefinieerde scope (binnen/buiten scope)
- Expliciete inputs en outputs
- Maximaal 3 aannames
- Traceerbaarheid naar upstream/downstream agents
- Nederlands B1 niveau

### Voor Generated Components
- **Prompts**: Minimaal - alleen agent-ID en charter-referentie
- **Runners**: Executable Python scripts met argument handling
- **Orchestrations**: Valide YAML met alle metadata
- **Buildplans**: Complete JSON met alle paths en settings

### Voor Sync
- Geen overschrijven zonder confirmatie
- Validatie dat target workspace bestaat
- Check dat prompts-directory aanwezig is
- Logging van alle copy-acties

## Versiebeheer

### Agents
- Versie zit in charter (standard repository)
- Agent-ID blijft stabiel (`std.<fase>.<naam>`)
- Bij breaking changes: nieuwe agent-naam

### Components
- Gegenereerd op `generatedOn` timestamp in buildplan
- Charter-path tracked in buildplan voor traceerbaarheid
- Git commits voor change tracking

## Security & Privacy

- Geen credentials in components
- Geen business data in deze workspace
- Geen PII in templates of voorbeelden
- Project workspaces verantwoordelijk voor hun eigen security

## Dependencies

### Python
- Python 3.8+
- `pathlib`, `argparse`, `json`, `subprocess` (stdlib)
- Geen externe dependencies voor core functionality

### External
- Standard repository: `c:\gitrepo\standard` (charters)
- Project workspaces: Targets voor sync

## Contact & Escalatie

- Charter-wijzigingen: Via standard repository
- Component-issues: Via deze workspace
- Project-specifieke vragen: Via project workspace
- Fundamentele architectuur: Escaleer naar Enterprise Architect
