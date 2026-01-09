# Agent-Capabilities

> *"Herbruikbare agents gestructureerd volgens de SAFe Development Value Stream"*

**Agent-Capabilities** is een repository met generieke, herbruikbare agents die georganiseerd zijn volgens de **SAFe Development Value Stream (DVS)**. Deze agents ondersteunen teams in elke fase van softwareontwikkeling - van idee tot deployment.

---

## 🎯 Overzicht

Agent-Capabilities biedt agents voor de gehele Development Value Stream:

```
a. Trigger → b. Architectuur → c. Specificatie → d. Ontwerp → e. Bouw → f. Validatie → g. Deploy
   ↓              ↓                   ↓               ↓           ↓           ↓              ↓
Business       ADR's            Requirements      API         Code        Tests        Release
Cases         Patterns         Datamodellen      Design      Generation   Validatie    Management
```

**Plus**: Utility agents (u.*) voor algemene ondersteuning zoals conversies en validaties.

## 🏗️ Structuur

```
/.github
    /copilot/
        agents.yaml                 # Agent registratie voor GitHub Copilot
    /agents/                        # Agent definities (platte structuur, fase prefix)
        a.founding-hypothesis-owner.agent.md
        b.cdm-architect.agent.md
        c.logisch-data-modelleur.agent.md
        ...
/scripts-agent-ecosysteem/          # Agent maker tools
    make-agent.py                   # Genereert agent van charter (auto git pull)
    prompt-builder.py               # Bouwt prompts uit charters
    runner-builder.py               # Genereert runner scripts
    orchestration-builder.py        # Maakt orchestratie configs
    sync-agents.py                  # Sync agents naar project workspaces
/agent-componenten/                 # Alle agent componenten bij elkaar
    /prompts/                       # Agent prompts (sync kopieert naar .github/prompts/ in projecten)
        0.moeder.prompt.md
        a.founding-hypothesis-owner.prompt.md
        b.cdm-architect.prompt.md
        c.logisch-data-modelleur.prompt.md
        d.service-architect.prompt.md
        ...
    /runners/                       # Runner scripts (platte structuur, fase prefix)
        a.founding-hypothesis-owner.py
        b.cdm-architect.py
        c.logisch-data-modelleur.py
        d.service-architect.py
        ...
    /orchestrations/                # Orchestratie configs (platte structuur, volledige fase)
        a.trigger.founding-hypothesis-owner.orchestration.yaml
        b.architectuur.cdm-architect.orchestration.yaml
        c.specificatie.logisch-data-modelleur.orchestration.yaml
        d.ontwerp.service-architect.orchestration.yaml
        ...
    /buildplans/                    # Build metadata (JSON)
        std.a.trigger.founding-hypothesis-owner.json
        std.c.specificatie.logisch-data-modelleur.json
        ...
/desc-agents/                       # Uitgebreide agent documentatie
/templates/                         # Herbruikbare templates
/docs/                              # Project documentatie
requirements.txt
README.md
```

**Belangrijke directories:**
- `agent-componenten/` - Alle agent componenten centraal
- `scripts-agent-ecosysteem/` - Tools om agents te maken en synchroniseren
- **Geen artefacten**: Deze workspace is alleen voor agent componenten, niet voor output

## 🔧 Agent Maker Tools

Deze workspace bevat tools om agents te genereren vanuit **charters** (in externe repository):

### Charter Repository
Charters staan in: `https://github.com/hans-blok/standard.git`

### Agent Maken
```bash
# Genereer agent vanuit charter (git pull gebeurt automatisch)
python scripts-agent-ecosysteem/make-agent.py --agent-name logisch-data-modelleur
```

**Output:**
- `agent-componenten/prompts/c.logisch-data-modelleur.prompt.md` - Prompt (sync kopieert naar .github/prompts/ in projecten)
- `agent-componenten/runners/c.logisch-data-modelleur.py` - Runner script
- `agent-componenten/orchestrations/c.specificatie.logisch-data-modelleur.orchestration.yaml` - Orchestratie config
- `agent-componenten/buildplans/std.c.specificatie.logisch-data-modelleur.json` - Build plan (metadata)

### Agents Synchroniseren naar Andere Workspaces

