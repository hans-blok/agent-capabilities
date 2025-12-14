# Beleid voor Agent-Capabilities Repository

**Repository**: agent-capabilities  
**Kit**: agnt-cap  
**Taal**: Nederlands  
**Versie**: 1.0  
**Datum**: December 2025

---

## 1. Doel en Context

Deze repository bevat **generieke, herbruikbare agents** die domeinonafhankelijk zijn en in verschillende projecten kunnen worden ingezet.

**Doelstelling**:
> Een herbruikbare verzameling generieke agents bieden,  
> die bijdragen aan een schaalbaar ecosysteem voor het realiseren van software met agents,  
> met continue aandacht voor kwaliteit en controle.

**Scope**:
- Agents zijn **stabiel, voorspelbaar en goed gedocumenteerd**
- Agents zijn **eenvoudig te koppelen** aan project-repositories en andere agents
- Kwaliteit wordt bewaakt via **checks, tests en duidelijke regels**

---

## 2. SAFe Development Value Stream (DVS)

De Agent-Capabilities repository is gestructureerd volgens de **SAFe Development Value Stream**. Elke agent heeft een duidelijke plek binnen één van de volgende streams:

### 2.1 Stream A: Trigger
**Focus**: Ideeën, business cases, initiatieven

**Agents ondersteunen**:
- Genereren van business case templates
- Analyseren van initiatieven
- Prioriteren van ideeën
- Feasibility studies

**Prefix**: `A.01`, `A.02`, `A.03`, etc.

**Voorbeelden**:
- `A.01` - Business case generator
- `A.02` - ROI calculator
- `A.03` - Feasibility analyzer

### 2.2 Stream B: Architectuur
**Focus**: Architectonische beslissingen, patronen, principes

**Agents ondersteunen**:
- Genereren van architectuur documenten
- Analyseren van technische keuzes
- Valideren van architectuur beslissingen
- Creëren van ADR's (Architecture Decision Records)

**Prefix**: `B.01`, `B.02`, `B.03`, etc.

**Voorbeelden**:
- `B.01` - ADR generator
- `B.02` - Architectuur patroon analyzer
- `B.03` - Technology stack validator

### 2.3 Stream C: Specificeren
**Focus**: Requirements, functionele specificaties, datamodellen

**Agents ondersteunen**:
- Genereren van requirement specificaties
- Creëren van datamodellen (conceptueel, logisch)
- Analyseren van requirements
- Valideren van specificaties
- Conversie van specificatie formaten

**Prefix**: `C.01`, `C.02`, `C.03`, etc.

**Voorbeelden**:
- `C.01` - Conceptueel datamodel generator
- `C.02` - Requirement specificatie generator
- `C.03` - Use case analyzer
- `C.04` - Markdown naar DOCX converter (voor specificaties)

### 2.4 Stream D: Ontwerp
**Focus**: Technisch ontwerp, API design, database design

**Agents ondersteunen**:
- Genereren van technische ontwerpen
- Creëren van API specificaties
- Database schema ontwerp
- UML diagrammen
- Interface designs

**Prefix**: `D.01`, `D.02`, `D.03`, etc.

**Voorbeelden**:
- `D.01` - API specificatie generator (OpenAPI)
- `D.02` - Database schema generator
- `D.03` - UML class diagram generator
- `D.04` - Sequence diagram generator

### 2.5 Stream E: Bouw
**Focus**: Code generatie, implementatie support, build automation

**Agents ondersteunen**:
- Code generatie
- Boilerplate creatie
- Build script generatie
- Configuration management
- Dependency analysis

**Prefix**: `E.01`, `E.02`, `E.03`, etc.

**Voorbeelden**:
- `E.01` - CRUD code generator
- `E.02` - Test fixture generator
- `E.03` - Configuration file generator
- `E.04` - Dependency analyzer

### 2.6 Stream F: Valideren
**Focus**: Testen, kwaliteitscontrole, validatie

**Agents ondersteunen**:
- Test case generatie
- Test data generatie
- Kwaliteitsmetingen
- Schema validatie
- Code review support

**Prefix**: `F.01`, `F.02`, `F.03`, etc.

**Voorbeelden**:
- `F.01` - Test case generator
- `F.02` - Test data generator
- `F.03` - JSON/YAML schema validator
- `F.04` - Code quality analyzer

### 2.7 Stream G: Deploy
**Focus**: Deployment, release management, documentatie

**Agents ondersteunen**:
- Release notes generatie
- Deployment script generatie
- Migratie scripts
- Operationele documentatie
- Rollback procedures

**Prefix**: `G.01`, `G.02`, `G.03`, etc.

