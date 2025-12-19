# Agent-Capabilities

> *"Herbruikbare agents gestructureerd volgens de SAFe Development Value Stream"*

**Agent-Capabilities** is een repository met generieke, herbruikbare agents die georganiseerd zijn volgens de **SAFe Development Value Stream (DVS)**. Deze agents ondersteunen teams in elke fase van softwareontwikkeling - van idee tot deployment.

---

## 🎯 Overzicht

Agent-Capabilities biedt agents voor de gehele Development Value Stream:

```
A. Trigger → B. Architectuur → C. Specificeren → D. Ontwerp → E. Bouw → F. Valideren → G. Deploy
   ↓              ↓                   ↓               ↓           ↓           ↓              ↓
Business       ADR's            Requirements      API         Code        Tests        Release
Cases         Patterns         Datamodellen      Design      Generation   Validatie    Management
```

**Plus**: Utility agents (u.*) voor algemene ondersteuning zoals conversies en validaties.

## 🏗️ Structuur

```
/.github
    /agents/             # Agent definities per DVS-stream
        /a.trigger/      # Stream A: Trigger (kleine letters, beschrijvend)
        /b.architectuur/ # Stream B: Architectuur
        /c.specificatie/ # Stream C: Specificeren
        /d.solution-design/ # Stream D: Ontwerp
        /e.bouw/         # Stream E: Bouw
        /f.validatie/    # Stream F: Valideren
        /g.deployment/   # Stream G: Deploy
        /utility/        # Utility agents (domeinonafhankelijk)
        agnt-cap.moeder.agent.md
    /prompts/            # Prompt bestanden (root, voor Copilot)
        a.*.prompt.md, b.*.prompt.md, c.*.prompt.md, etc. (kleine letter)
        d.service-architect.prompt.md
        u.*.prompt.md    # Utility prompts
        agnt-cap.moeder.prompt.md
/desc-agents/            # Uitgebreide documentatie
    /a.trigger/, /b.architectuur/, /c.specificatie/, ...   # Per DVS-stream
    /d.solution-design/  # Stream D documentatie
    /utility/            # Utility documentatie
    00-agnt-cap-moeder-agent.md
/agnt-cap-kit
    /scripts/            # PowerShell scripts (stream.taaknaam.ps1, kleine letter)
    /templates/          # Herbruikbare templates
/agnt-cap-governance
    constitutie.md       # Algemene regels (bindend)
    handvest-logos.md    # Logos structuurprincipes
    beleid.md            # DVS-gestructureerd beleid
/input/                  # Input bestanden (lokaal, niet in git)
.gitignore
README.md
```

## 🚀 Gebruik

### Moeder-Agent: Nieuwe Agents Creëren

```
@github /agnt-cap.moeder
```

**Benodigde informatie:**
1. **Taaknaam**: Beschrijvende naam (bijv. `conceptueel-datamodel`, `api-spec`)
2. **Context**: Wat doet de agent? Input/output formaten? In welke ontwikkelfase?

De moeder-agent bepaalt automatisch de juiste DVS-stream op basis van de context.

**Voorbeeld:**
```
@github /agnt-cap.moeder
Taaknaam: conceptueel-datamodel
Context: Genereert conceptueel datamodel uit requirement specificaties.
Wordt gebruikt in de specificatiefase voor data-analyse.
```

→ Moeder-agent bepaalt: Stream C (Specificeren)

### Bestaande Agents Gebruiken

**Activeer een agent:**
```
@github /<stream>.<taaknaam>
```

**Voorbeelden:**
```
@github /u.md-to-docx          # Utility: Markdown naar DOCX
@github /d.service-architect   # Stream D: Service Architect
@github /c.datamodel           # Stream C: Datamodel generator (voorbeeld)
@github /f.schema-validator    # Stream F: Schema validatie (voorbeeld)
```

**Let op**: Agent-namen gebruiken kleine letter voor stream prefix (bijv. `d.`, niet `D.`)

## 📋 Governance

### Constitutie
De **constitutie** (`agnt-cap-governance/constitutie.md`) bevat algemene regels die bindend zijn voor alle repositories en agents:
- Taalgebruik en communicatie (B1 niveau)
- Professionele normen (agile, duurzaam ontwerp)
- Kwaliteitseisen voor specificaties
- AI-agent gedrag en orkestratie
- Transparantie en traceerbaarheid

### Handvest van Logos
Het **handvest** (`agnt-cap-governance/handvest-logos.md`) beschrijft hoe deze repository is opgezet door de Logos agent vanuit Genesis.

