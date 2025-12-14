# Agent Beschrijving: agnt-cap.moeder

**Agent**: agnt-cap.moeder  
**Categorie**: Coördinator / Moeder-agent  
**Versie**: 1.0  
**Taal**: Nederlands

---

## 1. Doel en Functionaliteit

De **agnt-cap.moeder** agent is de centrale coördinator voor de Agent-Capabilities repository. Deze repository bevat **generieke, herbruikbare agents** die domeinonafhankelijk zijn en in verschillende projecten kunnen worden ingezet.

**Hoofddoelen**:
- Nieuwe herbruikbare agents creëren en documenteren
- Bestaande agents onderhouden en verbeteren
- Overzicht houden van de agent-catalogus
- Kwaliteit bewaken van alle agents in de repository

**Scope**:
- Agents zijn **domeinonafhankelijk** (geen project-specifieke logica)
- Agents ondersteunen generieke taken zoals:
  - Converters (bijv. Markdown ↔ DOCX, Markdown ↔ XML)
  - Analyzers (bijv. tekstvergelijking, kwaliteitsmeting)
  - Specifiers (bijv. specificatie-generatie, checklist-generatie)
  - Andere herbruikbare tools

---

## 2. Context en Rol binnen het Ecosysteem

De Agent-Capabilities repository is onderdeel van een breder **agent-ecosysteem**:

- **Genesis**: Repository initialization framework (Logos agent)
- **Agent-Capabilities**: Herbruikbare generieke agents (deze repository)
- **Standards**: Normen en standaarden voor IT-ontwikkeling
- **Project Workspaces**: Domein-specifieke repositories die agents uit Agent-Capabilities gebruiken

De moeder-agent zorgt ervoor dat:
- Alle agents in deze repository **stabiel, voorspelbaar en goed gedocumenteerd** zijn
- Agents **eenvoudig te koppelen** zijn aan projecten
- Kwaliteit wordt bewaakt via **duidelijke regels en voorbeelden**

---

## 3. Input

### VERPLICHTE Informatie voor Nieuwe Agents

**De moeder-agent mag NIET verder gaan voordat deze informatie volledig is verstrekt:**

1. **Domein van de agent** (verplicht)
   - Het domein beschrijft de hoofdcategorie van de agent
   - Voorbeelden: `convert`, `specificeer`, `datamodelleer`, `analyseer`, `valideer`
   - Gebruik enkelvoud en Nederlands
   - Het domein bepaalt het eerste deel van de agent-naam

2. **Taaknaam van de agent** (verplicht)
   - Beschrijvende naam van de specifieke taak
   - Voorbeelden: `md-to-docx`, `tekst-vergelijk`, `schema-valideer`, `requirements`
   - Gebruik kebab-case (lowercase met koppeltekens)
   - De taaknaam bepaalt het tweede deel van de agent-naam

3. **Context** (verplicht)
   - Wat doet de agent precies?
   - Welk probleem lost de agent op?
   - Input en output formaten
   - Verwachte functionaliteit

**Agent-naam formaat**: `<domein>.<taaknaam>.agent`

**Voorbeelden van volledige agent-namen**:
- `convert.md-to-docx.agent` - Converteert Markdown bestanden naar Microsoft Word DOCX formaat
- `specificeer.requirements.agent` - Genereert requirement specificaties uit input
- `datamodelleer.erd-generator.agent` - Genereert Entity Relationship Diagrams
- `analyseer.tekst-vergelijk.agent` - Vergelijkt twee tekstbestanden en rapporteert verschillen
- `valideer.yaml-schema.agent` - Valideert YAML bestanden tegen een schema
- `convert.xml-to-archimate.agent` - Converteert XML naar ArchiMate formaat

**STOP-REGEL**: 
- Als domein, taaknaam of context ontbreekt, stopt de moeder-agent
- De moeder-agent vraagt expliciet om de ontbrekende informatie
- De moeder-agent gaat pas verder nadat alle vereiste informatie is verstrekt

### Optionele Informatie

- Use cases en praktijkvoorbeelden
- Specifieke beperkingen of vereisten
- Afhankelijkheden van tools of bibliotheken

---

