# Agent Beschrijving: C.04-md-to-docx

**Agent**: C.md-to-docx  
**DVS-Positie**: Stream C - Specificeren (C.04)  
**Categorie**: Specificatie Converter  
**Versie**: 1.1 (DVS-gestructureerd)  
**Taal**: Nederlands

---

## 1. Doel en Functionaliteit

De **C.md-to-docx** agent (Stream C: Specificeren - C.04) is een generieke converter die **Markdown-bestanden automatisch en betrouwbaar omzet naar Microsoft Word DOCX-formaat**. 

**Hoofddoel**:
> Een eenvoudige, stabiele agent leveren die Markdown-bestanden (vooral specificaties) automatisch en foutloos omzet naar DOCX, zonder domeinkennis en zonder aanvullende instructies.

**Kenmerken**:
- **DVS-Positie**: Stream C (Specificeren) - voor conversie van specificatie-documenten
- **Domeinonafhankelijk**: Werkt met elke Markdown-content
- **Structuurbehoud**: Behoudt kopjes, lijsten, tabellen en opmaak
- **Volledig automatisch**: Geen interactie nodig
- **Herbruikbaar**: In alle projecten inzetbaar

---

## 2. Context en Achtergrond

### 2.1 Rol binnen het Agent-Ecosysteem en Development Value Stream

Deze agent is onderdeel van de **Agent-Capabilities** repository die generieke, herbruikbare agents bevat volgens de **SAFe Development Value Stream (DVS)**:

**DVS-Positie: Stream C - Specificeren**
- Deze agent ondersteunt de **Specificeren-fase** van softwareontwikkeling
- Typische use case: Converteren van requirement specificaties, datamodellen en functionele specs van Markdown naar DOCX
- Positie in de stream: **C.04** (vierde agent in Stream C)

**Relatie tot andere streams**:
- **Input**: Kan Markdown ontvangen uit Stream B (Architectuur) voor architectuur documenten
- **Output**: DOCX-bestanden voor verdere review en distributie
- **Samenwerking**: Werkt samen met andere Stream C agents voor specificatie-documentatie
- **Converters** (zoals deze agent)
- **Analyzers** 
- **Specifiers**
- Andere domeinonafhankelijke tools

### 2.2 Waarom deze Agent?

Binnen het agent-ecosysteem gebruiken we **Markdown als standaardformaat** voor:
- Specificaties
- Ontwerpen
- Documentatie

**Voordelen van Markdown**:
- Eenvoudig te lezen
- Goed te verwerken door agents
- Geschikt voor versiebeheer

**Toch hebben we soms DOCX nodig voor**:
- Formele publicaties
- Rapportages
- Communicatie met stakeholders die niet met Markdown werken

### 2.3 Doelstelling

Deze agent moet:
- **Herbruikbaar** zijn in alle projecten
- **Voorspelbare output** leveren
- **Aansluiten** op kwaliteitsregels uit het standards-ecosysteem
- Als **professionele tool** beschikbaar zijn voor elke moeder-agent

---

## 3. Input

### Vereiste Informatie

**Markdown bestand**:
- **Formaat**: `.md`
- **Locatie**: Volledig bestandspad
- **Encoding**: UTF-8
- **Inhoud**: Valide Markdown syntax

**Voorbeeld**:
```
c:\docs\specificatie.md
```

### Optionele Informatie

**Output locatie**:
- Standaard: Zelfde directory als input
- Optioneel: Specifiek pad opgeven

**Output bestandsnaam**:
- Standaard: `<originele-naam>.docx`
- Optioneel: Custom naam

---

## 4. Functionaliteit

### 4.1 Structuurbehoud

De agent behoudt alle standaard Markdown-elementen:

#### Koppen
| Markdown | Word |
|----------|------|
| `# Kop 1` | Heading 1 |
| `## Kop 2` | Heading 2 |
| `### Kop 3` | Heading 3 |
| `#### Kop 4` | Heading 4 |

#### Tekstopmaak
| Markdown | Result |
|----------|--------|
| `**vet**` | **Vetgedrukt** |
| `*cursief*` | *Cursief* |
| `` `code` `` | Inline code |
| `~~doorhalen~~` | ~~Doorgehaald~~ |

#### Lijsten
- **Ongenummerd** (`-`, `*`, `+`) → Word bulleted lists
- **Genummerd** (`1.`, `2.`) → Word numbered lists
- **Genest** → Behoud van inspringing

