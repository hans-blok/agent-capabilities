# Agent-Capabilities – Context

## 1. Rol binnen het agent-ecosysteem

Deze workspace is onderdeel van een breder **agent-ecosysteem**.  
De repository **`agent-capabilities`** bevat **generieke agents**:

- converters (bijvoorbeeld Markdown ↔ DOCX, Markdown ↔ XML)  
- analyzers (bijvoorbeeld vergelijken, confronteren, kwaliteit meten)  
- specifiers (bijvoorbeeld specificaties of checklists genereren)  
- andere gespecialiseerde, maar **domeinonafhankelijke** taken  

Deze agents hebben **geen domeinkennis** van een specifiek project.  
Ze zijn bedoeld als **professionele tools** die in verschillende projecten kunnen worden ingezet.

---

## 2. Projectachtergrond

We willen software sneller en beter bouwen met behulp van agents.  
Hiervoor stellen we een **topteam van agents** samen dat IT-werk ondersteunt, zoals:

- specificeren van requirements  
- datamodelleren  
- database-analyse en DBA-ondersteuning  
- schrijven van PostgreSQL-code  
- ondersteunen van UX-ontwerp  
- genereren en controleren van documentatie  

In plaats van deze logica telkens per project opnieuw te bouwen,  
plaatsen we deze **generieke, herbruikbare agents** in één centrale workspace: `agent-capabilities`.

---

## 3. Doelstelling

De doelstelling van deze workspace is:

> **Een herbruikbare verzameling generieke agents bieden,  
> die bijdragen aan een schaalbaar ecosysteem voor het realiseren van software met agents,  
> met continue aandacht voor kwaliteit en controle.**

Concreet betekent dit:

- agents zijn **stabiel, voorspelbaar en goed gedocumenteerd**  
- agents zijn **eenvoudig te koppelen** aan project-repo’s en andere agents  
- kwaliteit wordt bewaakt via **checks, tests en duidelijke regels**

---

## 4. Belangrijke uitgangspunten

- We zijn **beginnend** in het werken met agents,  
  maar **zeer ervaren** in IT, architectuur en softwareontwikkeling.  
  Daarom bouwen we dit stap voor stap uit.
- We beginnen met een **kleine set capabilities** (bijvoorbeeld converters en analyzers)  
  en breiden deze uit op basis van echte praktijkervaring.
- Elke agent:
  - heeft een **duidelijke, afgebakende taak**  
  - is **domeinonafhankelijk**  
  - wordt **formeel gedocumenteerd** (doel, input, output, beperkingen, voorbeelden)  
- Kwaliteit en onderhoudbaarheid gaan vóór snelheid:  
  liever een paar goede agents dan veel half-af agents.

---

## 5. Opzet van de workspace

### 5.1 Technische stack (voorlopig uitgangspunt)

- Repository: `agent-capabilities`  
- Taal en tooling worden afgestemd op de rest van het ecosysteem  
  (bijvoorbeeld markdown + YAML voor agentdefinities, PowerShell of Python voor scripts).  
- Structuur volgt vaste patronen, zoals:
  - `agents/` voor agent-configuraties  
  - `prompts/` voor prompts  
  - `desc-agents/` voor documentatie per agent  
  - `tests/` voor voorbeeldscenario’s  

*(De exacte stack wordt per iteratie aangescherpt.)*

### 5.2 Aanpak

- We beginnen met een **kleine, bruikbare set agents**  
  (bijvoorbeeld Markdown ↔ DOCX, Markdown ↔ XML, tekstvergelijking).  
- Voor elke nieuwe agent gelden minimaal:
  - een duidelijke beschrijving van doel en gedrag  
  - ten minste één voorbeeld van input en output  
  - basiscontroles op kwaliteit van de output  
- We verbeteren de workspace iteratief:
  - ervaringen uit projecten worden teruggevoerd naar `agent-capabilities`  
  - bestaande agents worden verbeterd voordat nieuwe worden toegevoegd  
  - waar mogelijk automatiseren we validatie en catalogusbeheer van agents