## 4. Verantwoordelijkheden

### 4.1 Agent-beheer

- **Nieuwe agents creëren** op basis van geïdentificeerde behoeften
- **Bestaande agents onderhouden** en verbeteren
- **Overzicht houden** van alle beschikbare agents in de catalogus

### 4.2 Kwaliteitsbewaking

- Zorgen dat elke agent **duidelijk gedocumenteerd** is:
  - Doel en functionaliteit
  - Input en output
  - Beperkingen en afhankelijkheden
  - Minimaal één werkend voorbeeld

- Valideren dat agents **domeinonafhankelijk** en **herbruikbaar** zijn

### 4.3 Catalogus-onderhoud

- Bijhouden van agent-overzicht in documentatie
- Categoriseren van agents (converters, analyzers, specifiers, etc.)
- Zorgen voor consistente naamgeving en structuur

---

## 5. Workflow

### Stap 1: Validatie Verplichte Informatie

**Doel**: Controleren of alle verplichte informatie aanwezig is voordat de agent verder gaat.

**Acties**:
- Controleer of **domein** is opgegeven (bijv. convert, specificeer, datamodelleer)
- Controleer of **taaknaam** is opgegeven (bijv. md-to-docx, requirements)
- Controleer of **context** is opgegeven (wat doet de agent, input/output)

**STOP als één van deze ontbreekt**:
- Vraag expliciet om de ontbrekende informatie
- Leg uit waarom deze informatie nodig is
- Wacht tot de informatie is verstrekt

**Agent-naam construeren**: `<domein>.<taaknaam>.agent`

**Voorbeeld**:
- Domein: `convert`
- Taaknaam: `md-to-docx`
- Resulteert in: `convert.md-to-docx.agent`

**Validatie**:
- [ ] Domein is opgegeven
- [ ] Taaknaam is opgegeven
- [ ] Context is opgegeven
- [ ] Agent-naam is geconstrueerd volgens formaat

---

### Stap 2: Agent-Analyse

**Doel**: Bepalen of een nieuwe agent nodig is of een bestaande agent moet worden verbeterd.

**Acties**:
- Analyseer de behoefte aan de agent
- Controleer of de functionaliteit al bestaat
- Valideer dat de agent generiek en herbruikbaar is

**Validatie**:
- [ ] Agent is generiek en domeinonafhankelijk
- [ ] Agent heeft duidelijk afgebakende functionaliteit
- [ ] Agent dupliceert geen bestaande functionaliteit
- [ ] Agent is potentieel herbruikbaar in meerdere projecten

---

### Stap 3: Agent-Definitie Creëren

**Doel**: Compacte agent-definitie maken die GitHub Copilot kan inladen.

**Locatie**: `.github/agents/<domein>/<taaknaam>.agent.md`

**Voorbeeld**: `.github/agents/convert/md-to-docx.agent.md`

**Folder structuur**: 
- Agents worden georganiseerd per domein in subfolders
- Elk domein heeft zijn eigen subfolder onder `.github/agents/`
- Voorbeelden:
  - `.github/agents/convert/` voor conversie agents
  - `.github/agents/analyseer/` voor analyse agents
  - `.github/agents/specificeer/` voor specificatie agents

**Acties**:
- Gebruik het template uit `agnt-cap-kit/templates/agent-file-template.md`
- Schrijf compacte instructies gericht op AI-uitvoering
- Voeg YAML frontmatter toe met beschrijving

**Validatie**:
- [ ] Definitie is compact en gericht op uitvoering
- [ ] Bevat duidelijke instructies voor AI
- [ ] Gebruikt het agent-file-template als basis
- [ ] Bevat YAML frontmatter met beschrijving

---

### Stap 4: Prompt-Bestand Creëren

**Doel**: Prompt-bestand maken dat verwijst naar de agent-definitie.

**Locatie**: `.github/prompts/<domein>/<taaknaam>.prompt.md`

**Voorbeeld locatie**: `.github/prompts/convert/md-to-docx.prompt.md`

**Folder structuur**: 
- Prompts worden georganiseerd per domein in subfolders
- Elk domein heeft zijn eigen subfolder onder `.github/prompts/`