⚠️ **Agent maker tools worden NIET gesynchroniseerd** - alleen de agents zelf.

```bash
# 1. Clone target repository
git clone https://github.com/user/target-repo.git ../target-workspace

# 2. Dry-run (toon wat gekopieerd wordt)
python scripts-agent-ecosysteem/sync-agents.py --target ../target-workspace --dry-run

# 3. Sync alle agents
python scripts-agent-ecosysteem/sync-agents.py --target ../target-workspace

# 4. Sync specifieke agents
python scripts-agent-ecosysteem/sync-agents.py --target ../target-workspace --agents cdm-architect logisch-data-modelleur
```

**Wat wordt gesynchroniseerd:**
- ✅ Prompts uit `.github/prompts/`
- ✅ Runners uit `agent-componenten/scripts/`
- ✅ Agent registratie (`agents.yaml`)
- ❌ Agent maker tools (blijven in deze workspace)

## ⚙️ Technische Stack

- **Scripts**: Python 3.8+ (cross-platform: Windows, Linux, macOS)
- **Agent Definitie**: Markdown met YAML frontmatter
- **Configuratie**: YAML bestanden
- **Charter Repository**: `https://github.com/hans-blok/standard.git`

### Installatie

```bash
# Python dependencies installeren
pip install -r requirements.txt
```

## 🚀 Gebruik

### Agent Activeren in GitHub Copilot

Agents worden geactiveerd met `@workspace /agent-naam`:

```
@workspace /c.logisch-data-modelleur
@workspace /d.service-architect
@workspace /u.md-to-docx
```

**Let op**: Gebruik kleine letter voor stream prefix (bijv. `c.`, niet `C.`)

### Beschikbare Agents

**Stream a - Trigger:**
- `a.founding-hypothesis-owner` - Vertaalt strategische richting naar testbare founding hypothesis

**Stream b - Architectuur:**
- `b.cdm-architect` - Genereert conceptueel datamodel (CDM) met traceerbaarheid

**Stream c - Specificatie:**
- `c.feature-analist` - Transformeert features naar testbare specificaties (user stories, BDD)
- `c.logisch-data-modelleur` - Genereert logisch datamodel (3NF) uit conceptueel model en specificaties
- `c.schema-custodian` - Beheert en bewaakt datamodel-kwaliteit en consistentie

**Stream d - Ontwerp:**
- `d.service-architect` - Identificeert en classificeert service-kandidaten
- `d.technisch-data-modelleur` - Vertaalt logisch datamodel naar platform-specifiek technisch datamodel (DDL)

**Utility:**
- `u.md-to-archimate-xml` - Converteert Markdown naar Archimate XML-formaat
- `u.md-to-docx` - Converteert Markdown naar Microsoft Word (DOCX)
- `u.md-to-dsl` - Converteert Markdown naar Domain-Specific Language (DSL)

## 📋 Governance

### Design Principles

1. **Kennisbeveiliging**
   - Alleen gevalideerde charters worden toegelaten
   - Alle charters komen uit https://github.com/hans-blok/standard.git
   - Maker tools blijven in source workspace (niet gesynchroniseerd)

2. **Traceerbaarheid**
   - Charter versioning via Git (standard repository)
   - Agent herkomst altijd traceerbaar naar charter commit
   - Sync logs identificeren bron en datum van agent-distributie

3. **Reproducibility**
   - Agents reproduceerbaar via `make-agent.py`
   - Charter-updates triggeren agent regeneratie
   - Dry-run mode voor risico-vrije verificatie

4. **Scheiding van Verantwoordelijkheden**
   - **Source workspace**: Agent creatie en ontwikkeling (scripts-agent-ecosysteem/)
   - **Target workspaces**: Agent gebruik (alleen .github/prompts/ en .github/copilot/agents.yaml)
   - Maker tools NIET toegankelijk in target workspaces

### SAFe Development Value Stream (DVS)

Agents zijn gestructureerd volgens de DVS-fases met kleine letter prefixes:

