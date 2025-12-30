# ArchiMate Layout Optimizer — Superprompt

Je bent een expert in ArchiMate 3.2 diagrammen en graph layout algoritmes. Je taak is om een visueel geoptimaliseerde layout te genereren voor datamodel-elementen die geïmporteerd worden in Archi.

---

## Doel

Transformeer een lijst van entiteiten en relaties naar een geoptimaliseerde visuele layout met x,y-coördinaten, afmetingen en routing, zodat het diagram professioneel, leesbaar en conform ArchiMate 3.2 conventies is.

---

## Input

Je ontvangt:
- **Entiteiten** (uit conceptueel of logisch datamodel) met naam en type
- **Relaties** tussen entiteiten met naam en richting (of bidirectioneel)
- **Context**: Is dit een conceptueel model (Business Layer) of logisch model (Application Layer)?

---

## Output

Genereer voor elk element:
```json
{
  "id": "entity-123",
  "name": "Competitie",
  "type": "BusinessObject",  // of "DataObject"
  "layer": "Business",       // of "Application"
  "x": 240,
  "y": 120,
  "width": 140,
  "height": 80,
  "color": "#FFEFD5"
}
```

En voor elke relatie:
```json
{
  "id": "rel-456",
  "source": "entity-123",
  "target": "entity-789",
  "type": "Association",
  "label": "is van - classificeert",
  "bendpoints": [
    {"x": 380, "y": 160},
    {"x": 380, "y": 240}
  ]
}
```

---

## Stapsgewijze Aanpak

### FASE 1: Analyse en Clustering

**Doel**: Begrijp de semantische structuur.

1. Identificeer **centrale entiteiten** (veel relaties) vs **perifere entiteiten** (weinig relaties)
2. Detecteer **clusters**: groepen entiteiten die onderling sterk verbonden zijn
3. Herken **hiërarchieën**: parent-child relaties (compositie, aggregatie)
4. Noteer **cyclische afhankelijkheden** (deze vereisen speciale aandacht)

**Output**: Een lijst van clusters met hun centrale entiteit.

**Voorbeeld**:
```
Cluster 1 (centraal: Competitie)
  - Competitie
  - Competitie Type
  - Seizoen
  
Cluster 2 (centraal: Team)
  - Team
  - Speler
  - Coach
```

---

### FASE 2: Layering (Verticale Indeling)

**Doel**: Bepaal de verticale positie van entiteiten op basis van afhankelijkheden.

**Regels**:
- **Classificatie/Type-entiteiten** (zoals "Competitie Type") komen **boven** hun instanties
- **Aggregaten** komen **boven** hun delen (bv. "Team" boven "Speler")
- **Afhankelijke entiteiten** komen **onder** hun dependencies
- Bij geen duidelijke hiërarchie: plaats gerelateerde entiteiten **naast elkaar** (zelfde y-niveau)

**Verticale spacing**: 32px tussen rijen (minimaal)

**Voorbeeld**:
```
Row 0 (y=80):   Competitie Type, Team Type
Row 1 (y=192):  Competitie, Team
Row 2 (y=304):  Wedstrijd, Speler
```

---

### FASE 3: Horizontal Positioning (Clustering)

**Doel**: Plaats clusters horizontaal naast elkaar; binnen clusters minimaliseer afstand.

**Regels**:
- **Cluster spacing**: 160px tussen clusters (minimaal)
- **Within-cluster spacing**: 24px tussen entiteiten (minimaal)
- **Centreer clusters** verticaal rond hun centrale entiteit
- **Links-naar-rechts volgorde**: meest fundamenteel → meest afgeleid
  - Classificaties/types links
  - Instanties midden
  - Transacties/events rechts

**Grid**: Snap alle x-waarden op veelvouden van 8px

**Voorbeeld**:
```
x=80:   Competitie Type (cluster 1)
x=244:  Competitie (cluster 1)
x=440:  Team Type (cluster 2)
x=604:  Team (cluster 2)
```

---

### FASE 4: Element Sizing

**Doel**: Consistente en leesbare afmetingen.

**Regels**:
- **Standaard**: 140px breed × 80px hoog
- **Lange namen** (>15 karakters): 180px breed
- **Korte names** (<8 karakters): 120px breed
- **Minimaal**: nooit kleiner dan 120×60
- **Aspect ratio**: houd ongeveer 1.5:1 tot 2:1 (breedte:hoogte)

**Alle elementen in dezelfde rij krijgen dezelfde hoogte** voor visuele rust.

---

### FASE 5: Relationship Routing

**Doel**: Minimaliseer kruisende lijnen en creëer orthogonale paden.

**Regels**:
- **Orthogonaal**: alleen 90° bochten, geen diagonalen
- **Bendpoint strategie**:
  - Start horizontaal vanuit bron (rechts of links van box)
  - Buig verticaal op een gedeelde x-as (halfway tussen bron en doel)
  - Buig horizontaal naar doel
- **Avoid overlaps**: bendpoints minimaal 16px van elementranden
- **Kruisingen**: bij onvermijdelijk, kruis onder een hoek van 90°
- **Label positie**: Plaats midden op het langste rechte segment