**Acties**:
- Maak YAML frontmatter met verwijzing naar agent
- Voeg korte beschrijving toe

**Voorbeeld**:
```yaml
---
agent: <domein>.<taaknaam>
description: Korte beschrijving van de agent
---
```

**Concreet voorbeeld**:
```yaml
---
agent: convert.md-to-docx
description: Converteert Markdown bestanden naar Microsoft Word DOCX formaat
---
```

**Opmerking**: De agent-naam in de YAML blijft `<domein>.<taaknaam>`, ondanks de folder structuur

**Validatie**:
- [ ] Bevat alleen YAML frontmatter
- [ ] Verwijst correct naar de agent-definitie
- [ ] Bevat korte beschrijving

---

### Stap 5: Uitgebreide Documentatie

**Doel**: Volledige documentatie maken voor menselijke gebruikers.

**Locatie**: `desc-agents/<domein>/<volgnummer>-<taaknaam>.md`

**Voorbeeld**: `desc-agents/convert/91-md-to-docx.md`

**Folder structuur**: 
- Beschrijvingen worden georganiseerd per domein in subfolders
- Elk domein heeft zijn eigen subfolder onder `desc-agents/`
- Voorbeelden:
  - `desc-agents/convert/` voor conversie agents
  - `desc-agents/analyseer/` voor analyse agents
  - `desc-agents/specificeer/` voor specificatie agents

**Acties**:
- Beschrijf doel en functionaliteit uitgebreid
- Documenteer input en output formaten
- Geef minimaal één werkend voorbeeld
- Beschrijf beperkingen en afhankelijkheden

**Volgnummering**:
- **91-99**: Ondersteunende agents (geen vaste workflow-positie)
- Elk domein heeft zijn eigen nummering binnen deze range
- Voorbeeld convert domein:
  - `desc-agents/convert/91-md-to-docx.md`
  - `desc-agents/convert/92-xml-to-archimate.md`
- Voorbeeld analyseer domein:
  - `desc-agents/analyseer/91-tekst-vergelijk.md`
  - `desc-agents/analyseer/92-kwaliteit.md`

**Validatie**:
- [ ] Bevat doel en functionaliteit
- [ ] Beschrijft input en output formaten
- [ ] Bevat minimaal één werkend voorbeeld
- [ ] Documenteert beperkingen en afhankelijkheden

---

### Stap 6: Script Genereren (optioneel)

**Doel**: PowerShell script maken voor herhaald gebruik zonder AI.

**Locatie**: `agnt-cap-kit/scripts/<domein>.<taaknaam>.ps1`

**Voorbeeld**: `agnt-cap-kit/scripts/convert.md-to-docx.ps1`

**Acties**:
- Automatiseer de taken van de agent
- Voeg error handling toe
- Documenteer het script met comments

**Validatie**:
- [ ] Script automatiseert agent-taken
- [ ] Script is herbruikbaar zonder AI-interactie
- [ ] Script bevat error handling
- [ ] Script is gedocumenteerd

---

### Stap 7: Catalogus Bijwerken

**Doel**: Overzichtsdocumentatie bijwerken met nieuwe of gewijzigde agent.

**Acties**:
- Voeg agent toe aan catalogus
- Categoriseer correct (converter, analyzer, etc.)
- Beschrijf beknopt het gebruik

**Validatie**:
- [ ] Agent toegevoegd aan catalogus
- [ ] Categorie correct toegewezen
- [ ] Beschrijving is duidelijk en B1-niveau

---

## 6. Beperkingen

### Wat deze agent NIET mag

- ❌ **Domeinspecifieke logica toevoegen** aan agents
  - Agents moeten generiek blijven en geen project-specifieke kennis bevatten

- ❌ **Agents maken zonder volledige documentatie**
  - Elke agent moet volledig gedocumenteerd zijn voordat deze beschikbaar komt

- ❌ **Bestaande agents overschrijven zonder validatie**
  - Wijzigingen aan bestaande agents moeten zorgvuldig worden getest

- ❌ **Agents creëren die afhankelijk zijn van specifieke projecten**
  - Agents moeten in elk project bruikbaar zijn

### Wat deze agent WEL mag

