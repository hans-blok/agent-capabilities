---
Agent: Agent Updater
Type: Utility
Repository: hans-blok/agent-capabilities
Gebruik: Vanuit andere workspaces
Datum: 30-12-2025
---

# Agent Beschrijving: Agent Updater (u.agent-updater)

## 1. Doel en Functionaliteit

De **Agent Updater** is een utility-agent die gebruikt wordt vanuit andere workspaces om agent-definities, prompt-bestanden en beschrijvingen bij te werken vanuit de centrale GitHub repository `hans-blok/agent-capabilities`.

### Kernfunctionaliteiten:
- **Versie-beheer**: Ophalen van specifieke versies of laatste versie (main branch)
- **Multi-file update**: Agent-definitie, prompt en beschrijving in één keer bijwerken
- **GitHub integratie**: Direct ophalen van bestanden via GitHub raw content URLs
- **Validatie**: Controleren of bestanden correct zijn opgehaald en geschreven
- **Rapportage**: Duidelijke melding van geïnstalleerde versie en bestanden

### Use Cases:
1. **Eerste installatie**: Agent voor het eerst toevoegen aan een workspace
2. **Update naar nieuwste versie**: Laatste verbeteringen ophalen van main branch
3. **Specifieke versie**: Terugdraaien naar of installeren van specifieke versie (tag/commit)
4. **Meerdere agents**: Batch-update van meerdere agents tegelijk

## 2. Positie in Ecosysteem

Deze agent is een **utility-agent** die:
- **NIET** binnen de agent-capabilities repository zelf wordt gebruikt
- **WEL** vanuit andere workspaces wordt aangeroepen
- **Cross-workspace functionaliteit** biedt voor agent-beheer

**Workflow**:
```
Andere Workspace → Agent Updater → GitHub Repository → Download → Lokaal Schrijven
```

## 3. Input en Output

### Input

**Verplicht**:
- **Agent-naam**: Bijvoorbeeld `c.feature-analist`, `d.ldm`, `b.cdm-architect`

**Optioneel**:
- **Versie**: Git tag (`v1.0.0`), commit hash (`abc123`), of branch (`main`, `develop`)
  - Default: `main` (laatste versie)
- **Update type**: `full` (standaard) of `definition-only`
- **Target directory**: Waar bestanden moeten worden opgeslagen (default: huidige workspace)

### Output

**Bestanden**:
1. `.github/agents/{stream-folder}/{agent-naam}.agent.md` - Agent-definitie
2. `.github/prompts/{stream}.{agent-naam}.prompt.md` - Prompt-bestand
3. `desc-agents/{stream-folder}/{PREFIX}-{agent-naam}.md` - Uitgebreide beschrijving

**Rapportage**:
```
✅ Agent 'c.feature-analist' bijgewerkt naar versie 'v1.2.0'

Geïnstalleerde bestanden:
- Agent-definitie: .github/agents/c.specificatie/feature-analist.agent.md
- Prompt: .github/prompts/c.feature-analist.prompt.md
- Beschrijving: desc-agents/c.specificatie/C.01-feature-analist.md

Versie: v1.2.0
Datum: 2025-12-30 14:35:22
```

## 4. Gebruik

### Via GitHub Copilot Chat

**Laatste versie ophalen**:
```
@github /u.agent-updater

Agent: c.feature-analist
```

**Specifieke versie**:
```
@github /u.agent-updater

Agent: d.ldm
Versie: v1.0.0
```

**Meerdere agents**:
```
@github /u.agent-updater

Agents: c.feature-analist, d.ldm, b.cdm-architect
Versie: main
```

**Alleen definitie**:
```
@github /u.agent-updater

Agent: d.service-architect
Update type: definition-only
```

### Via PowerShell Script

```powershell
# Implementatie mogelijk via script dat GitHub API gebruikt
# Voorlopig alleen via Copilot Chat beschikbaar
```

## 5. Agent Mapping

De agent herkent automatisch de juiste locaties op basis van agent-naam:

### DVS Stream Agents

**Stream prefix → Folder mapping**:
- `a.*` → `a.trigger`
- `b.*` → `b.architectuur`
- `c.*` → `c.specificatie`
- `d.*` → `d.ontwerp`
- `e.*` → `e.bouw`
- `f.*` → `f.validatie`
- `g.*` → `g.deployment`

**Voorbeeld** (`c.feature-analist`):
- Agent-definitie: `.github/agents/c.specificatie/feature-analist.agent.md`
- Prompt: `.github/prompts/c.feature-analist.prompt.md`
- Beschrijving: `desc-agents/c.specificatie/C.01-feature-analist.md`

### Utility Agents

**Prefix**: `u.*`  
**Folder**: `utility`

**Voorbeeld** (`u.md-to-docx`):
- Agent-definitie: `.github/agents/utility/u.md-to-docx.agent.md`
- Prompt: `.github/prompts/u.md-to-docx.prompt.md`
- Beschrijving: `desc-agents/utility/u.md-to-docx.md`

### Governance Agents

**Speciale behandeling** voor agents zoals `agnt-cap.moeder`:
- Agent-definitie: `.github/agents/agnt-cap.moeder.agent.md` (root)
- Prompt: `.github/prompts/agnt-cap.moeder.prompt.md`
- Beschrijving: `desc-agents/00-agnt-cap-moeder-agent.md`

## 6. Versie-beheer

### Versie Formaten