### Beleid
Het **beleid** (`agnt-cap-governance/beleid.md`) bevat specifieke regels voor Agent-Capabilities:
- Agents zijn gestructureerd volgens **SAFe Development Value Stream (DVS)**
- Streams: A=Trigger, B=Architectuur, C=Specificeren, D=Ontwerp, E=Bouw, F=Valideren, G=Deploy
- Agent moet generiek en domeinonafhankelijk zijn
- Minimaal één werkend voorbeeld vereist
- Documentatie op B1-niveau
- Moeder-agent bepaalt DVS-positie en prefix

## 🤖 Agent Catalogus

### Utility Agents (u.*)
**Focus**: Algemene ondersteuning, conversies, validaties

| Agent | Beschrijving | Status |
|-------|-------------|--------|
| **u.md-to-docx** | Markdown naar DOCX conversie | ✅ Actief |
| **u.md-to-dsl** | Markdown naar DSL conversie | 🔄 In ontwikkeling |

### Stream A: Trigger
**Focus**: Ideeën, business cases, initiatieven

| Prefix | Agent | Beschrijving | Status |
|--------|-------|-------------|--------|
| *(Nog geen agents)* | - | - | - |

### Stream B: Architectuur
**Focus**: Architectonische beslissingen, patronen, principes

| Prefix | Agent | Beschrijving | Status |
|--------|-------|-------------|--------|
| *(Nog geen agents)* | - | - | - |

### Stream C: Specificeren
**Focus**: Requirements, functionele specificaties, datamodellen

| Prefix | Agent | Beschrijving | Status |
|--------|-------|-------------|--------|
| *(Nog geen agents)* | - | - | - |

### Stream D: Ontwerp
**Focus**: Technisch ontwerp, API design, database design

| Prefix | Agent | Beschrijving | Status |
|--------|-------|-------------|--------|
| D.01 | [service-architect](.github/agents/d.solution-design/service-architect.agent.md) | Identificeert en classificeert service-kandidaten volgens TrueLogicX (E,T,O,R,U) | ✅ Active |

### Stream E: Bouw
**Focus**: Code generatie, implementatie support, build automation

| Prefix | Agent | Beschrijving | Status |
|--------|-------|-------------|--------|
| *(Nog geen agents)* | - | - | - |

### Stream F: Valideren
**Focus**: Testen, kwaliteitscontrole, validatie

| Prefix | Agent | Beschrijving | Status |
|--------|-------|-------------|--------|
| *(Nog geen agents)* | - | - | - |

### Stream G: Deploy
**Focus**: Deployment, release management, documentatie

| Prefix | Agent | Beschrijving | Status |
|--------|-------|-------------|--------|
| *(Nog geen agents)* | - | - | - |

## 📝 Agent Naamgeving en Structuur

### DVS-Stream Agents
**Agent-naam formaat:** `<stream>.<taaknaam>` (voor activatie)  
**DVS Prefix:** `<STREAM>.<VOLGNUMMER>` (voor documentatie)

**Voorbeelden:**
- Stream A: `A.01-business-case` - Business case generator
- Stream B: `B.01-adr-template` - ADR template generator
- Stream C: `C.01-conceptueel-datamodel` - Conceptueel datamodel generator
- Stream D: `D.01-api-spec` - OpenAPI specificatie generator
- Stream E: `E.01-crud-generator` - CRUD code generator
- Stream F: `F.01-test-case-generator` - Test case generator
- Stream G: `G.01-release-notes` - Release notes generator

### Utility Agents
**Agent-naam formaat:** `u.<taaknaam>` (voor activatie)  
**Geen prefix** - utility agents zijn stream-onafhankelijk

**Voorbeelden:**
- `u.md-to-docx` - Markdown naar DOCX converter
- `u.yaml-validator` - YAML schema validator
- `u.file-compare` - Bestandsvergelijker

### Bestanden per Agent

**Voor DVS-stream agents:**
1. **Agent Definitie**: `.github/agents/<STREAM>/<taaknaam>.agent.md`
2. **Prompt Bestand**: `.github/prompts/<STREAM>.<taaknaam>.prompt.md` *(root voor Copilot)*
3. **Beschrijving**: `desc-agents/<STREAM>/<PREFIX>-<taaknaam>.md`
4. **Script** (optioneel): `agnt-cap-kit/scripts/<STREAM>.<taaknaam>.ps1`

