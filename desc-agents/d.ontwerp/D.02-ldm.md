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

## 5. Activatie en Aanroep

De LDM agent kan op verschillende manieren worden benaderd van buitenaf:

### 5.1 Via GitHub Copilot Chat
```
@github /d.ldm
```
Voeg het conceptuele datamodel en eventuele specificaties toe aan de context voordat je de agent activeert.

### 5.2 Via PowerShell Script
```powershell
.\agnt-cap-kit\scripts\d.ldm-realisatie.ps1 -InputFiles "cdm.md","requirements.md" -NormalizationLevel 3NF
```

**Parameters**:
- `-InputFiles`: Een of meerdere bronbestanden met CDM en/of specificaties (verplicht)
- `-OutputFile`: Pad voor output (standaard: `ldm.md`)
- `-ModelName`: Naam van het logische model
- `-NormalizationLevel`: `1NF`, `2NF`, of `3NF` (standaard: `3NF`)
- `-IncludeConstraints`: Documenteer business rule constraints (standaard: aan)
- `-IncludeVisualization`: Genereer ER-diagram in Mermaid (standaard: aan)
- `-NamingConvention`: `PascalCase`, `snake_case`, of `camelCase` (standaard: `PascalCase`)
- `-OutputFormat`: `Markdown`, `JSON`, `SQL`, of `All` (standaard: `Markdown`)
- `-ValidateModel`: Valideer het gegenereerde model
- `-DetectManyToMany`: Automatisch detecteren van N-op-M relaties (standaard: aan)

**Voorbeelden**:
```powershell
# Basis gebruik
.\d.ldm-realisatie.ps1 -InputFiles "cdm.md"

# Met validatie en alle output formaten
.\d.ldm-realisatie.ps1 -InputFiles "cdm.md","specs.md" -ValidateModel -OutputFormat All

# Snake_case naamgeving voor Python/PostgreSQL projecten
.\d.ldm-realisatie.ps1 -InputFiles "cdm.md" -NamingConvention snake_case
```

### 5.3 Via Prompt Template
Voor directe interactie met LLM-gebaseerde systemen:

```markdown
# Taak: Logisch Datamodel Realisatie

Rol: Je bent een Logisch Datamodelleur (Agent D.02)

Context:
[Voeg hier het conceptueel datamodel en/of specificaties toe]

Opdracht:
1. Analyseer het conceptuele datamodel en identificeer alle entiteiten
2. Pas normalisatie toe tot 3NF:
   - 1NF: Maak alle attributen atomair
   - 2NF: Elimineer partiële afhankelijkheden
   - 3NF: Elimineer transitieve afhankelijkheden
3. Definieer primaire sleutels (PK) voor elke entiteit
4. Identificeer en modelleer foreign keys (FK) voor relaties
5. Creëer koppeltabellen voor veel-op-veel relaties
6. Documenteer cardinaliteit (1-op-1, 1-op-N, N-op-M)
7. Genereer een gestructureerd LDM in Markdown
8. Voeg een ER-diagram toe in Mermaid

Output formaat: Markdown volgens de structuur uit sectie 3.

Normalisatie niveau: [1NF/2NF/3NF]
Naamgeving: [PascalCase/snake_case/camelCase]
```

### 5.4 Via API/Service Endpoint
Als de agent als service wordt gehost:

```bash
POST /api/agents/ldm/normalize
Content-Type: application/json

{
  "inputDocuments": [
    {
      "name": "conceptual-model.md",
      "content": "..."
    }
  ],
  "modelName": "Enterprise LDM",
  "normalizationLevel": "3NF",
  "namingConvention": "PascalCase",
  "outputFormat": "Markdown"
}
```

### 5.5 Integratievoorbeeld - Pipeline
Voor automatische verwerking in een CI/CD pipeline:

```yaml
# .github/workflows/ldm-generation.yml
name: Generate LDM
on:
  push:
    paths:
      - 'models/cdm/**'

jobs:
  generate-ldm:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Generate LDM
        run: |
          .\agnt-cap-kit\scripts\d.ldm-realisatie.ps1 `
            -InputFiles (Get-ChildItem models/cdm/*.md).FullName `
            -OutputFile "output/ldm.md" `
            -NormalizationLevel 3NF `
            -ValidateModel `
            -OutputFormat All
```

### 5.6 Integratie met CDM Agent
De LDM agent wordt vaak gebruikt in combinatie met de CDM agent (B.01):

```powershell
# Stap 1: Genereer CDM uit strategische documenten
.\agnt-cap-kit\scripts\b.cdm-realisatie.ps1 `
  -InputFiles "business-case.md","wet.md" `
  -OutputFile "cdm.md"

# Stap 2: Genereer LDM uit CDM
.\agnt-cap-kit\scripts\d.ldm-realisatie.ps1 `
  -InputFiles "cdm.md" `
  -OutputFile "ldm.md" `
  -NormalizationLevel 3NF `
  -ValidateModel
```

## 6. Normalisatie Regels

### 6.1 Eerste Normaalvorm (1NF)
- **Regel**: Alle attributen moeten atomair zijn
- **Actie**: Splits samengestelde attributen (bijv. Adres → Straat, Huisnummer, Postcode, Plaats)
- **Actie**: Elimineer herhalende groepen

### 6.2 Tweede Normaalvorm (2NF)
- **Regel**: Geen partiële afhankelijkheden van samengestelde sleutels
- **Actie**: Als een attribuut alleen afhankelijk is van een deel van de primaire sleutel, verplaats naar aparte tabel
- **Vereiste**: Model moet al voldoen aan 1NF

### 6.3 Derde Normaalvorm (3NF)
- **Regel**: Geen transitieve afhankelijkheden tussen niet-sleutelattributen
- **Actie**: Als attribuut B afhankelijk is van A, en C afhankelijk van B, verplaats C naar aparte tabel
- **Vereiste**: Model moet al voldoen aan 2NF

## 7. Beperkingen en Afhankelijkheden

- De agent ontwerpt **geen** fysieke databasemodellen (geen volledige SQL DDL met indexen, partities, etc.)
- SQL output is **indicatief** en bedoeld als startpunt voor database-ontwerp
- De kwaliteit van de output is sterk afhankelijk van de kwaliteit van het aangeleverde conceptuele model en de specificaties
- De agent is geen vervanging voor een data-architect, maar een hulpmiddel om het modelleringsproces te versnellen en te standaardiseren
- De agent baseert zich op de regels en principes uit de charter: `std.agent.charter.d.ldm.md`
- **Input dependency**: Vereist een conceptueel datamodel uit fase B of gedetailleerde specificaties uit fase C