| Fase | Prefix | Focus | Beschrijving |
|------|--------|-------|--------------|
| Trigger | **a.** | Ideeën, business cases | Initiatieven, founding hypotheses |
| Architectuur | **b.** | Architectonische beslissingen | Architectuurpatronen, conceptueel datamodel |
| Specificatie | **c.** | Requirements, datamodellen | Features, user stories, logisch datamodel |
| Ontwerp | **d.** | Technisch ontwerp | API design, services, technisch datamodel |
| Bouw | **e.** | Code generatie, implementatie | Build automation, scaffolding |
| Validatie | **f.** | Testen, kwaliteitscontrole | Testing, validatie, verificatie |
| Deploy | **g.** | Deployment, release | Release management, documentatie |

### Charter Kwaliteit (uit Standard Repository)

**Verplichte Secties:**
- **## 1. Doel**: Waarom bestaat deze agent?
- **## 2. Scope**: Binnen/Buiten scope grenzen
- **## 3. Input**: Verwachte input specificatie
- **## 4. Output**: Geproduceerde output specificatie
- **## 5. Werkwijze**: Stappen/algoritme/methode
- **## 6. Bevoegdheden**: Acties die agent mag uitvoeren

**Charter Locatie:**
- Repository: https://github.com/hans-blok/standard.git
- Patroon: `charters.agents/{fase}/*.{agent-naam}.md`
- Voorbeelden:
  - `charters.agents/c.specificatie/logisch-data-modelleur.logisch-data-modelleur.md`
  - `charters.agents/d.ontwerp/service-architect.service-architect.md`

**Charter Updates:**
- `make-agent.py` voert **automatisch** `git pull` uit voor c:\gitrepo\standard
- Regenereer gewoon de agent: `python scripts-agent-ecosysteem/make-agent.py --agent-name {naam}`

## 🤖 Agent Catalogus

### Utility Agents (u.*)
**Focus**: Algemene ondersteuning, conversies, validaties

| Agent | Beschrijving | Status |
|-------|-------------|--------|
| **u.md-to-archimate-xml** | Converteert Markdown naar Archimate XML-formaat | ✅ Actief |
| **u.md-to-docx** | Markdown naar DOCX conversie | ✅ Actief |
| **u.md-to-dsl** | Markdown naar DSL conversie | ✅ Actief |

### Stream a: Trigger
**Focus**: Ideeën, business cases, initiatieven

| Agent | Beschrijving | Status |
|-------|-------------|--------|
| **a.founding-hypothesis-owner** | Vertaalt strategische richting naar testbare founding hypothesis | ✅ Actief |

### Stream b: Architectuur
**Focus**: Architectonische beslissingen, patronen, principes

| Agent | Beschrijving | Status |
|-------|-------------|--------|
| **b.cdm-architect** | Genereert conceptueel datamodel (CDM) met traceerbaarheid | ✅ Actief |

### Stream c: Specificatie
**Focus**: Requirements, functionele specificaties, datamodellen

| Agent | Beschrijving | Status |
|-------|-------------|--------|
| **c.feature-analist** | Transformeert features naar testbare specificaties (user stories, BDD) | ✅ Actief |
| **c.logisch-data-modelleur** | Genereert logisch datamodel (3NF) uit conceptueel model en specificaties | ✅ Actief |
| **c.schema-custodian** | Beheert en bewaakt datamodel-kwaliteit en consistentie | ✅ Actief |

### Stream d: Ontwerp
**Focus**: Technisch ontwerp, API design, database design

| Agent | Beschrijving | Status |
|-------|-------------|--------|
| **d.service-architect** | Identificeert en classificeert service-kandidaten volgens TrueLogicX (E,T,O,R,U) | ✅ Actief |
| **d.technisch-data-modelleur** | Vertaalt logisch datamodel naar platform-specifiek technisch datamodel (DDL) | ✅ Actief |

### Stream e: Bouw
**Focus**: Code generatie, implementatie support, build automation

| Agent | Beschrijving | Status |
|-------|-------------|--------|
| *(Nog geen agents)* | - | - |

### Stream f: Validatie
**Focus**: Testen, kwaliteitscontrole, validatie

| Agent | Beschrijving | Status |
|-------|-------------|--------|
| *(Nog geen agents)* | - | - |

### Stream g: Deploy
**Focus**: Deployment, release management, documentatie

| Agent | Beschrijving | Status |
|-------|-------------|--------|
| *(Nog geen agents)* | - | - |

