# Agent-converter: Markdown naar DOCX – Context

## 1. Rol binnen het Agent-Ecosysteem

Deze workspace is onderdeel van een breder **agent-ecosysteem**.  
De repository **`agent-capabilities`** bevat **generieke agents**:

- **Converters** (bijvoorbeeld Markdown ↔ DOCX, Markdown ↔ XML)  
- **Analyzers** (bijvoorbeeld vergelijken, confronteren, kwaliteit meten)  
- **Specifiers** (bijvoorbeeld specificaties of checklists genereren)  
- Andere gespecialiseerde, maar **domeinonafhankelijke** taken  

Deze agents hebben **geen domeinkennis** van een specifiek project.  
Ze zijn bedoeld als **professionele tools** die in verschillende projecten kunnen worden ingezet.

---

## 2. Achtergrond

Binnen het agent-ecosysteem gebruiken we **Markdown als standaardformaat** voor specificaties, ontwerpen en documentatie. Markdown is:
- Eenvoudig te lezen
- Goed te verwerken door agents
- Geschikt voor versiebeheer

Toch hebben we soms documenten nodig in **Microsoft Word (DOCX)**, bijvoorbeeld voor:
- Formele publicaties
- Rapportages
- Communicatie met stakeholders die niet met Markdown werken

Hiervoor is een **generieke conversie-agent** nodig die zelfstandig en betrouwbaar Markdown-bestanden omzet naar DOCX.

---

## 3. Doelstelling Capability

> Een eenvoudige, stabiele agent leveren die Markdown-bestanden automatisch en foutloos omzet naar DOCX, zonder domeinkennis en zonder aanvullende instructies.

Deze agent moet:
- **Herbruikbaar** zijn in alle projecten
- **Voorspelbare output** leveren
- **Aansluiten** op de kwaliteitsregels uit het standards-ecosysteem
- Als **"professionele tool"** beschikbaar zijn voor elke moeder-agent

---

## 4. Belangrijke Uitgangspunten

### 4.1 Domeinonafhankelijkheid
De agent is **domeinonafhankelijk** en maakt geen aannames over de inhoud van het Markdown-document.

### 4.2 Constitutie-compliance
De agent volgt de algemene regels uit de constitutie:
- Formele **B1-taal**
- **Geen onzekerheid verbergen**
- **Duidelijke uitleg** bij fouten

### 4.3 Structuurbehoud
De agent levert DOCX-uitvoer met **behoud van structuur**, zoals:
- Koppen (H1, H2, H3, etc.)
- Lijsten (genummerd en ongenummerd)
- Tabellen
- Codeblokken (indien mogelijk)
- Vetgedrukte en cursieve tekst
- Links

### 4.4 Volledig Automatisch
De agent werkt **volledig automatisch**:
- Geen interactie nodig
- Geen extra vragen
- Direct van input naar output

### 4.5 Integratie
De moeder-agent kan deze capability activeren wanneer een project vraagt om publiceerbare Word-documenten.

---

## 5. Aanpak

### Stap 1: Capability-agent Aanmaken
De moeder-agent maakt een capability-agent aan in de map `.github/agents/convert/`.

### Stap 2: Agent-configuratie
De agent krijgt:
- Een **duidelijke taakomschrijving**
- Een **prompt** die de conversieregels bevat
- **Minimaal één voorbeeld** van input en output
- Een **beschrijving** in `desc-agents/convert/`

### Stap 3: Registratie
De moeder-agent registreert deze capability in de **catalogus**, zodat andere agents hem kunnen aanroepen.

### Stap 4: Kwaliteitscontrole
De output wordt automatisch gecontroleerd op:
- Aanwezigheid van een **geldig DOCX-bestand**
- **Behoud van de structuur** uit de Markdown
- **Leesbaarheid** van het resultaat

### Stap 5: Iteratie
De capability wordt later **uitgebreid** op basis van gebruikservaring in echte projecten.

---

## 6. Technische Details

### Input
- **Formaat**: Markdown (`.md`)
- **Locatie**: Door gebruiker opgegeven bestandspad
- **Encoding**: UTF-8

### Output
- **Formaat**: Microsoft Word DOCX (`.docx`)
- **Locatie**: Zelfde directory als input, of door gebruiker opgegeven
- **Naamgeving**: `<originele-naam>.docx`

### Dependencies
De agent maakt gebruik van:
- **Pandoc** (indien beschikbaar) voor conversie
- Alternatieve methoden als Pandoc niet beschikbaar is

---

## 7. Gebruik

### Aanroepen via moeder-agent
```
@github /agnt-cap.moeder

Ik wil een nieuwe agent maken:
- Domein: convert
- Taaknaam: md-to-docx
- Context: Converteert Markdown bestanden naar Microsoft Word DOCX formaat
```

### Direct gebruik (na creatie)
```
@github /convert.md-to-docx

Converteer het bestand 'specificatie.md' naar DOCX formaat.
```

---

## 8. Kwaliteitscriteria

De agent wordt goedgekeurd als:
- [ ] Markdown wordt correct omgezet naar DOCX
- [ ] Kopstructuur blijft behouden
- [ ] Lijsten worden correct weergegeven
- [ ] Tabellen blijven leesbaar
- [ ] Codeblokken zijn herkenbaar
- [ ] Er ontstaan geen corrupte DOCX-bestanden
- [ ] De agent werkt zonder handmatige tussenkomst
- [ ] Foutmeldingen zijn duidelijk en op B1-niveau

---

## 9. Toekomstige Uitbreidingen

Mogelijke uitbreidingen op basis van gebruikservaring:
- Ondersteuning voor **afbeeldingen** in Markdown
- **Template-ondersteuning** voor corporate huisstijl
- **Batch-conversie** voor meerdere bestanden tegelijk
- Ondersteuning voor **custom styling**
- Export naar andere formaten (PDF, ODT, etc.)