**Branch**:
- `main` - Laatste stabiele versie (default)
- `develop` - Development versie

**Git Tag**:
- `v1.0.0` - Semantische versie
- `v2.1.3` - Specifieke release

**Commit Hash**:
- `abc123def` - Specifieke commit (volledige hash)

### GitHub URLs

**Raw Content** (gebruikt door agent):
```
https://raw.githubusercontent.com/hans-blok/agent-capabilities/{versie}/{pad}
```

**Voorbeelden**:
```
# Laatste versie (main)
https://raw.githubusercontent.com/hans-blok/agent-capabilities/main/.github/agents/c.specificatie/feature-analist.agent.md

# Specifieke versie
https://raw.githubusercontent.com/hans-blok/agent-capabilities/v1.0.0/.github/agents/d.ontwerp/ldm.agent.md

# Commit hash
https://raw.githubusercontent.com/hans-blok/agent-capabilities/abc123def/.github/prompts/b.cdm-architect.prompt.md
```

## 7. Validatie en Error Handling

### Validaties

**Pre-download**:
- [ ] Agent-naam is geldig format
- [ ] Versie bestaat (indien opgegeven)
- [ ] Target directory is schrijfbaar

**Post-download**:
- [ ] Alle bestanden succesvol gedownload
- [ ] Bestanden hebben inhoud (niet leeg)
- [ ] Bestanden zijn valide Markdown

### Error Scenarios

**404 Not Found**:
```
❌ Fout: Agent 'x.onbekend' niet gevonden in versie 'main'

Controleer:
- Is de agent-naam correct? (bijv. c.feature-analist)
- Bestaat deze agent in de repository?
- Is de versie correct opgegeven?
```

**403 Forbidden**:
```
❌ Fout: Geen toegang tot repository hans-blok/agent-capabilities

Dit is een public repository - dit zou niet mogen gebeuren.
Neem contact op met de repository eigenaar.
```

**Bestand niet gevonden**:
```
⚠️ Waarschuwing: Beschrijving niet gevonden voor agent 'd.ldm'

Geïnstalleerd:
✅ Agent-definitie
✅ Prompt-bestand
❌ Beschrijving (niet gevonden in repository)

Agent is bruikbaar, maar beschrijving ontbreekt.
```

## 8. Beperkingen

**Deze agent doet NIET**:
- ❌ Agents wijzigen of aanpassen (alleen ophalen)
- ❌ Werken binnen agent-capabilities repository zelf
- ❌ Bestaande bestanden verwijderen
- ❌ Automatische updates (moet handmatig worden aangeroepen)
- ❌ Dependencies installeren (alleen agent-bestanden)

**Deze agent doet WEL**:
- ✅ Bestanden ophalen van GitHub
- ✅ Lokale structuur aanmaken
- ✅ Bestanden overschrijven met nieuwere versies
- ✅ Rapporteren over succes/falen

## 9. Best Practices

### Wanneer Updaten?

**Regelmatig**:
- Maandelijkse check voor updates op main branch
- Voor belangrijke bug fixes of verbeteringen

**Voor specifieke versies**:
- Bij stabiele releases (tags)
- Voor reproduceerbare omgevingen

**Niet updaten**:
- Midden in actief werk met de agent
- Zonder eerst release notes te lezen

### Update Strategy

**Stap 1**: Check beschikbare versies
```
Ga naar: https://github.com/hans-blok/agent-capabilities/releases
```

**Stap 2**: Update naar laatste stabiele tag
```
@github /u.agent-updater
Agent: c.feature-analist
Versie: v1.2.0
```

**Stap 3**: Test de agent
```
@github /c.feature-analist
[Test met voorbeeldproject]
```

**Stap 4**: Bij problemen: rollback
```
@github /u.agent-updater
Agent: c.feature-analist
Versie: v1.1.0
```

## 10. Voorbeeld Sessie

```
Gebruiker: @github /u.agent-updater
          Agent: c.feature-analist

Agent:    Ophalen van agent 'c.feature-analist' vanaf main...
          
          ✅ Agent-definitie gedownload
          ✅ Prompt-bestand gedownload  
          ✅ Beschrijving gedownload
          
          Bestanden schrijven...
          
          ✅ .github/agents/c.specificatie/feature-analist.agent.md
          ✅ .github/prompts/c.feature-analist.prompt.md
          ✅ desc-agents/c.specificatie/C.01-feature-analist.md
          
          ✅ Agent 'c.feature-analist' bijgewerkt naar versie 'main'
          Datum: 2025-12-30 14:35:22

Gebruiker: Dank je! Kan ik nu meerdere agents tegelijk updaten?

Agent:    Ja! Geef ze door gescheiden met komma's:
          
          @github /u.agent-updater
          Agents: c.feature-analist, d.ldm, b.cdm-architect
```

## 11. Toekomstige Uitbreidingen

**Mogelijk**:
- PowerShell script voor batch updates
- Automatische dependency checking
- Update notificaties (nieuwe versies beschikbaar)
- Changelog weergave bij update

**Niet gepland**:
- Automatische updates (moet expliciet worden aangeroepen)
- Modificatie van agent-bestanden
- Custom agent repositories (alleen hans-blok/agent-capabilities)

---

**Agent Type**: Utility  
**Source Repository**: https://github.com/hans-blok/agent-capabilities  
**Gebruik**: Vanuit andere workspaces  
**Status**: Actief