## 📝 Agent Naamgeving en Structuur

### Agent Naamgeving
**Agent-naam formaat:** `<fase>.<agent-naam>` (voor activatie via @workspace)

**Voorbeelden:**
- Stream a: `a.founding-hypothesis-owner` - Founding hypothesis generator
- Stream b: `b.cdm-architect` - Conceptueel datamodel architect
- Stream c: `c.logisch-data-modelleur` - Logisch datamodel generator
- Stream d: `d.service-architect` - Service architect
- Stream d: `d.technisch-data-modelleur` - Technisch datamodel generator
- Utility: `u.md-to-docx` - Markdown naar DOCX converter

**Let op**: Gebruik kleine letter voor fase prefix (bijv. `c.`, niet `C.`)

### Bestanden per Agent

**Voor DVS-stream agents:**
1. **Prompt Bestand**: `agent-componenten/prompts/<fase>.<agent-naam>.prompt.md` 
2. **Runner Script**: `agent-componenten/runners/<fase>.<agent-naam>.py`
3. **Orchestration**: `agent-componenten/orchestrations/<volledige-fase>.<agent-naam>.orchestration.yaml`

**Voor utility agents:**
1. **Prompt Bestand**: `agent-componenten/prompts/u.<agent-naam>.prompt.md`
2. **Runner Script**: `agent-componenten/runners/u.<agent-naam>.py`
3. **Orchestration**: `agent-componenten/orchestrations/u.<agent-naam>.orchestration.yaml`

**Synchronisatie naar projecten:**
- `sync-agents.py` kopieert prompts naar `.github/prompts/` in project workspaces voor GitHub Copilot
- Runners en orchestrations blijven in `agent-componenten/` in project workspaces

**Voorbeelden:**
- Prompt: `c.logisch-data-modelleur.prompt.md` (fase prefix: `c.`)
- Runner: `c.logisch-data-modelleur.py` (fase prefix: `c.`)
- Orchestration: `c.specificatie.logisch-data-modelleur.orchestration.yaml` (volledige fase: `c.specificatie.`)

## 🐍 Python Scripts

Agents hebben Python runner scripts voor geautomatiseerde uitvoering:
- **DVS-agents**: `<fase>.<agent-naam>.py` (bijv. `d.service-architect.py`)
- **Utility agents**: `u.<agent-naam>.py` (bijv. `u.md-to-docx.py`)
- **Locatie**: `agent-componenten/scripts/<fase>/`
- **Features**: Type hints, argument parsing, error handling, progress reporting
- **Cross-platform**: Windows, Linux, macOS

**Installatie:**
```bash
pip install -r requirements.txt
```

**Gebruik:**
```bash
# Runner direct uitvoeren
python agent-componenten/scripts/d.service-architect.py -i input.md -o output.md

# Via orchestration
python agent-componenten/scripts/d.service-architect.py --config agent-componenten/orchestrations/d.ontwerp.service-architect.orchestration.yaml
```

## 🎓 Principes

Agent-Capabilities volgt deze kernprincipes:

