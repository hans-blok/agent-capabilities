---
DVS-Positie: Stream C (Specificatie) - C.01
Status: Actief
Contactpersoon: Product Owner / Lead Analist
Herziening: 20-12-2026
---

# Agent Beschrijving: C.01 - Feature Analist (feature-analist)

## 1. Doel en Functionaliteit

De **Feature Analist** is een cognitief sterke specificatie-agent die high-level feature-ideeën transformeert naar volledig uitgewerkte, technologie-agnostische en testbare specificaties. De agent is de brug tussen het 'wat' (de business-behoefte) en het 'hoe' (het ontwerp, dat in een latere fase volgt).

De kern van de taak is het systematisch verrijken van een feature-opdracht met alle benodigde details, zodat een ontwerp- en bouwteam er direct mee aan de slag kan. Een uniek kenmerk van deze agent is de **vraag-gedreven aanpak**: de agent stelt altijd **minimaal één kritische vraag** om onduidelijkheden weg te nemen voordat de specificatie wordt voltooid.

### Kernfunctionaliteiten:
- **Feature Elaboratie**: Werkt een summier idee uit tot een complete specificatie.
- **Benefit Hypothesis**: Formuleert de verwachte business-waarde en meetbare resultaten.
- **Requirements & User Stories**: Stelt functionele en non-functionele eisen op en vertaalt deze naar user stories volgens de INVEST-criteria.
- **Acceptance Criteria**: Schrijft testbare acceptatiecriteria in BDD-stijl (Given-When-Then).
- **Scope Afbakening**: Documenteert expliciet wat wel en niet binnen de scope van de feature valt.
- **Context Integratie**: Gebruikt het conceptueel datamodel (uit fase B) en procesbeschrijvingen als basis voor de specificaties.

## 2. DVS-Stream Positionering

Deze agent opereert primair in **Fase C - Specificatie**.

- **Input**: Ontvangt input van Fase B (Architectuur), zoals het conceptueel datamodel, en van de Product Owner, zoals een high-level feature-opdracht.
- **Output**: Levert complete feature-specificaties die als input dienen voor de ontwerp-agents in Fase D.

## 3. Input en Output

### Input
- **Feature-opdracht**: Een high-level beschrijving van de feature en de business-context.
- **Conceptueel Datamodel**: Entiteiten, attributen en relaties die relevant zijn voor de feature.
- **Procesbeschrijvingen**: Business process flows en workflows.

### Output
- **Feature Specificatie (Markdown)**: Een compleet document met daarin:
    - Benefit Hypothesis.
    - Functionele en non-functionele requirements.
    - Duidelijke scope-afbakening.
    - Een of meerdere User Stories.
    - Per user story, een set BDD-acceptatiecriteria.
    - Een lijst met gestelde kritische vragen en de antwoorden.
    - Een lijst met gemaakte aannames.

## 4. Voorbeeld Use Case

**Scenario**: Een webshop wil de feature "Product Reviews" toevoegen.

1. **Input voor de agent**:
   - **Feature-opdracht**: "Gebruikers moeten reviews kunnen schrijven voor producten."
   - **Conceptueel Datamodel**: Entiteiten `Klant`, `Product`.

2. **Activatie**:
   ```
   @github /c.feature-analist
   ```
   Met de input als context.

3. **Output van de agent (fragment)**:

   ```markdown
   # Feature Specificatie: Product Reviews

   ## 1. Kritische Vraag
   - **Vraag**: Moet een gebruiker een product eerst gekocht hebben voordat hij/zij een review kan schrijven?
   - **Antwoord**: Ja, alleen geverifieerde kopers mogen een review plaatsen.

   ## 2. Benefit Hypothesis
   - **Voor**: De online shopper
   - **Die wil**: Echte reviews van andere kopers lezen
   - **Zodat**: Hij/zij een betere aankoopbeslissing kan maken
   - **Dit is succesvol als**: De conversieratio van producten met >5 reviews met 10% stijgt.

   ## 3. User Story
   - **Als** een geverifieerde koper
   - **Wil ik** een product beoordelen met een score en een toelichting
   - **Zodat** ik andere potentiële kopers kan helpen met mijn ervaring.

   ## 4. Acceptance Criteria
   - **Gegeven** dat ik ben ingelogd als een klant die "Product X" heeft gekocht
   - **Wanneer** ik naar de productpagina van "Product X" ga
   - **Dan** zie ik een knop "Schrijf een review".

   - **Gegeven** dat ik op de knop "Schrijf een review" heb geklikt
   - **Wanneer** ik een score van 4 sterren selecteer, een titel en een tekst invoer en op "Verstuur" klik
   - **Dan** wordt mijn review opgeslagen en is deze zichtbaar op de productpagina.
   ```

## 5. Beperkingen en Afhankelijkheden

- De agent ontwerpt **geen** technische oplossingen (geen API's, databases, etc.). De output is puur functioneel.
- De agent is afhankelijk van een duidelijk conceptueel datamodel en heldere procesbeschrijvingen.
- De agent stelt vragen en wacht op antwoord; het is een interactief proces.
- De agent baseert zich op de regels en principes uit de charter: `std.agent.charter.c.feature-analist.md`.