**Voor utility agents:**
1. **Agent Definitie**: `.github/agents/utility/<taaknaam>.agent.md`
2. **Prompt Bestand**: `.github/prompts/u.<taaknaam>.prompt.md` *(root voor Copilot)*
3. **Beschrijving**: `desc-agents/u.utility/u.<taaknaam>.md`
4. **Script** (optioneel): `agnt-cap-kit/scripts/u.<taaknaam>.ps1`

**Opmerking**: Prompt bestanden blijven in `.github/prompts/` root omdat GitHub Copilot alleen prompts in de root herkent voor `@github /` activatie.

## 🛠️ PowerShell Scripts

Agents kunnen PowerShell scripts genereren voor herhaald gebruik:
- **DVS-agents**: `<stream>.<taaknaam>.ps1` (bijv. `C.datamodel.ps1`)
- **Utility agents**: `u.<taaknaam>.ps1` (bijv. `u.md-to-docx.ps1`)
- **Locatie**: `agnt-cap-kit/scripts/`
- **Features**: Parameter validatie, error handling, progress reporting
- **Voorbeeld**: `u.md-to-docx.ps1` (Utility), `C.datamodel.ps1` (Stream C)

## 🎓 Principes

Agent-Capabilities volgt deze kernprincipes:

1. **DVS-Gestructureerd**: DVS-agents volgen de SAFe Development Value Stream (A-G)
2. **Utility Support**: Utility agents (u.*) bieden stream-onafhankelijke ondersteuning
3. **Domeinonafhankelijk**: Alle agents zijn generiek en herbruikbaar
4. **Volledig Gedocumenteerd**: Elke agent heeft definitie + beschrijving + voorbeelden
5. **Kwaliteit Eerst**: Moeder-agent valideert en bepaalt DVS-positie
6. **Menselijke Leesbaarheid**: Documentatie op B1-niveau (Nederlands)

## ❓ FAQ

**Q: Wat is de Development Value Stream (DVS)?**  
A: De DVS beschrijft de flow van softwareontwikkeling: A=Trigger → B=Architectuur → C=Specificeren → D=Ontwerp → E=Bouw → F=Valideren → G=Deploy. DVS-agents ondersteunen een specifieke fase.

**Q: Wat zijn utility agents?**  
A: Utility agents (u.*) zijn stream-onafhankelijke tools zoals converters en validators. Ze kunnen in elke DVS-fase worden gebruikt.

**Q: Hoe maak ik een nieuwe agent?**  
A: Gebruik `@github /agnt-cap.moeder` met taaknaam en context. De moeder-agent bepaalt automatisch of het een DVS-agent of utility agent wordt.

**Q: Wie bepaalt in welke DVS-stream een agent thuishoort?**  
A: De moeder-agent analyseert de context. Bij twijfel vraagt de moeder-agent om input. Algemene tools worden utility agents.

**Q: Verschil tussen DVS-agent en utility agent?**  
A: DVS-agents zijn specifiek voor één ontwikkelfase (bijv. C.datamodel voor specificeren). Utility agents zijn algemeen bruikbaar (bijv. u.md-to-docx voor conversies).

**Q: Kan ik een agent aanpassen voor mijn project?**  
A: Ja! Kopieer de agent naar je project en pas aan. Deel verbeteringen terug naar agent-capabilities.

**Q: Waarom twee bestanden per agent?**  
A: `.agent.md` is compact voor AI (efficiënt). Beschrijving in `desc-agents/` is uitgebreid voor mensen.

## 📖 Documentatie

- **Constitutie**: `agnt-cap-governance/constitutie.md` - Algemene regels (10 artikelen)
- **Handvest**: `agnt-cap-governance/handvest-logos.md` - Logos structuurprincipes
- **Beleid**: `agnt-cap-governance/beleid.md` - DVS en utility agent structuur
- **Moeder-Agent**: `desc-agents/00-agnt-cap-moeder-agent.md` - Volledige documentatie

## 🔄 Development Value Stream Overzicht

```
A. Trigger → B. Architectuur → C. Specificeren → D. Ontwerp → E. Bouw → F. Valideren → G. Deploy
   ↓              ↓                   ↓               ↓           ↓           ↓              ↓
Business       ADR's            Requirements      API         Code        Tests        Release
Cases         Patterns         Datamodellen      Design      Generation   Validatie    Management

                            ┌─────────────────────────────────┐
                            │      Utility Agents (u.*)       │
                            │  Converters, Validators, Tools  │
                            │  Beschikbaar in alle fases      │
                            └─────────────────────────────────┘
```

**DVS-agents** ondersteunen een specifieke fase. **Utility agents** ondersteunen alle fases.

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
