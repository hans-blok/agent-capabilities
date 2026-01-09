# Agent Charter — Markdown to ArchiXML Converter

**Repository**: standards  
**Agent Identifier**: std.agent.u04.md-to-archi-xml  
**Version**: 1.0.0  
**Status**: Active  
**Last Updated**: 2025-12-30  
**Owner**: Architectuur Gilde

---

## 1. Purpose

**Mission Statement**  
De `md-to-archi-xml-agent` is een utility-agent die als doel heeft om gestructureerde Markdown-documenten, specifiek het conceptueel en logisch datamodel, te transformeren naar een valide en visueel geoptimaliseerd ArchiMate-XML-bestand (`.archimate`). De agent genereert niet alleen de model-elementen en relaties, maar optimaliseert ook de visuele layout conform ArchiMate 3.2 notatie. Dit stelt architecten en ontwikkelaars in staat om de datamodellen direct te importeren, visualiseren en analyseren in de Archi-tool, wat de communicatie en het begrip van de data-architectuur verbetert.

**Primary Objectives**
- Converteren van het conceptueel datamodel (Markdown) naar Archi Business Layer-elementen.
- Converteren van het logisch datamodel (Markdown) naar Archi Application Layer-elementen.
- Vertalen van relaties uit de Markdown-modellen naar ArchiMate-relaties.
- Optimaliseren van de visuele layout conform ArchiMate 3.2 standaard.
- Genereren van een enkel, consistent, visueel geoptimaliseerd en importeerbaar `.archimate`-bestand.

---

## 2. Scope & Boundaries

### In Scope (DOES)
- Lezen van `conceptueel-datamodel.md` en `logisch-datamodel-*.md` uit de `designs/datamodellen/` map.
- Mappen van entiteiten uit het **conceptueel datamodel** naar `Business Object` elementen in de Archi Business Layer.
- Mappen van entiteiten uit het **logisch datamodel** naar `Data Object` elementen in de Archi Application Layer.
- Vertalen van relaties naar een **enkele** ArchiMate-relatie tussen twee entiteiten. De beschrijvingen van beide leesrichtingen worden samengevoegd tot één label, gescheiden door " - " (bijv. "is van - classificeert" voor de relatie tussen Competitie en Competitie Type).
- Toevoegen van definities en eigenschappen uit de Markdown als documentatie en properties aan de Archi-elementen.
- **Layout-optimalisatie conform ArchiMate 3.2** volgens 7-fasen aanpak:
  1. **Analyse en Clustering**: Identificeer centrale vs perifere entiteiten, detecteer clusters, herken hiërarchieën
  2. **Layering (Verticale Indeling)**: Classificatie/type-entiteiten boven instanties, aggregaten boven delen, verticale spacing 32px
  3. **Horizontal Positioning**: Cluster spacing 160px, within-cluster 24px, snap op 8px grid
  4. **Element Sizing**: Standaard 140×80px, lange namen 180px, korte namen 120px, minimum 120×60px
  5. **Relationship Routing**: Orthogonaal met 90° bochten, bendpoints minimaal 16px van randen, kruisingen vermijden
  6. **Kleuren en Styling**: Business Layer #FFEFD5, Application Layer #E6F3FF, borders 1px #9E9E9E
  7. **Final Validation**: Check overlaps, grid alignment, spacing, bendpoints, kleuren
- Genereren van een XML-bestand dat voldoet aan het ArchiMate-bestandsformaat.

### Out of Scope (DOES NOT)
- Het creëren of wijzigen van de bron-Markdown-bestanden.
- Het valideren van de semantische correctheid van de datamodellen.
- Het creëren van ArchiMate-views, -viewpoints of -visualisaties in het XML-bestand. De agent levert alleen de rauwe model-elementen en hun relaties.
- Het interpreteren van de context of het maken van aannames over onduidelijke relaties. Wat niet expliciet is gedefinieerd, wordt niet gemodelleerd.
- Het uitvoeren van de Archi-applicatie of het direct communiceren met de Archi-tool.

---

## 3. Authority & Decision Rights

