# Agent Charter Standard
*Normatief kader voor alle agent charters in het ecosysteem*

## Doel en positie
Dit document definieert **wat een geldig Agent Charter is** binnen het ecosysteem.  
Het beschrijft **structuur, verplichte onderdelen en verantwoordelijkheden**, maar **niet** het gedrag van een specifieke agent.

Dit is een **standaard** (rules abstraction) en hoort thuis in de *standards-repository*.

Alle concrete agent charters (capabilities) **MOETEN** aan dit document conformeren.

---

## Scope
### In scope
- Structuur en inhoud van agent charters
- Terminologie en vaste definities
- Verantwoordelijkheden en grenzen van agents
- Samenwerking tussen agents
- Relatie tot workspaces en charters

### Out of scope
- Implementatiedetails
- Prompt engineering
- Tooling- of platformkeuzes
- Concrete workflows of pipelines

---

## Definitie: Agent Charter
Een **Agent Charter** is een normatief document dat vastlegt:
- welk probleem een agent oplost
- welke verantwoordelijkheden hij heeft
- welke inputs en outputs hij accepteert
- welke aannames hij mag doen
- hoe hij samenwerkt met andere agents

Een agent **mag niet functioneren** zonder een geldig charter.

---

## Verplichte structuur van een Agent Charter
Elk agent charter **MOET** minimaal de volgende secties bevatten, in deze volgorde.

### 1. Identiteit
- **Agentnaam** (uniek binnen het ecosysteem)
- **Type**: Capability Agent | Constitutionele Agent | Supporting Agent
- **Eigenaar** (rol of team, geen persoon)
- **Status**: Experimental | Active | Deprecated

---

### 2. Doel en verantwoordelijkheid
- Heldere beschrijving van het doel van de agent
- Expliciete verantwoordelijkheid
- Wat de agent **oplevert aan waarde**

Formuleer dit in maximaal 5 zinnen.

---

### 3. Scope en grenzen
#### In scope
- Taken die deze agent expliciet uitvoert

#### Out of scope
- Taken die deze agent **niet** uitvoert
- Zaken die expliciet aan andere agents zijn gedelegeerd

---

### 4. Inputs
- Geaccepteerde inputvormen (artefacten, prompts, context)
- Vereiste voorkennis of aannames
- Verplichte en optionele inputs

Inputs moeten **technologie-agnostisch** zijn.

---

### 5. Outputs
- Artefacten die de agent produceert
- Vorm (bijv. markdown, diagram, structuur)
- Verwachte kwaliteitseisen

Outputs zijn **deterministisch** gegeven dezelfde input, tenzij expliciet anders vermeld.

---

### 6. Aannames en onzekerheden
- Maximaal 3 expliciete aannames
- Duidelijk gemarkeerd als aanname
- Geen impliciete aannames toegestaan

---

### 7. Samenwerking en afhankelijkheden
- Welke andere agents worden geconsumeerd
- Welke agents consumeren deze agent
- Volgorde en orkestratie (hoog niveau)

Geen circulaire afhankelijkheden zonder expliciete motivatie.

---

### 8. Regels en beperkingen
- Normatieve regels waaraan de agent zich moet houden
- Wat de agent **nooit** mag doen
- Escalatie- of stopcondities

Deze regels mogen niet strijdig zijn met hogere charters of de constitutie.

---

### 9. Conformiteit en validatie
- Hoe wordt vastgesteld dat de agent correct functioneert?
- Acceptatiecriteria (conceptueel)
- Eventuele validatie- of lintingmechanismen

---

### 10. Wijzigingsbeleid
- Hoe en wanneer mag dit charter wijzigen?
- Impact op bestaande workspaces of agents
- Versiebeheer (semantisch, conceptueel)

---

## Hiërarchie en autoriteit
De volgende hiërarchie is leidend:

1. Constitutie
2. Workspace Architecture Charter
3. Agent Charter Standard (dit document)
4. Individuele Agent Charters
5. Implementaties / prompts

Lagere niveaus **mogen hogere niveaus niet tegenspreken**.

---

## Verantwoordelijkheid
- Elke agent is verantwoordelijk voor **naleving van zijn eigen charter**
- Workspace Moeder-Agents mogen agents weigeren zonder geldig charter
- Afwijkingen moeten expliciet en gemotiveerd zijn

---

## Ontwerpprincipes
- Separation of concerns
- Process–rules abstraction
- Stabiliteit boven optimalisatie
- Expliciet boven impliciet
- Leesbaarheid boven volledigheid

---

## Slot
Dit document verandert zelden.  
Wijzigingen vereisen expliciete motivatie en brede impactanalyse.

> *Charters beschrijven intentie en verantwoordelijkheid; gedrag volgt daaruit.*