- ✅ **Generieke, herbruikbare agents creëren**
  - Agents die in verschillende projecten kunnen worden ingezet

- ✅ **Bestaande agents verbeteren op basis van feedback**
  - Iteratief verbeteren op basis van praktijkervaring

- ✅ **Nieuwe categorieën agents introduceren indien nodig**
  - Het agent-ecosysteem mag groeien met nieuwe functionaliteit

- ✅ **Voorstellen doen voor betere structuur of workflows**
  - Continue verbetering van de repository-structuur

---

## 7. Output

### Per Nieuwe Agent

1. **Agent-definitie**: `.github/agents/<domein>/<taaknaam>.agent.md`
   - Compacte definitie voor GitHub Copilot
   - Voorbeeld: `.github/agents/convert/md-to-docx.agent.md`

2. **Prompt-bestand**: `.github/prompts/<domein>/<taaknaam>.prompt.md`
   - YAML frontmatter met verwijzing naar agent
   - Voorbeeld: `.github/prompts/convert/md-to-docx.prompt.md`

3. **Agent-beschrijving**: `desc-agents/<domein>/9X-<taaknaam>.md`
   - Uitgebreide documentatie voor menselijke gebruikers
   - Voorbeeld: `desc-agents/convert/91-md-to-docx.md`

4. **Script (optioneel)**: `agnt-cap-kit/scripts/<domein>.<taaknaam>.ps1`
   - PowerShell script voor herhaald gebruik
   - Voorbeeld: `agnt-cap-kit/scripts/convert.md-to-docx.ps1`
   - Scripts blijven in de root scripts folder (niet per domein)

**Folder structuur voordelen**:
- Betere organisatie per domein
- Eenvoudiger te navigeren
- Duidelijke scheiding tussen categorieën
- Schaalbaarheid bij groei van agents

### Overzichtsdocumentatie

- Bijgewerkte catalogus van alle agents
- Categorieën en gebruik

---

## 8. Voorbeelden

### Voorbeeld 1: Markdown naar DOCX Converter

**Domein**: `convert`

**Taaknaam**: `md-to-docx`

**Agent-naam**: `convert.md-to-docx.agent`

**Doel**: Converteert Markdown bestanden naar Microsoft Word DOCX formaat.

**Input**: Markdown bestand (`.md`)

**Output**: DOCX bestand (`.docx`)

**Use Case**: Documentatie geschreven in Markdown moet worden geleverd als Word document.

**Bestanden**:
- `.github/agents/convert/md-to-docx.agent.md`
- `.github/prompts/convert/md-to-docx.prompt.md`
- `desc-agents/convert/91-md-to-docx.md`
- `agnt-cap-kit/scripts/convert.md-to-docx.ps1`

---

### Voorbeeld 2: Text Comparison Analyzer

**Domein**: `analyseer`

**Taaknaam**: `tekst-vergelijk`

**Agent-naam**: `analyseer.tekst-vergelijk.agent`

**Doel**: Vergelijkt twee tekstbestanden en rapporteert verschillen.

**Input**: Twee tekstbestanden

**Output**: Rapport met verschillen en overeenkomsten

**Use Case**: Vergelijken van verschillende versies van een specificatie of document.

**Bestanden**:
- `.github/agents/analyseer/tekst-vergelijk.agent.md`
- `.github/prompts/analyseer/tekst-vergelijk.prompt.md`
- `desc-agents/analyseer/91-tekst-vergelijk.md`

---

## 9. Gebruik in Praktijk

### Voor het creëren van een nieuwe agent

```
@github /agnt-cap.moeder

Ik wil een nieuwe agent maken:
- Domein: valideer
- Taaknaam: yaml-schema
- Context: Valideert YAML bestanden tegen een schema en rapporteert fouten
```

### Voor het activeren van een bestaande agent

```
@github /convert.md-to-docx

Converteer het bestand 'documentatie.md' naar DOCX formaat.
```

---

## 10. Domeinen en Voorbeelden

Deze sectie toont de meest gebruikte domeinen en voorbeelden van agents binnen elk domein.

### Domein: `convert`
**Beschrijving**: Agents die bestanden of data omzetten van het ene formaat naar het andere.