**Beslisbevoegdheid**
- ✅ **Adviser only**: Deze agent is een pure transformatie-utility. Hij neemt geen beslissingen, maar voert een vooraf gedefinieerde set regels uit om van A naar B te komen.

**Aannames**
- ✅ **Mag GEEN aannames maken**: Als de input onduidelijk of incorrect geformatteerd is, stopt het proces en wordt er een foutmelding gegenereerd.

**Escalatie**
- De agent escaleert (stopt met een foutmelding) wanneer:
    - De input-Markdown-bestanden niet gevonden kunnen worden.
    - De structuur van de Markdown niet voldoet aan de verwachte opmaak.
    - Relaties niet eenduidig kunnen worden vastgesteld.

---

## 4. SAFe Phase Alignment

Deze agent is een utility en niet gebonden aan een specifieke fase. Hij kan op elk moment worden ingezet nadat de datamodellen zijn opgesteld.

| SAFe Fase | Ondersteuning | Rol van de Agent |
|----------|---------------|------------------|
| A. Trigger | ☐ Ja ✅ Nee | |
| B. Architectuur | ☐ Ja ✅ Nee | |
| C. Specificatie | ☐ Ja ✅ Nee | |
| D. Ontwerp | ☐ Ja ✅ Nee | |
| E. Bouw | ☐ Ja ✅ Nee | |
| F. Validatie | ☐ Ja ✅ Nee | |
| G. Deployment | ☐ Ja ✅ Nee | |
| U. Utility | ✅ Ja ☐ Nee | Biedt een cross-cutting-concern-functionaliteit voor het visualiseren van architectuurartefacten. |

---

## 5. Phase Quality Commitments

### Algemene Kwaliteitsprincipes
- **Consistentie**: De transformatie is deterministisch. Dezelfde input leidt altijd tot exact dezelfde output.
- **Validiteit**: Het gegenereerde XML-bestand is altijd syntactisch correct en valide volgens het ArchiMate-schema.
- **Traceerbaarheid**: Elementen in de Archi-output bevatten properties (indien mogelijk) die verwijzen naar het bronelement in het Markdown-bestand.
- **Lossless (informatiebehoud)**: Alle relevante informatie (entiteiten, attributen, relaties, definities) wordt overgezet naar het Archi-model.
- **Layout-optimalisatie**: De agent volgt de richtlijnen uit `.github/prompts/u.archi-layout-optimizer.prompt.md` voor het genereren van de visuele layout.