**Voorbeelden**:
- `G.01` - Release notes generator
- `G.02` - Deployment checklist generator
- `G.03` - Database migration script generator
- `G.04` - Operations runbook generator

---

## 3. Kwaliteitsnormen

### 3.1 Documentatie
Elke agent moet volledig gedocumenteerd zijn:

- **Agent-definitie** (`.github/agents/<stream>/`) - Compact, voor AI-uitvoering
- **Prompt-bestand** (`.github/prompts/<stream>/`) - YAML frontmatter met verwijzing
- **Agent-beschrijving** (`desc-agents/<stream>/`) - Uitgebreide documentatie voor mensen

**Minimale inhoud**:
- **DVS Positie**: Welke stream (A-G) en volgnummer (01-99)
- **Doel en functionaliteit**: Wat doet de agent?
- **Input en output formaten**: Welke data wordt verwacht en geleverd?
- **Beperkingen en afhankelijkheden**: Wat zijn de grenzen?
- **Minimaal één werkend voorbeeld**: Praktijkscenario met verwacht resultaat

**Bestandsnaamgeving**:
- Agent-beschrijving: `<prefix>-<taaknaam>.md` (bijv. `C.01-conceptueel-datamodel.md`)
- Agent-definitie: `<taaknaam>.agent.md` (bijv. `conceptueel-datamodel.agent.md`)
- Prompt-bestand: `<taaknaam>.prompt.md` (bijv. `conceptueel-datamodel.prompt.md`)

### 3.2 Herbruikbaarheid
Agents moeten **domeinonafhankelijk** zijn:

- Geen project-specifieke logica
- Geen hardcoded pad of configuraties
- Geen specifieke domeinkennis vereist
- Bruikbaar in verschillende contexten

### 3.3 Voorspelbaarheid
Agent-gedrag moet **consistent en reproduceerbaar** zijn:

- Duidelijk gedefinieerde input en output
- Geen hidden dependencies
- Foutafhandeling is gedocumenteerd
- Resultaten zijn verifieerbaar

---

## 4. Ontwikkelproces

### 4.1 Nieuwe Agent Creëren

1. **Identificeer behoefte**
   - Is de functionaliteit generiek genoeg?
   - Bestaat er al een vergelijkbare agent?
   - Is de agent herbruikbaar in meerdere projecten?
   - **In welke DVS-stream hoort deze agent thuis?**

2. **Ontwerp de agent**
   - Definieer doel en scope
   - Bepaal input en output formaten
   - Identificeer afhankelijkheden en beperkingen
   - **Bepaal DVS-positie** (stream A-G)

3. **Creëer de agent via agnt-cap.moeder**
   - Gebruik `@github /agnt-cap.moeder` om de agent te creëren
   - Geef aan: domein, taaknaam, context, **en gewenste DVS-stream**
   - Moeder-agent bepaalt definitieve positie en prefix
   - Bij twijfel vraagt moeder-agent om verduidelijking
   - Volg de workflow van de moeder-agent

4. **Test de agent**
   - Test met minimaal één praktijkvoorbeeld
   - Valideer output
   - Documenteer resultaten
   - Verifieer dat DVS-positie correct is

5. **Publiceer de agent**
   - Update catalogus per stream
   - Deel met team
   - Verzamel feedback

### 4.2 Agent Verbeteren

1. **Verzamel feedback**
   - Uit projecten die de agent gebruiken
   - Uit praktijkervaring
   - Uit bug reports

2. **Analyseer verbeteringen**
   - Blijft de agent generiek?
   - Is de verbetering waardevol voor meerdere projecten?
   - Breekt de wijziging bestaande functionaliteit?

3. **Implementeer verbeteringen**
   - Update agent-definitie en documentatie
   - Test de wijzigingen
   - Communiceer wijzigingen aan gebruikers

---

## 5. Gebruik van Agents

### 5.1 In Projecten

Agents uit deze repository kunnen worden gebruikt in project-repositories:

1. **Kopieer de agent-definitie** naar het project (`.github/agents/`)
2. **Pas de agent aan** indien nodig voor project-specifieke context
3. **Gebruik de agent** met `@github /agnt-cap.<agent-naam>`
4. **Deel feedback** met agnt-cap.moeder voor verbetering

### 5.2 In Workflows

Agents kunnen worden ingezet in workflows:

1. **Identificeer workflow-stappen** die generieke functionaliteit vereisen
2. **Selecteer de juiste agent** uit de catalogus
3. **Integreer de agent** in de workflow
4. **Documenteer het gebruik** in workflow-documentatie

---

## 6. Governance en Verantwoordelijkheden

### 6.1 Moeder-Agent (agnt-cap.moeder)