#### Tabellen
Markdown tabellen worden omgezet naar Word tabellen met:
- Borders
- Vetgedrukte header rij
- Correcte kolom alignering

#### Codeblokken
` ```code``` ` wordt:
- Monospace font
- Achtergrondkleur
- Syntax highlighting (indien mogelijk)

#### Links
`[tekst](url)` → Word hyperlinks

#### Afbeeldingen
`![alt](url)` → Ingevoegde afbeeldingen (indien toegankelijk)

#### Overige Elementen
- **Horizontale lijnen**: `---` → Word horizontal rule
- **Citaten**: `> tekst` → Word blockquote styling

### 4.2 Conversie-methoden

**Primaire methode: Pandoc**
```powershell
pandoc -f markdown -t docx -o output.docx input.md
```

**Voordelen**:
- Betrouwbaar
- Breed ondersteund
- Behoud van complexe structuren

**Alternatieve methode: Python + python-docx**
```python
import markdown
from docx import Document
# Parseer en converteer
```

**Fallback: PowerShell custom**
- Basis conversie
- Minder features
- Altijd beschikbaar

---

## 5. Workflow

### Stap 1: Input Validatie

**Doel**: Controleren of Markdown bestand geldig is

**Acties**:
1. Controleer of bestand bestaat
2. Controleer of extensie `.md` is
3. Controleer of bestand leesbaar is
4. Valideer UTF-8 encoding

**Foutafhandeling**:
- Bestand niet gevonden → Duidelijke foutmelding met pad
- Geen `.md` extensie → Waarschuwing en vraag om bevestiging
- Niet leesbaar → Controleer permissies

### Stap 2: Conversie Uitvoeren

**Doel**: Markdown omzetten naar DOCX

**Methode selectie**:
1. Probeer Pandoc (indien beschikbaar)
2. Probeer Python + python-docx
3. Gebruik PowerShell fallback

**Conversie-proces**:
1. Lees Markdown bestand
2. Parseer Markdown syntax
3. Genereer DOCX structuur
4. Schrijf output bestand

### Stap 3: Output Validatie

**Doel**: Controleren of DOCX geldig is

**Acties**:
1. Controleer of bestand is aangemaakt
2. Controleer bestandsgrootte > 0 bytes
3. Test of bestand te openen is
4. Valideer DOCX structuur

**Validatie checklist**:
- [ ] DOCX bestand bestaat
- [ ] Kopstructuur behouden
- [ ] Lijsten correct
- [ ] Tabellen leesbaar
- [ ] Opmaak (vet, cursief) correct
- [ ] Links werken
- [ ] Geen corrupt bestand

### Stap 4: Rapportage

**Bij succes**:
```
✅ Conversie succesvol!

Input:  c:\docs\specificatie.md
Output: c:\docs\specificatie.docx
Grootte: 125 KB

Structuur behouden:
- 12 koppen
- 8 lijsten
- 3 tabellen
- 45 links
```

**Bij fout**:
```
❌ Conversie mislukt

Fout: Bestand niet gevonden
Details: Het bestand 'c:\docs\spec.md' bestaat niet.
Oplossing: Controleer het bestandspad en probeer opnieuw.
```

---

## 6. Voorbeelden

### Voorbeeld 1: Basis Conversie

**Input** (`voorbeeld.md`):
```markdown
# Hoofdstuk 1

Dit is een **voorbeeld** document.

## Sectie 1.1

- Punt 1
- Punt 2
- Punt 3

### Subsectie

Hier is een tabel:

| Kolom A | Kolom B |
|---------|---------|
| Data 1  | Data 2  |
```

**Commando**:
```
@github /convert.md-to-docx

Converteer bestand: voorbeeld.md
```

**Output** (`voorbeeld.docx`):
- Heading 1: "Hoofdstuk 1"
- Normale tekst met **vetgedrukt** "voorbeeld"
- Heading 2: "Sectie 1.1"
- Bulleted list met 3 items
- Heading 3: "Subsectie"
- Word tabel met 2 kolommen en headers

### Voorbeeld 2: Met Custom Output

**Commando**:
```
@github /convert.md-to-docx

Converteer bestand: c:\project\specs\requirements.md
Output locatie: c:\deliverables\
Output naam: Requirements_Final.docx
```

**Resultaat**:
```
✅ Conversie succesvol!

Input:  c:\project\specs\requirements.md
Output: c:\deliverables\Requirements_Final.docx
```

### Voorbeeld 3: Complexe Structuur