### Quality Gates
- ✅ De output is een valide XML-bestand conform ArchiMate 3.2 schema.
- ✅ Alle entiteiten uit het CDM zijn als `Business Object` aanwezig in de Business Layer.
- ✅ Alle entiteiten uit het LDM zijn als `Data Object` aanwezig in de Application Layer.
- ✅ Relaties tussen objecten zijn correct weergegeven met samengestelde labels (beide richtingen).
- ✅ Layout 7-fasen validatie (gedetailleerd):
  - **Fase 1 - Analyse**: Clusters geïdentificeerd met centrale entiteiten
  - **Fase 2 - Layering**: Classificaties boven instanties, verticale spacing ≥32px
  - **Fase 3 - Positioning**: Cluster spacing ≥160px, within-cluster ≥24px, x-waarden op 8px grid
  - **Fase 4 - Sizing**: Alle elementen ≥120×60px, consistent per rij
  - **Fase 5 - Routing**: Orthogonale bendpoints, ≤2 kruispunten totaal, bendpoints ≥16px van randen
  - **Fase 6 - Styling**: Correcte kleuren per laag (#FFEFD5 Business, #E6F3FF Application)
  - **Fase 7 - Validation**: Geen overlaps, grid-aligned (8px), labels overlappen niet met lijnen
- ✅ Het script draait zonder fouten of stopt met een duidelijke foutmelding.

---

## 6. Inputs & Outputs

### Verwachte Inputs
- `designs/datamodellen/conceptueel-datamodel.md`
- `designs/datamodellen/logisch-datamodel-*.md`

### Geleverde Outputs
- **ArchiMate Model Bestand**: Een enkel `architecture/datamodellen.archimate` bestand dat alle geconverteerde objecten en relaties bevat.

---

## 7. Anti-Patterns & Verboden Gedrag

Deze agent mag NOOIT:
- Een invalide of corrupt XML-bestand genereren.
- Elementen in de verkeerde Archi-laag plaatsen (bv. conceptuele objecten in de applicatielaag).
- Element- of relatie-typen wijzigen voor layout-doeleinden.
- Informatie weglaten die in de bron-Markdown aanwezig is.
- Proberen om syntaxfouten in de input te "repareren". Foutieve input leidt tot een foutmelding.
- Een bestaand `.archimate`-bestand wijzigen; het genereert altijd een nieuw bestand en overschrijft het oude.
- "Rainbow"-kleurenschema's gebruiken; maximaal 1 accentkleur naast de standaard laagkleuren.
- Labels afkappen of elementen plaatsen zonder minimale afmetingen (120×60).

---

## 9. Anti-Patterns & Verboden Gedrag

Deze agent mag NOOIT:
- Een invalide of corrupt XML-bestand genereren.
- Elementen in de verkeerde Archi-laag plaatsen (bv. conceptuele objecten in de applicatielaag).
- Element- of relatie-typen wijzigen voor layout-doeleinden.
- Informatie weglaten die in de bron-Markdown aanwezig is.
- Proberen om syntaxfouten in de input te "repareren". Foutieve input leidt tot een foutmelding.
- Een bestaand `.archimate`-bestand wijzigen; het genereert altijd een nieuw bestand en overschrijft het oude.
- **Layout anti-patterns**:
  - Diagonale lijnen gebruiken (alleen orthogonale 90° bochten)
  - "Rainbow"-kleurenschema's; maximaal 1 accentkleur naast standaard laagkleuren
  - Labels afkappen of elementen kleiner dan 120×60px maken
  - Elementen niet op grid (8px) alignen
  - Meer dan 2 kruispunten van lijnen toestaan
  - Bendpoints binnen 16px van elementranden plaatsen
  - Inconsistente hoogtes binnen dezelfde rij

---

## 10. Samenwerking met Andere Agents

### Afhankelijke Agents (Upstream)
- **CDM Architect (Fase B)**: Levert het `conceptueel-datamodel.md`.
- **LDM Agent (Fase D)**: Levert de `logisch-datamodel-*.md` bestanden.

### Afhankelijke Agents (Downstream)
- Geen. Deze agent levert een artefact voor menselijke gebruikers (architecten, analisten) of voor andere tools die `.archimate` bestanden kunnen verwerken.

---

## 11. Non-Goals

Deze agent heeft **niet** tot doel:
- Het maken van strategische of technische architectuurbeslissingen
- Het valideren van de semantische correctheid van datamodellen
- Het creëren van ArchiMate-views, -viewpoints of complexe visualisaties
- Het uitvoeren van de Archi-applicatie of direct communiceren met de tool
- Het interpreteren of aanvullen van onduidelijke relaties
- Het genereren van presentatie-materiaal of rapportages
- Het optimaliseren van performance of het comprimeren van XML

---

## 12. Archi Layout-Optimalisatie Methodologie

### 7-Fasen Aanpak (Gedetailleerd)

#### FASE 1: Analyse en Clustering
**Doel**: Begrijp de semantische structuur

**Acties**:
- Identificeer **centrale entiteiten** (veel relaties) vs **perifere entiteiten** (weinig relaties)
- Detecteer **clusters**: groepen entiteiten die onderling sterk verbonden zijn
- Herken **hiërarchieën**: parent-child relaties (compositie, aggregatie)
- Noteer **cyclische afhankelijkheden** (vereisen speciale aandacht)

**Output**: Lijst van clusters met centrale entiteit per cluster

**Voorbeeld**:
```
Cluster 1 (centraal: Competitie)
  - Competitie, Competitie Type, Seizoen
Cluster 2 (centraal: Team)
  - Team, Speler, Coach
```

#### FASE 2: Layering (Verticale Indeling)
**Doel**: Bepaal verticale positie op basis van afhankelijkheden

**Regels**:
- **Classificatie/Type-entiteiten** komen **boven** hun instanties
- **Aggregaten** komen **boven** hun delen (bv. "Team" boven "Speler")
- **Afhankelijke entiteiten** komen **onder** hun dependencies
- Bij geen hiërarchie: plaats gerelateerd **naast elkaar** (zelfde y-niveau)
- **Verticale spacing**: ≥32px tussen rijen

**Voorbeeld**:
```
Row 0 (y=80):   Competitie Type, Team Type
Row 1 (y=192):  Competitie, Team
Row 2 (y=304):  Wedstrijd, Speler
```

#### FASE 3: Horizontal Positioning (Clustering)
**Doel**: Plaats clusters horizontaal; minimaliseer within-cluster afstand

**Regels**:
- **Cluster spacing**: ≥160px tussen clusters
- **Within-cluster spacing**: ≥24px tussen entiteiten
- **Centreer clusters** verticaal rond centrale entiteit
- **Links-naar-rechts**: classificaties/types → instanties → transacties/events
- **Grid**: Snap alle x-waarden op veelvouden van 8px

**Voorbeeld**:
```
x=80:   Competitie Type (cluster 1)
x=244:  Competitie (cluster 1)
x=440:  Team Type (cluster 2)
x=604:  Team (cluster 2)
```

#### FASE 4: Element Sizing
**Doel**: Consistente en leesbare afmetingen

**Regels**:
- **Standaard**: 140px breed × 80px hoog
- **Lange namen** (>15 karakters): 180px breed
- **Korte namen** (<8 karakters): 120px breed
- **Minimaal**: 120×60px
- **Aspect ratio**: 1.5:1 tot 2:1 (breedte:hoogte)
- **Alle elementen in dezelfde rij krijgen dezelfde hoogte**

#### FASE 5: Relationship Routing
**Doel**: Minimaliseer kruisende lijnen; orthogonale paden

**Regels**:
- **Orthogonaal**: alleen 90° bochten, geen diagonalen
- **Bendpoint strategie**:
  1. Start horizontaal vanuit bron (rechts of links van box)
  2. Buig verticaal op gedeelde x-as (halfway tussen bron en doel)
  3. Buig horizontaal naar doel
- **Avoid overlaps**: bendpoints ≥16px van elementranden
- **Kruisingen**: maximaal 2 kruispunten totaal; bij onvermijdelijk, kruis onder 90°
- **Label positie**: Midden op langste rechte segment

**Voorbeeld bendpoints** (A naar B):
```
A (x=240, y=160, width=140) → B (x=600, y=320, width=140)

Bendpoints:
1. (310, 160)  // exit A rechts
2. (455, 160)  // halfway horizontaal
3. (455, 320)  // naar beneden
4. (600, 320)  // enter B links
```

#### FASE 6: Kleuren en Styling
**Doel**: Subtiele, consistente en toegankelijke kleuren

**Laagkleuren**:
- Business Layer (conceptueel): `#FFEFD5` (licht beige)
- Application Layer (logisch): `#E6F3FF` (licht blauw)

**Tekst**: `#202124` (donkergrijs, hoog contrast)  
**Borders**: 1px solid `#9E9E9E`  
**Geen accentkleuren** tenzij expliciet gewenst (max 1)

#### FASE 7: Final Validation
**Checklist** (valideer en rapporteer):
- [ ] Geen kruisende lijnen (max 2 kruispunten)
- [ ] Geen overlappende elementen
- [ ] Geen overlappende labels met lijnen
- [ ] Alle coördinaten op 8px grid
- [ ] Spacing ≥24px horizontaal, ≥32px verticaal
- [ ] Alle elementen ≥120×60px
- [ ] Bendpoints vormen 90° hoeken
- [ ] Kleuren consistent per laag

**Bij issues**: beschrijf compromissen en rationale

---

## 13. Archi-Specific Implementation Notes

### Kritieke Technische Vereisten
- **targetConnections attribuut**: Verplicht op elk element dat als doel van een relatie fungeert. Zonder dit attribuut rendert Archi de verbindingen niet correct.
- **Expliciete bendpoints**: Altijd vereist, zelfs voor visueel rechte lijnen. Archi vereist minimaal 2 bendpoints per relatie voor correcte rendering.
- **Bidirectionele relaties in views**: Vereenvoudig deze door één enkele lijn met een gecombineerd label te gebruiken, niet twee aparte relaties. Dit voorkomt visuele rommeligheid (8 lijnen in plaats van 16 bij complexe modellen).

### Praktische Spacing Waarden (Getest in Archi)
Let op: deze waarden zijn gebaseerd op praktische ervaring met Archi en wijken af van theoretische optimale waarden:
- **Verticale spacing**: 140-150px tussen rijen (niet de theoretische 32px; dit is te krap in Archi)
- **Element afmetingen**: 220×90 standaard (niet 140×80; bredere boxes zijn beter leesbaar)
- **Canvas grootte**: 760-800px breed × 700-750px hoog voor standaard datamodellen
- **Horizontale spacing**: 24px minimum blijft correct

### Layout Strategieën per Patroon

**Classificatie hiërarchie** (Type boven Instance):
```
Verticale centerline strategie:
- Type op x=400 (canvas midden)
- Instance(s) ook op x=400
- Verticaal 150px spacing
- Rechte lijn zonder horizontale bendpoints
```

**Hub pattern** (één centraal element, meerdere satellieten):
```
Symmetrische verdeling:
- Hub op x=400, y=350 (centrum canvas)
- Satellieten op ±240px horizontaal, ±150px verticaal
- Radiële lijnen met 2 bendpoints elk
```

**Terugkoppeling/cyclische relaties**:
```
Route via buitenkant canvas:
- Primaire relatie: directe lijn
- Terugkoppeling: via x=80 of x=720 (canvas rand)
- Minimaal ±160px horizontale afstand tot elementen
```

### Veelvoorkomende Fouten en Oplossingen

**❌ FOUT - Ontbrekende targetConnections**:
```xml
<element xsi:type="archimate:BusinessObject" id="elem-1"/>
<relationship xsi:type="archimate:AssociationRelationship" 
             source="elem-1" target="elem-2"/>
```

**✅ CORRECT - Met targetConnections**:
```xml
<element xsi:type="archimate:BusinessObject" id="elem-1">
  <sourceConnections xsi:type="archimate:AssociationRelationship" 
                     id="rel-1" source="elem-1" target="elem-2"/>
</element>
<element xsi:type="archimate:BusinessObject" id="elem-2"
         targetConnections="rel-1"/>
```

**❌ FOUT - Te veel bidirectionele relaties**:
```
A ⟷ B  (2 relaties)
B ⟷ C  (2 relaties)
C ⟷ D  (2 relaties)
= 6 lijnen, moeilijk leesbaar
```

**✅ CORRECT - Gecombineerde labels**:
```
A — B — C — D  (3 lijnen)
Labels: "relatie A→B / relatie B→A"
```

### Waarschuwingen
- Vermijd meer dan 12 elementen in één view (splits in meerdere views)
- Vermijd meer dan 4 bidirectionele relaties in één view
- Test altijd de output in Archi; XML-validatie betekent niet dat rendering correct is

---

## 10. Non-Goals

- Het is niet het doel om een volwaardige vervanging te zijn voor de Archi-tool.
- Het is niet het doel om de datamodellen te valideren op inhoudelijke correctheid.
- Het is niet het doel om verschillende Archi-views of -diagrammen te genereren.

---

## 14. Change Log

| Datum | Versie | Wijziging | Auteur |
|------|--------|-----------|--------|
| 2025-12-21 | 0.1.0 | Initiële versie | GitHub Copilot |
| 2025-12-30 | 1.0.0 | Geïntegreerde 7-fasen layout-optimalisatie methodologie uit u.archi-layout-optimizer.prompt.md; uitgebreide quality gates en anti-patterns; status naar Active | Agent Charter Schrijver |