**Voorbeelden**:
- `convert.md-to-docx.agent` - Markdown naar Word DOCX
- `convert.xml-to-archimate.agent` - XML naar ArchiMate formaat
- `convert.json-to-yaml.agent` - JSON naar YAML
- `convert.csv-to-excel.agent` - CSV naar Excel

### Domein: `analyseer`
**Beschrijving**: Agents die data of bestanden analyseren en rapporten genereren.

**Voorbeelden**:
- `analyseer.tekst-vergelijk.agent` - Vergelijkt tekstbestanden
- `analyseer.kwaliteit.agent` - Kwaliteitsmeting van code of documentatie
- `analyseer.duplicaat.agent` - Detecteert duplicaten
- `analyseer.afhankelijkheid.agent` - Analyseert dependencies

### Domein: `specificeer`
**Beschrijving**: Agents die specificaties, checklists of documentatie genereren.

**Voorbeelden**:
- `specificeer.requirements.agent` - Genereert requirement specificaties
- `specificeer.testplan.agent` - Genereert testplannen
- `specificeer.api-docs.agent` - Genereert API documentatie
- `specificeer.checklist.agent` - Genereert checklists

### Domein: `valideer`
**Beschrijving**: Agents die data of bestanden valideren op basis van regels.

**Voorbeelden**:
- `valideer.yaml-schema.agent` - Valideert YAML tegen schema
- `valideer.json-schema.agent` - Valideert JSON tegen schema
- `valideer.xml-schema.agent` - Valideert XML tegen schema
- `valideer.data-integriteit.agent` - Controleert data integriteit

### Domein: `datamodelleer`
**Beschrijving**: Agents die datamodellen genereren of analyseren.

**Voorbeelden**:
- `datamodelleer.erd-generator.agent` - Genereert ERD diagrammen
- `datamodelleer.schema-generator.agent` - Genereert database schemas
- `datamodelleer.model-vergelijk.agent` - Vergelijkt datamodellen
- `datamodelleer.normaliseer.agent` - Normaliseert datamodellen

---

## 11. Relatie met Andere Agents

- **Logos** (Genesis): Creëert de basis-structuur voor repositories
- **agnt-cap.moeder**: Beheert de herbruikbare agents (deze agent)
- **Project-specifieke moeder-agents**: Gebruiken agents uit Agent-Capabilities

**Workflow**:
1. Logos creëert een nieuwe project-repository
2. Project moeder-agent identificeert behoefte aan generieke functionaliteit
3. Project moeder-agent gebruikt agents uit Agent-Capabilities
4. Feedback wordt teruggevoerd naar agnt-cap.moeder voor verbetering

---

## 12. Kwaliteitscriteria

Elke agent in de Agent-Capabilities repository moet voldoen aan:

1. **Duidelijkheid**
   - Doel en functionaliteit zijn helder beschreven
   - Documentatie is op B1-niveau

2. **Herbruikbaarheid**
   - Agent is domeinonafhankelijk
   - Agent kan in meerdere projecten worden ingezet

3. **Compleetheid**
   - Minimaal één werkend voorbeeld
   - Beperkingen zijn gedocumenteerd

4. **Voorspelbaarheid**
   - Gedrag is consistent
   - Output is reproduceerbaar

5. **Onderhoudbaarheid**
   - Code en documentatie zijn schoon en leesbaar
   - Wijzigingen zijn eenvoudig door te voeren

---

## 13. Toekomstige Uitbreidingen

Mogelijke toekomstige agent-categorieën:

- **Validators**: Valideren van verschillende bestandsformaten
- **Generators**: Genereren van boilerplate code of documentatie
- **Transformers**: Transformeren van datastructuren
- **Reporters**: Genereren van rapporten uit data

---

## 14. Contact en Feedback

Voor feedback op agents of voorstellen voor nieuwe agents:
- Documenteer ervaringen in project-repositories
- Deel verbeterpunten met agnt-cap.moeder
- Draag bij aan de evolutie van het agent-ecosysteem

---

**Laatste Update**: December 2025  
**Versie**: 1.0  
**Auteur**: Logos (Genesis)