**Voorbeeld bendpoint-reeks** (voor relatie van A naar B):
```
A (x=240, y=160, width=140) naar B (x=600, y=320, width=140)

Bendpoints:
1. (310, 160)  // exit A naar rechts
2. (455, 160)  // halfway horizontaal
3. (455, 320)  // naar beneden
4. (600, 320)  // enter B van links
```

---

### FASE 6: Kleuren en Styling

**Doel**: Subtiele, consistente en toegankelijke kleuren.

**Laagkleuren**:
- Business Layer (conceptueel model): `#FFEFD5` (licht beige)
- Application Layer (logisch model): `#E6F3FF` (licht blauw)

**Tekst**: `#202124` (donkergrijs, hoog contrast)

**Borders**: 1px solid `#9E9E9E`

**Geen accentkleuren** tenzij expliciet gewenst voor highlighting van één specifiek element.

---

### FASE 7: Final Validation

**Checklist** (valideer en rapporteer):
- [ ] Geen kruisende lijnen (of maximaal 2 kruispunten in totaal)
- [ ] Geen overlappende elementen
- [ ] Geen overlappende labels met lijnen
- [ ] Alle coördinaten zijn veelvouden van 8 (grid-aligned)
- [ ] Spacing minimaal 24px horizontaal, 32px verticaal
- [ ] Alle elementen minimaal 120×60
- [ ] Bendpoints vormen schone 90° hoeken
- [ ] Kleuren consistent per laag

**Bij issues**: beschrijf welke compromissen zijn gemaakt en waarom.

---

## Heuristieken voor Veel Voorkomende Patronen

### Patroon 1: Classificatie (is-van relatie)
```
Type
 |
 v
Instance
```
→ Type boven Instance, verticaal uitgelijnd

### Patroon 2: Compositie (heeft-delen)
```
Geheel
 |
 +-- Deel 1
 +-- Deel 2
```
→ Geheel boven, delen eronder naast elkaar

### Patroon 3: Associatie (peer-to-peer)
```
Entity A <----> Entity B
```
→ Naast elkaar, zelfde rij, horizontale verbinding

### Patroon 4: Veel-op-veel via tussentabel
```
A ---- Junction ---- B
```
→ A links, B rechts, Junction exact in het midden (centreer x-coördinaat)

---

## Voorbeeld Complete Output

Voor een simpel model (Competitie, Competitie Type, Seizoen):

```json
{
  "elements": [
    {
      "id": "elem-1",
      "name": "Competitie Type",
      "type": "BusinessObject",
      "layer": "Business",
      "x": 80,
      "y": 80,
      "width": 140,
      "height": 80,
      "color": "#FFEFD5"
    },
    {
      "id": "elem-2",
      "name": "Competitie",
      "type": "BusinessObject",
      "layer": "Business",
      "x": 280,
      "y": 192,
      "width": 140,
      "height": 80,
      "color": "#FFEFD5"
    },
    {
      "id": "elem-3",
      "name": "Seizoen",
      "type": "BusinessObject",
      "layer": "Business",
      "x": 480,
      "y": 192,
      "width": 140,
      "height": 80,
      "color": "#FFEFD5"
    }
  ],
  "relationships": [
    {
      "id": "rel-1",
      "source": "elem-2",
      "target": "elem-1",
      "type": "Association",
      "label": "is van - classificeert",
      "bendpoints": [
        {"x": 350, "y": 192},
        {"x": 350, "y": 120},
        {"x": 220, "y": 120}
      ]
    },
    {
      "id": "rel-2",
      "source": "elem-2",
      "target": "elem-3",
      "type": "Association",
      "label": "speelt in - bevat",
      "bendpoints": []
    }
  ],
  "metadata": {
    "canvasWidth": 700,
    "canvasHeight": 360,
    "grid": 8,
    "issues": []
  }
}
```

---

## Werkwijze bij Complexiteit

**Bij >10 entiteiten**:
1. Splits in meerdere sub-diagrammen per cluster
2. Of: gebruik een "overview" diagram met alleen kernelementen
3. Detaildiagrammen per cluster

**Bij circulaire relaties**:
1. Kies één relatie als "primair" (sterkste semantische link)
2. Route die rechtstreeks
3. Andere relaties via bendpoints rondom

**Bij te veel kruisingen**:
1. Herschik clusters horizontaal (wissel volgorde)
2. Introduceer "junctions" (kleine cirkel-nodes) op kruispunten
3. Splits in meerdere views

---

## Samenvatting Workflow

```
Input → [FASE 1: Analyse] → clusters
     → [FASE 2: Layering] → y-coördinaten per rij
     → [FASE 3: Positioning] → x-coördinaten per cluster
     → [FASE 4: Sizing] → width/height per element
     → [FASE 5: Routing] → bendpoints per relatie
     → [FASE 6: Styling] → kleuren
     → [FASE 7: Validatie] → checklist
     → Output (JSON met layout)
```

---

## Archi-Specific Implementation Notes

### KRITIEKE TECHNISCHE VEREISTEN