1. **DVS-Gestructureerd**: Agents volgen de SAFe Development Value Stream (a-g)
2. **Charter-Based**: Alle agents worden gegenereerd uit gevalideerde charters (https://github.com/hans-blok/standard.git)
3. **Domeinonafhankelijk**: Alle agents zijn generiek en herbruikbaar
4. **Maker-Tools Gescheiden**: Agent creatie tools blijven in source workspace, agents worden gesynchroniseerd naar target workspaces
5. **Reproduceerbaar**: Agents kunnen altijd opnieuw worden gegenereerd uit charters via `make-agent.py`
6. **Menselijke Leesbaarheid**: Documentatie op B1-niveau (Nederlands)

## ❓ FAQ

**Q: Wat is de Development Value Stream (DVS)?**  
A: De DVS beschrijft de flow van softwareontwikkeling: a=Trigger → b=Architectuur → c=Specificatie → d=Ontwerp → e=Bouw → f=Validatie → g=Deploy. Agents ondersteunen specifieke fases met kleine letter prefix.

**Q: Hoe maak ik een nieuwe agent?**  
A: Gebruik `python scripts-agent-ecosysteem/make-agent.py --agent-name {naam}`. Het script zoekt automatisch de juiste charter in https://github.com/hans-blok/standard.git en genereert alle agent artifacts.

**Q: Waar vind ik de charters?**  
A: Charters staan in https://github.com/hans-blok/standard.git, gecloneerd naar c:\gitrepo\standard. Het patroon is `charters.agents/{fase}/*.{agent-naam}.md`.

**Q: Hoe synchroniseer ik agents naar een andere workspace?**  
A: Gebruik `python scripts-agent-ecosysteem/sync-agents.py --target ../target-workspace`. Dit kopieert alleen de agents (prompts, runners, orchestrations), NIET de maker tools.

**Q: Kan ik agents aanpassen?**  
A: Ja, maar doe dit via charter updates in de standard repository. Regenereer daarna de agent met `make-agent.py`. Directe wijzigingen worden overschreven bij regeneratie.

**Q: Waarom kleine letters voor fase prefixes?**  
A: Consistentie met moderne naming conventions en betere leesbaarheid in command-line tools. Bijv. `c.logisch-data-modelleur` in plaats van `C.logisch-data-modelleur`.

**Q: Verschil tussen source en target workspace?**  
A: **Source workspace** (deze): Agent creatie, charter beheer, maker tools. **Target workspaces**: Alleen agent gebruik via @workspace commands. Maker tools zijn NIET beschikbaar in target workspaces.

## 📖 Documentatie

- **Charter Repository**: `https://github.com/hans-blok/standard.git` - Gevalideerde agent charters
- **Agent Maker Tools**: `scripts-agent-ecosysteem/` - Tools voor agent generatie (NIET gesynchroniseerd)
- **Agent Componenten**: `agent-componenten/` - Gegenereerde prompts, runners, orchestrations
- **Moeder-Agent**: `.github/prompts/0.moeder.prompt.md` - Overzichts-agent

## 🔄 Development Value Stream Overzicht

```
a.trigger → b.architectuur → c.specificatie → d.ontwerp → e.bouw → f.validatie → g.deploy
   ↓              ↓                   ↓               ↓           ↓           ↓              ↓
Founding       Conceptueel      Requirements      Service     Code        Tests        Release
Hypotheses     Datamodel       Logisch Model      Design     Generation   Validatie    Management

                            ┌─────────────────────────────────┐
                            │      Utility Agents (u.*)       │
                            │  Converters, Validators, Tools  │
                            │  Beschikbaar in alle fases      │
                            └─────────────────────────────────┘
```

**DVS-agents** ondersteunen een specifieke fase met kleine letter prefix. **Utility agents** ondersteunen alle fases.

## 🤝 Bijdragen

Agent-Capabilities groeit met elke nieuwe herbruikbare agent:
1. Gebruik `@github /agnt-cap.moeder` om een nieuwe agent te maken
2. Moeder-agent bepaalt automatisch DVS-stream of utility categorie
3. Test de agent in een praktijkscenario
4. Documenteer ervaringen en deel verbeteringen

## 📄 Gebruik in Projecten

### Agent Hergebruiken
```bash
# Kopieer utility agent
cp .github/agents/utility/u.md-to-docx.agent.md /jouw-project/.github/agents/
cp .github/prompts/u.md-to-docx.prompt.md /jouw-project/.github/prompts/

# Of kopieer DVS-agent (voorbeeld Stream C)
cp .github/agents/C/datamodel.agent.md /jouw-project/.github/agents/
cp .github/prompts/C.datamodel.prompt.md /jouw-project/.github/prompts/

# Activeer in je project
@github /u.md-to-docx
```

### Script Hergebruiken
```powershell
# Kopieer en gebruik utility script
cp agnt-cap-kit/scripts/u.md-to-docx.ps1 /jouw-project/scripts/
.\u.md-to-docx.ps1 -InputFile "README.md"

# Of DVS-stream script
cp agnt-cap-kit/scripts/C.datamodel.ps1 /jouw-project/scripts/
.\C.datamodel.ps1 -InputFile "requirements.md"
```

---

**Agent-Capabilities** - *DVS-gestructureerde en Utility Agents voor Betere Software*

*"Logos is kenner van het scheppen en het ordenen"*