**Input** met:
- Meerdere kopniveaus (H1-H6)
- Geneste lijsten
- Codeblokken
- Afbeeldingen
- Links
- Tabellen met merged cells

**Agent behoudt**:
- ✅ Alle kopniveaus
- ✅ Geneste lijsten met correcte inspringing
- ✅ Codeblokken met monospace font
- ✅ Afbeeldingen (indien toegankelijk)
- ✅ Werkende hyperlinks
- ✅ Tabellen (zonder merged cells)

---

## 7. Beperkingen

### Wat de Agent NIET doet

❌ **Complexe Word features**:
- Geen custom templates
- Geen advanced formatting
- Geen macros of VBA

❌ **Content aanpassingen**:
- Geen spelling correctie
- Geen stijl verbeteringen
- Geen domeinspecifieke aanpassingen

❌ **Geavanceerde layouts**:
- Geen multi-column layouts
- Geen page breaks op specifieke plekken
- Geen custom headers/footers

### Wat de Agent WEL doet

✅ **Standaard conversie**:
- Alle basis Markdown elementen
- Correcte structuur
- Behoud van opmaak

✅ **Betrouwbaar**:
- Consistente output
- Voorspelbaar gedrag
- Duidelijke foutmeldingen

✅ **Automatisch**:
- Geen handmatige tussenkomst
- Direct van input naar output
- Validatie van resultaat

---

## 8. Dependencies

### Aanbevolen: Pandoc

**Versie**: 2.0 of hoger

**Installatie Windows**:
```powershell
choco install pandoc
```

Of download van: https://pandoc.org/installing.html

**Voordelen**:
- Beste conversie kwaliteit
- Uitgebreide Markdown support
- Actief onderhouden

### Alternatief: Python + python-docx

**Installatie**:
```bash
pip install python-docx markdown
```

**Voordelen**:
- Programmatische controle
- Aanpasbaar
- Python ecosysteem

### Fallback: PowerShell

**Versie**: PowerShell 5.1 of hoger

**Voordelen**:
- Altijd beschikbaar op Windows
- Geen extra installatie
- Basis functionaliteit

---

## 9. Output Specificaties

### Bestand Eigenschappen

**Formaat**: 
- Microsoft Word DOCX (Office Open XML)
- Compatible met Word 2007+

**Locatie**:
- Standaard: Zelfde directory als input
- Custom: Door gebruiker opgegeven

**Naamgeving**:
- Standaard: `<input-naam>.docx`
- Custom: Door gebruiker opgegeven

**Eigenschappen**:
- Author: Agent-Capabilities
- Creator: convert.md-to-docx
- Creation date: Conversie datum/tijd

### Structuur

**Styles gebruikt**:
- Heading 1-6
- Normal
- Code
- Blockquote
- Table styles

**Opmaak**:
- Font: Calibri (standaard Word)
- Heading fonts: Volgens Word template
- Code font: Consolas of Courier New
- Font size: 11pt (Normal), variërend (Headings)

---

## 10. Foutafhandeling

### Fout: Bestand niet gevonden

**Foutmelding**:
> ❌ Het Markdown bestand '[pad]' is niet gevonden.  
> Controleer het bestandspad en probeer opnieuw.

**Oorzaak**:
- Verkeerd pad opgegeven
- Bestand verplaatst of verwijderd
- Typfout in bestandsnaam

**Oplossing**:
- Controleer pad
- Gebruik absolute paden
- Controleer of bestand bestaat

### Fout: Pandoc niet beschikbaar

**Foutmelding**:
> ⚠️ Pandoc is niet geïnstalleerd.  
> Installeer Pandoc via https://pandoc.org/installing.html  
> Of de agent zal een alternatieve methode gebruiken.

**Oorzaak**:
- Pandoc niet geïnstalleerd
- Pandoc niet in PATH

**Oplossing**:
- Installeer Pandoc
- Agent gebruikt automatisch fallback methode

### Fout: Conversie mislukt

**Foutmelding**:
> ❌ De conversie naar DOCX is mislukt.  
> Controleer of het Markdown bestand valide is.  
> Foutdetails: [specifieke fout]

**Mogelijke oorzaken**:
- Ongeldige Markdown syntax
- Encoding problemen
- Corrupte input

**Oplossing**:
- Valideer Markdown syntax
- Controleer encoding (moet UTF-8 zijn)
- Test met eenvoudiger Markdown

### Fout: Ongeldige DOCX

