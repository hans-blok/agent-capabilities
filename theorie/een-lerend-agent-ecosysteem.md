# Leren binnen een Agent-Ecosysteem  
*Van losse succesvolle applicaties naar institutionele intelligentie*

---

## 1. Inleiding

Organisaties die veel ervaring hebben met het bouwen van applicaties met AI-agents bereiken vroeg of laat een kantelpunt:

> *“We kunnen dit goed. We hebben capabilities, standaarden en meerdere applicaties die op elkaar lijken.  
> Hoe zorgen we dat het systeem zélf structureel beter wordt?”*

Deze vraag gaat **niet** over betere prompts of een groter LLM, maar over het **verankeren van ervaring** in het ecosysteem.

---

## 2. Fundamentele visie

Wat hier gezocht wordt is **institutionalisering van ervaring**:

- ❌ Niet: het LLM laten leren zoals een mens (blind fine-tunen)
- ✅ Wel: het **agent-ecosysteem** laten leren via expliciete structuren

De echte intelligentie zit niet in het model, maar in:

- expliciete artefacten  
- governance en selectie  
- agent-compositie  
- feedback- en leerloops  

Dit sluit naadloos aan bij:
- charter-first werken  
- SAFe-fase-indeling  
- klassieke Yourdon-principes: *expliciete modellen boven impliciete kennis*

---

## 3. Wat bestaat er al (en waar loopt het vast)

### 3.1 Bestaande benaderingen

| Aanpak | Effect |
|------|-------|
| RAG op code & docs | Goed voor kennisopvraag, niet voor beter gedrag |
| Fine-tuning op outputs | Vervlakt gedrag, verlies van context |
| Tool-augmented agents | Verbeteren uitvoering, niet ontwerpkwaliteit |
| Reflection loops | Lokaal nuttig, globaal chaotisch zonder governance |

### 3.2 Wat structureel ontbreekt

- Expliciete **ervaringseenheden**
- Selectie op **waarde**, niet volume
- Evolutie op **patroon-niveau**, niet prompt-niveau

De industrie probeert vooral het **model slimmer** te maken,  
terwijl het echte vraagstuk is: *het systeem slimmer laten worden*.

---

## 4. Drie patronen die wél werken

### 4.1 Van applicatie naar *Experience Package*

Behandel elke succesvolle applicatie als een **ervaringspakket**, niet als code of prompt.

**Minimale inhoud:**
- Context (domein, constraints)
- Agent-landschap (welke agents, waarom)
- Belangrijke beslissingen (ADR-achtig)
- Wat werkte / wat faalde
- Kwaliteitsresultaten (doorlooptijd, defects, rework)

> Dit is geen trainingsdata, maar **operationele kennis**.

---

### 4.2 Leren door selectie, niet door training

Niet:
> “Het model moet leren”

Maar:
> “Het systeem moet betere keuzes leren maken”

Concreet:
- Meerdere bekende agent-composities proberen
- Objectief evalueren (kwaliteit, stabiliteit, snelheid)
- Slechte patronen elimineren
- Goede patronen promoveren

Dit is **evolutionair leren**, geen statistisch leren.

---

### 4.3 Meta-agents boven een slimmer core-model

Volwassen agent-ecosystemen kiezen voor:

- ❌ Geen alleswetend mega-model
- ✅ **Meta-agents** die:
  - eerdere cases herkennen
  - agent-composities voorstellen
  - keuzes expliciet onderbouwen

De **Moeder Agent** is hier de natuurlijke spil.

---

## 5. Concreet groeipad passend bij jullie ecosysteem

### Stap 1 — Experience Registry

Introduceer een expliciet geheugen:

```text
experience/
 └─ app-x/
    ├─ context.md
    ├─ agent-landschap.md
    ├─ beslissingen.md
    ├─ kwaliteitsmetrics.md
    └─ lessons-learned.md