Verantwoordelijk voor:
- Creëren van nieuwe agents
- **Bepalen van DVS-positie** (stream A-G en volgnummer)
- **Vragen om input bij twijfel** over de juiste stream-positie
- Onderhouden van bestaande agents
- Bewaken van kwaliteit
- Bijhouden van catalogus per stream
- Zorgen voor correcte prefix-toewijzing

### 6.2 Project-Teams

Verantwoordelijk voor:
- Identificeren van behoeften aan nieuwe agents
- Delen van feedback over bestaande agents
- Testen van agents in praktijkscenario's

### 6.3 Gebruikers

Verantwoordelijk voor:
- Correct gebruik van agents
- Documenteren van ervaringen
- Rapporteren van bugs of problemen

---

## 7. Uitgangspunten

### 7.1 Ervaring en Professionaliteit

- We zijn **beginnend** in het werken met agents
- We zijn **zeer ervaren** in IT, architectuur en softwareontwikkeling
- We bouwen dit **stap voor stap** uit op basis van praktijkervaring

### 7.2 Kwaliteit boven Kwantiteit

- Liever een paar goede agents dan veel half-af agents
- Elke agent heeft een **duidelijke, afgebakende taak**
- Kwaliteit en onderhoudbaarheid gaan vóór snelheid

### 7.3 Iteratieve Verbetering

- We beginnen met een **kleine set capabilities**
- We breiden uit op basis van **echte praktijkervaring**
- Bestaande agents worden verbeterd voordat nieuwe worden toegevoegd

---

## 8. Technische Conventies

### 8.1 Naamgeving

**DVS Prefix Systeem**:
- Elke agent krijgt een prefix die zijn positie in de Development Value Stream aangeeft
- Format: `<STREAM>.<VOLGNUMMER>` (bijv. `C.01`, `D.05`, `F.03`)
- Streams: A=Trigger, B=Architectuur, C=Specificeren, D=Ontwerp, E=Bouw, F=Valideren, G=Deploy
- Volgnummers: 01-99 (per stream)

**Agent-namen**: kebab-case (bijv. `conceptueel-datamodel`, `md-to-docx`)

**Bestanden**:
- Agent-definitie: `.github/agents/<stream>/<taaknaam>.agent.md`
- Prompt-bestand: `.github/prompts/<stream>/<taaknaam>.prompt.md`
- Agent-beschrijving: `desc-agents/<stream>/<PREFIX>-<taaknaam>.md` (bijv. `C.01-conceptueel-datamodel.md`)
- Scripts: `agnt-cap-kit/scripts/<stream>.<taaknaam>.ps1` (bijv. `C.md-to-docx.ps1`)

**Voorbeelden**:
- `C.01-conceptueel-datamodel.md` - Eerste agent in Specificeren stream
- `D.05-api-specificatie.md` - Vijfde agent in Ontwerp stream
- `F.02-test-data-generator.md` - Tweede agent in Valideren stream

### 8.2 Documentatie Niveau

- Alle documentatie op **B1-niveau** (begrijpelijk voor niet-technische lezers)
- Formeel, duidelijk en eenvoudig
- Geen jargon zonder uitleg

### 8.3 Versiebeheer

- Gebruik van Git voor versiebeheer
- Duidelijke commit messages
- Changes worden gedocumenteerd

---

## 9. Beperkingen en Restricties

### 9.1 Wat NIET in deze Repository Thuishoort

- ❌ Domeinspecifieke logica
- ❌ Project-specifieke configuraties
- ❌ Hardcoded waarden of paden
- ❌ Agents die afhankelijk zijn van specifieke projecten

### 9.2 Wat WEL in deze Repository Thuishoort

- ✅ Generieke, herbruikbare functionaliteit
- ✅ Domeinonafhankelijke tools
- ✅ Converters, analyzers, specifiers, validators
- ✅ Goed gedocumenteerde agents met voorbeelden

---

## 10. Toekomstige Ontwikkeling

### 10.1 Waar Mogelijk Automatiseren

- Validatie van agent-definities
- Testen van agents
- Catalogus-generatie
- Documentatie-checks

### 10.2 Uitbreiden van Categorieën

Op basis van praktijkervaring kunnen nieuwe categorieën worden toegevoegd:
- Generators
- Transformers
- Reporters
- Orchestrators

### 10.3 Integratie met Standards Repository

Agents kunnen normen en standaarden uit de Standards repository toepassen bij hun werk.

---

## 11. Contact en Bijdragen

Voor vragen, feedback of bijdragen:
- Gebruik de moeder-agent: `@github /agnt-cap.moeder`
- Documenteer ervaringen in project-repositories
- Deel verbeterpunten en suggesties

---

**Dit beleid is opgesteld door**: agnt-cap.moeder (via Logos)  
**Laatste update**: December 2025  
**Versie**: 1.0