**Foutmelding**:
> ❌ Het gegenereerde DOCX bestand lijkt beschadigd.  
> Probeer het opnieuw of controleer de input.

**Oorzaak**:
- Conversie proces onderbroken
- Disk space vol
- Permissions probleem

**Oplossing**:
- Probeer opnieuw
- Check disk space
- Check write permissions

---

## 11. Gebruik in Praktijk

### Scenario 1: Documentatie Publiceren

**Context**: Technische documentatie geschreven in Markdown moet naar stakeholders in Word formaat.

**Gebruik**:
```
@github /convert.md-to-docx

Converteer bestand: c:\project\docs\technical-spec.md
```

**Resultaat**:
- Professional DOCX document
- Alle kopjes en structuur behouden
- Direct te delen met stakeholders

### Scenario 2: Rapportage

**Context**: Wekelijkse rapportage in Markdown moet als Word document naar management.

**Gebruik**:
```
@github /convert.md-to-docx

Converteer bestand: weekrapport-w50.md
Output locatie: c:\rapportages\
```

**Resultaat**:
- Consistent geformatteerd rapport
- Behoud van lijsten en tabellen
- Direct te printen of mailen

### Scenario 3: Batch Conversie

**Context**: Meerdere Markdown bestanden moeten naar DOCX.

**PowerShell script**:
```powershell
Get-ChildItem *.md | ForEach-Object {
    & convert.md-to-docx.ps1 $_.FullName
}
```

**Resultaat**:
- Alle `.md` bestanden geconverteerd
- Originele structuur behouden
- Batch processing

---

## 12. Integratie met Andere Agents

### Met Project Moeder-agents

Project moeder-agents kunnen deze converter gebruiken voor:
- Publicatie van specificaties
- Genereren van leverbare documenten
- Export van documentatie

**Voorbeeld**:
```
@github /project.moeder

Publiceer specificatie als Word document
→ Roept convert.md-to-docx aan
```

### Met Specificeer Agents

Specificeer agents kunnen output direct laten converteren:
```
1. Genereer specificatie (Markdown)
2. Converteer naar DOCX met convert.md-to-docx
3. Lever DOCX af aan stakeholder
```

### Workflow Integratie

```
[Schrijf docs in MD] → [Review in Git] → [convert.md-to-docx] → [Deel DOCX]
```

---

## 13. Kwaliteitscriteria

De agent voldoet aan kwaliteitseisen als:

**Functionaliteit**:
- [x] Markdown wordt correct omgezet naar DOCX
- [x] Kopstructuur blijft behouden
- [x] Lijsten worden correct weergegeven
- [x] Tabellen blijven leesbaar
- [x] Codeblokken zijn herkenbaar
- [x] Links werken
- [x] Opmaak (vet, cursief) correct

**Betrouwbaarheid**:
- [x] Geen corrupte DOCX-bestanden
- [x] Consistente output
- [x] Reproduceerbaar resultaat

**Gebruiksvriendelijkheid**:
- [x] Agent werkt zonder handmatige tussenkomst
- [x] Foutmeldingen zijn duidelijk en op B1-niveau
- [x] Duidelijke succesbericht

**Performance**:
- [x] Conversie binnen 5 seconden voor <100KB Markdown
- [x] Schaalt goed met bestandsgrootte

---

## 14. Toekomstige Uitbreidingen

Mogelijke uitbreidingen op basis van gebruikservaring:

### Fase 2: Templates
- Ondersteuning voor **Word templates**
- Custom **corporate huisstijl**
- **Headers en footers** configuratie

### Fase 3: Batch Processing
- **Bulk conversie** van meerdere bestanden
- **Directory monitoring** voor automatische conversie
- **Batch rapportage**

### Fase 4: Advanced Features
- **Custom styling** opties
- **Afbeelding optimalisatie**
- **Table of Contents** generatie
- **Index** generatie

### Fase 5: Multi-Format
- Export naar **PDF**
- Export naar **ODT** (OpenDocument)
- Export naar **HTML**

---

## 15. Contact en Feedback

Voor feedback of problemen met deze agent:

**Via moeder-agent**:
```
@github /agnt-cap.moeder

Feedback op convert.md-to-docx agent:
[Jouw feedback]
```

**Verbeterpunten melden**:
- Ontbrekende features
- Bugs of fouten
- Performance problemen
- Documentatie onduidelijkheden

---

**Laatste Update**: December 2025  
**Versie**: 1.0  
**Status**: Productie-ready  
**Auteur**: agnt-cap.moeder
