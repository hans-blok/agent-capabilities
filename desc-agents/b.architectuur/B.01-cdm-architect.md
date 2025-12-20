---
DVS-Positie: Stream B (Architectuur) - B.01
Status: Actief
Contactpersoon: Architectuur Gilde
Herziening: 20-12-2026
---

# Agent Beschrijving: B.01 - Conceptueel Datamodel Architect (cdm-architect)

## 1. Doel en Functionaliteit

De **Conceptueel Datamodel Architect (cdm-architect)** is een gespecialiseerde architectuur-agent die verantwoordelijk is voor het opstellen van een helder, stabiel en technologie-onafhankelijk **conceptueel datamodel (CDM)**.

Deze agent vertaalt strategische documenten zoals business cases, beleidsstukken en wettelijke kaders naar een fundamenteel datamodel. Het CDM legt de kern-bedrijfsconcepten (entiteiten), hun eigenschappen (attributen) en hun onderlinge relaties vast. Het dient als een **gedeelde taal** tussen business en IT.

Een cruciale taak van deze agent is het borgen van **traceerbaarheid**: data-elementen moeten expliciet herleidbaar zijn naar hun bron, zoals een wetsartikel of een beleidsregel.

### Kernfunctionaliteiten:
- **Analyse**: Leest en interpreteert strategische en normatieve documenten.
- **Modellering**: Identificeert en definieert kernentiteiten, attributen en relaties.
- **Documentatie**: Genereert een conceptueel datamodel in Markdown, inclusief definities en bronverwijzingen.
- **Visualisatie**: Maakt een visuele representatie van het model met behulp van Mermaid-syntax.

## 2. DVS-Stream Positionering

Deze agent opereert primair in **Fase B - Architectuur**.

- **Input**: Ontvangt input uit Fase A (Trigger), zoals business cases en project charters.
- **Output**: Levert het conceptuele datamodel dat als fundering dient voor Fase C (Specificatie) en Fase D (Ontwerp).

## 3. Input en Output

### Input
- **Strategische documenten**: Project charters, business cases, beleidsdocumenten.
- **Normatieve kaders**: Relevante wet- en regelgeving.
- **Domeinkennis**: Beschrijvingen of interviews met experts.

### Output
- **Conceptueel Datamodel (`datamodel.md`)**:
    - Een lijst van entiteiten met heldere definities.
    - Per entiteit, een lijst van attributen met definities, conceptuele datatypes (bv. 'Tekst', 'Datum') en **bronverwijzingen**.
    - Een beschrijving van de relaties tussen de entiteiten.
    - Een Mermaid-diagram voor visualisatie.

## 4. Voorbeeld Use Case

**Scenario**: De overheid introduceert een nieuwe wet "Digitale Toegankelijkheid" die eisen stelt aan publieke websites.

1. **Input voor de agent**:
   - De volledige wettekst van de "Digitale Toegankelijkheid".
   - Een intern beleidsdocument dat de implementatie van deze wet beschrijft.

2. **Activatie**:
   ```
   @github /b.cdm-architect
   ```
   Met de wettekst en het beleidsdocument als context.

3. **Output van de agent**:
   Een Markdown-document `datamodel.md` met de volgende inhoud:

   ```markdown
   # Conceptueel Datamodel: Digitale Toegankelijkheid

   ## Entiteiten

   ### Website
   - **Definitie**: Een publiek toegankelijke online dienst van de organisatie.
   - **Attributen**:
     - **Naam**: De officiële naam van de website. (Type: Tekst)
     - **URL**: De primaire URL van de website. (Type: Tekst)
     - **Status Toegankelijkheid**: De huidige conformiteitsstatus. (Type: Tekst, Bron: Wet Digitale Toegankelijkheid, Art. 5, lid 2)

   ### Toegankelijkheidsverklaring
   - **Definitie**: Een officieel document dat de toegankelijkheidsstatus van een website beschrijft.
   - **Attributen**:
     - **Datum Publicatie**: De datum waarop de verklaring is gepubliceerd. (Type: Datum, Bron: Wet Digitale Toegankelijkheid, Art. 7)
     - **Versie**: Het versienummer van de verklaring. (Type: Getal)

   ## Relaties
   - Een `Website` heeft één-op-veel `Toegankelijkheidsverklaringen`.

   ## Visualisatie
   ```mermaid
   graph TD;
       Website -->|heeft| Toegankelijkheidsverklaring;
   ```
   ```

## 5. Beperkingen en Afhankelijkheden

- De agent ontwerpt **geen** logische of fysieke datamodellen. Technische details zoals keys en indexen zijn buiten scope.
- De kwaliteit van de output is direct afhankelijk van de duidelijkheid en volledigheid van de aangeleverde brondocumenten.
- De agent is een `Recommender`: hij doet voorstellen voor het model. De finale goedkeuring ligt bij een menselijke architect.
- De agent baseert zich op de regels en principes uit de charter: `std.agent.charter.b.cdm-architect.md`.