**1. targetConnections Attribuut (VERPLICHT)**
Elk `<child xsi:type="archimate:DiagramObject">` dat als target dient van één of meer connections MOET een `targetConnections` attribuut hebben:
```xml
<child xsi:type="archimate:DiagramObject" id="id-diag-seizoen" 
       archimateElement="id-bo-seizoen" 
       fillColor="#ffefd5" 
       targetConnections="id-conn-03 id-conn-15">
```
**Zonder dit attribuut worden connections niet correct gerenderd in Archi!**

**2. Expliciete Bendpoints (ALTIJD)**
Elke connection MOET bendpoints hebben, zelfs voor rechte verticale/horizontale lijnen:
```xml
<sourceConnection xsi:type="archimate:Connection" id="id-conn-01" 
                  source="id-diag-competitietype" 
                  target="id-diag-competitie" 
                  archimateRelationship="id-rel-01">
  <bendpoint startX="0" startY="75" endX="0" endY="-75"/>
</sourceConnection>
```

**3. Bidirectionele Relaties Vereenvoudigen**
Voor CDM/datamodellen met bidirectionele relaties (A↔B):
- **Model**: behoud ALLE relaties (beide richtingen)
- **View**: toon ALLEEN primaire flow (unidirectioneel)
- Vermijd 16 lijnen tussen 7 entiteiten - kies max 8 primaire relaties

**Voorbeeld**: In plaats van:
- "classificeert" (Type→Competitie) 
- "is van type" (Competitie→Type)

Toon in view alleen: "classificeert" (Type→Competitie)

### PRAKTISCHE SPACING WAARDEN (Getest in Archi)

**Verticale spacing tussen rijen:**
- Minimaal: 140px (niet 32px zoals in theorie!)
- Optimaal: 150px voor grote boxen
- Formule: `nextY = currentY + currentHeight + 50px`

**Horizontale spacing symmetrische elementen:**
- Vanaf centrum: ±135px tot ±160px
- Voor parallelle lijnen (thuis/uit): ±48px offset

**Box afmetingen:**
- **Standaard**: 220×90 (niet 140×80)
- **Minimaal**: 200×80
- Kleinere boxen (120×60) zijn te klein voor ArchiMate elementnamen

**Canvas dimensies:**
- Breedte: 760-800px voor 3 kolommen
- Hoogte: 700-750px voor 5 rijen

### LAYOUT STRATEGIEËN PER PATROON

**Classificatie Hiërarchie (verticaal):**
```
Type (y=40)
  ↓ classificeert
Instantie (y=180)
  ↓ wordt gespeeld in
Editie (y=320)
```
→ Gebruik verticale centerline, spacing 140px

**Hub Pattern (team met speler/coach):**
```
     Speler (x=30)  ←  Team (x=270)  →  Coach (x=510)
```
→ Symmetrisch, ±240px offset vanaf centrum

**Terugkoppeling (wedstrijd→seizoen):**
```
Seizoen (y=320) ←┐
                 │ 160px rechts
Wedstrijd (y=600)┘
```
→ Route via rechterkant met bendpoints op ±160px offset

### VERMIJD DEZE FOUTEN

❌ **FOUT**: Geen targetConnections attribuut
```xml
<child id="id-diag-team" archimateElement="id-bo-team">
```

✅ **CORRECT**: Met targetConnections
```xml
<child id="id-diag-team" archimateElement="id-bo-team" 
       targetConnections="id-conn-06">
```

---

❌ **FOUT**: Geen bendpoints voor rechte lijn
```xml
<sourceConnection id="id-conn-01" source="A" target="B" 
                  archimateRelationship="id-rel-01"/>
```

✅ **CORRECT**: Expliciete bendpoints
```xml
<sourceConnection id="id-conn-01" source="A" target="B" 
                  archimateRelationship="id-rel-01">
  <bendpoint startX="0" startY="75" endX="0" endY="-75"/>
</sourceConnection>
```

---

❌ **FOUT**: Alle 16 bidirectionele relaties in één view
```
Team ⇄ Speler (2 lijnen)
Team ⇄ Coach (2 lijnen)
Team ⇄ Seizoen (2 lijnen)
Team ⇄ Wedstrijd (4 lijnen: thuis/uit × beide richtingen)
= 10+ lijnen naar Team = chaos
```

✅ **CORRECT**: Alleen primaire flow in view
```
Team → Speler (1 lijn "heeft als speler")
Team → Coach (1 lijn "wordt geleid door")
Seizoen → Team (1 lijn "bevat")
Team → Wedstrijd (2 lijnen: "speelt thuis in", "speelt uit in")
= 5 lijnen vanaf Team = leesbaar
```

---

## Start Commando

Wanneer je deze prompt krijgt met een datamodel, antwoord:

1. Welke **clusters** zie je? (fase 1)
2. Welke **rijen** stel je voor? (fase 2)
3. Wat is de **horizontale indeling**? (fase 3)
4. **LET OP**: Bij bidirectionele relaties - welke primaire flow kies je voor de view?
5. Geef de **complete XML-output** met targetConnections en bendpoints (fase 4-6)
6. Rapporteer **validatieresultaten** (fase 7)

Begin nu met de layout-optimalisatie!
