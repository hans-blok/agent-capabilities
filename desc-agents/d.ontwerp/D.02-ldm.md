---
DVS-Positie: Stream D (Ontwerp) - D.02
Status: Actief
Contactpersoon: Enterprise Architectuur
Herziening: 20-12-2026
---

# Agent Beschrijving: D.02 - Logisch Datamodelleur (ldm)

## 1. Doel en Functionaliteit

De **Logisch Datamodelleur (ldm)** agent is een gespecialiseerde ontwerp-agent die verantwoordelijk is voor het opstellen en bewaken van het **logisch datamodel** binnen een domein.

Deze agent vertaalt het **conceptueel datamodel (uit fase B)** en de **feature-/proces-specificaties (uit fase C)** naar een robuust en consistent logisch datamodel. De kern van de taak is het waarborgen dat het model voldoet aan de **derde normaalvorm (3NF)**, waardoor redundantie en data-anomalieën worden geminimaliseerd.

### Kernfunctionaliteiten:
- **Vertaling**: Zet conceptuele modellen om in een gedetailleerd logisch model.
- **Normalisatie**: Past normalisatieregels (1NF, 2NF, 3NF) toe om de datakwaliteit te borgen.
- **Sleutel- en Relatiedefinitie**: Definieert primaire sleutels (PK), kandidaat-sleutels en foreign keys (FK) om de integriteit van de data te garanderen.
- **Constraint Vertaling**: Vertaalt business-regels naar logische data-constraints.
- **Naamgeving**: Zorgt voor consistente en duidelijke naamgeving van entiteiten en attributen.

## 2. DVS-Stream Positionering

Deze agent opereert primair in **Fase D - Ontwerp**.

- **Input**: Ontvangt input van Fase B (Architectuur), zoals het conceptueel datamodel, en Fase C (Specificatie), zoals requirements.
- **Output**: Levert een technologie-onafhankelijk logisch datamodel op dat als basis dient voor het fysieke database-ontwerp in Fase E (Bouw).

## 3. Input en Output

### Input
- **Conceptueel Datamodel**: Entiteiten, relaties en domeinbegrippen.
- **Specificaties**: Requirements, use cases, en procesbeschrijvingen.
- **Governance**: Architectuurprincipes, naamgevingsconventies en kwaliteitsregels.

### Output
- **Logisch Datamodel**: Een set van genormaliseerde entiteiten, attributen en relaties, gedocumenteerd in Markdown.
- **Documentatie**: Toelichting op de gemaakte ontwerpkeuzes en de toepassing van normalisatieregels.
- **Aannames**: Een expliciete lijst van gemaakte aannames (indien van toepassing).

## 4. Voorbeeld Use Case

**Scenario**: Een nieuw "Product Management" domein wordt ontwikkeld. De architect heeft een conceptueel model opgeleverd met de entiteiten `Product`, `Leverancier`, en `Categorie`.

1. **Input voor de agent**:
   - Het conceptuele model.
   - Een specificatie die beschrijft dat een product meerdere leveranciers kan hebben en in één categorie valt.

2. **Activatie**:
   ```
   @github /d.ldm
   ```
   Met de input als context.

3. **Output van de agent**:
   Een Markdown-document met het logische datamodel:

   ```markdown
   # Logisch Datamodel: Product Management

   ## Entiteiten

   ### Product
   - **ProductID** (PK)
   - ProductName
   - Beschrijving
   - Prijs
   - CategorieID (FK)

   ### Categorie
   - **CategorieID** (PK)
   - CategorieName

   ### Leverancier
   - **LeverancierID** (PK)
   - LeverancierName
   - Contactpersoon

   ### ProductLeverancier (Koppeltabel)
   - **ProductID** (PK, FK)
   - **LeverancierID** (PK, FK)
   - Inkoopprijs
   - Levertijd

   ## Relaties
   - `Categorie` 1-op-N `Product`
   - `Product` N-op-M `Leverancier` (via `ProductLeverancier`)
   ```

## 5. Beperkingen en Afhankelijkheden

- De agent ontwerpt **geen** fysieke databasemodellen (geen SQL DDL).
- De kwaliteit van de output is sterk afhankelijk van de kwaliteit van het aangeleverde conceptuele model en de specificaties.
- De agent is geen vervanging voor een data-architect, maar een hulpmiddel om het modelleringsproces te versnellen en te standaardiseren.
- De agent baseert zich op de regels en principes uit de charter: `std.agent.charter.d.ldm.md`.
