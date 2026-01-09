# Beleid Agent-Capabilities Workspace

## Verplicht: Git Pull bij Standard Repository Raadpleging

**Beleid**: Bij elke raadpleging van https://github.com/hans-blok/standard.git MOET er eerst een `git pull` worden uitgevoerd.

**Implementatie**:
- make-agent.py voert automatisch `git pull` uit op standard repository
- Alle agents die charters raadplegen doen eerst een pull
- Dit garandeert dat altijd met de nieuwste versie wordt gewerkt

**Rationale**: 
- Voorkomt werken met verouderde charters
- Agents genereren altijd de meest actuele componenten
- Consistentie tussen alle agent-componenten

**Is dit dubbel met agent charters?**: Nee, dit is complementair:
- Dit beleid = workspace regel (hoe we werken)
- Agent charter = agent verantwoordelijkheid (wat de agent doet)
- Beide versterken elkaar voor robuuste workflows

---

## 1. Minimale Prompts
**Rationale**: Schaalbaarheid en onderhoudbaarheid

**Implementatie**:
- Prompt bevat ALLEEN:
  ```yaml
  ---
  agent: std.<fase>.<agent-naam>
  ---
  
  We scheiden agents en prompts voor schaalbaarheid.
  Charter: <pad-naar-charter>
  ```

**Consequenties**:
- Instructies staan in charter (standard repository)
- Prompt-wijzigingen minimal → snelle sync
- Charter is single source of truth

## 2. Charter als Single Source of Truth
**Rationale**: Eén plek voor agent-definitie

**Implementatie**:
- Alle agent-logica in charter
- Components gegenereerd vanuit charter
- Charter-updates → regenerate components

**Consequenties**:
- Charter-wijziging impacteert alle usages
- Versioning in charter, niet in components
- Traceerbaarheid via charter-path in buildplan

## 3. Separation of Concerns
**Rationale**: Duidelijke verantwoordelijkheden

**Boundaries**:
```
standard/               → Agent-definities (charters)
agent-capabilities/     → Component-generator & sync
project-workspaces/     → Agent-execution & artefacten
```

**Geen overlap**:
- Agent-capabilities maakt GEEN artefacten
- Project workspaces definiëren GEEN agents
- Standard bepaalt GEEN sync-mechanisme

## 4. Flat File Structure
**Rationale**: Eenvoud en snelheid

**Implementatie**:
- Fase in filename prefix, niet in directory
- `c.logisch-data-modelleur.prompt.md` ✓
- `c/logisch-data-modelleur.prompt.md` ✗

**Consequenties**:
- Sneller zoeken
- Geen directory-nesting issues
- Alfabetische sortering toont fase-grouping

## 5. Idempotency
**Rationale**: Veilig opnieuw uitvoeren

**Implementatie**:
- make-agent.py overschrijft bestaande files
- sync-agents.py vraagt confirmatie bij overschrijven
- Regenerate is altijd veilig

**Consequenties**:
- Charter-fix → regenerate → sync
- Geen handmatige merges nodig
- Generated files NIET handmatig editen

## 6. Explicit over Implicit
**Rationale**: Geen verrassingen

**Implementatie**:
- Expliciete paths (geen relatieve paths zonder context)
- Expliciete aannames (max 3, gedocumenteerd)
- Expliciete fase-prefix in filenames

**Consequenties**:
- Meer verbose, maar duidelijker
- Self-documenting file structure
- Tooling kan valideren

## 7. Fail Fast
**Rationale**: Problemen vroeg detecteren

**Implementatie**:
- Validatie VOOR generatie
- Charter moet bestaan VOOR make-agent.py
- Target workspace moet bestaan VOOR sync

**Consequenties**:
- Minder corrupte states
- Duidelijke error messages
- Snellere feedback loop

## 8. Traceable Generation
**Rationale**: Begrijpbare output

**Implementatie**:
- Buildplan bevat alle metadata:
  - Charter-path
  - Gegenereerd-op timestamp
  - Output-paths
  - Quality gates

**Consequenties**:
- Altijd terug te traceren naar charter
- Audit trail voor debugging
- Reproduceerbare builds

## 9. Pipeline Templates
**Rationale**: Herbruikbare, platform-agnostische CI/CD configuratie

**Architectuur**:
- **Definities**: Platform-agnostische pipeline definities in `agent-componenten/pipelines/definitions/`
- **Generators**: `make-agent.py` bevat generators die definities vertalen naar platform-specifieke templates
- **Gegenereerd**: Platform-specifieke templates in `agent-componenten/pipelines/generated/<platform>/`

**Implementatie**:
- `make-agent.py` genereert platform-specifieke templates uit de agnostische definitie
- `sync-agents.py` synchroniseert de *gegenereerde* templates naar project workspaces
- Naming: `<fase>.<agent-naam>.pipeline.yml` (definitie), `<fase>.<agent-naam>.<platform-extensie>` (gegenereerd)

**Project Gebruik**:
- Project kiest platform bij sync (`--platform gitlab-ci`)
- Template wordt gekopieerd naar platform-specifieke locatie (bv. `.gitlab-ci.yml`)
- Project MAG template aanpassen na sync
- Template dient als startpunt en best practice

**Consequenties**:
- Charter kan pipeline-configuratie bevatten (optioneel)
- `make-agent.py` kan alle pipelines regenereren voor een nieuw platform (bv. bij migratie)
- `sync-agents.py` kopieert alleen de benodigde platform-specifieke templates
- Pipeline definities zijn onderdeel van Experience Packages

**Beperkingen**:
- Definitie bevat generieke agent-executie
- Project-specifieke secrets/vars niet in definitie
- Environment-specifieke config in project

## Anti-Patterns (NIET doen)

### ❌ Business Logic in Components
**Probleem**: Components zijn transport-mechanisme, geen business logic
**Goed**: Charter bevat logic, prompt refereert ernaar
**Slecht**: Prompt bevat inline business rules

### ❌ Project-Specifieke Configuration in Components
**Probleem**: Components zijn herbruikbaar
**Goed**: Generic runner met project-specific config in workspace
**Slecht**: Hardcoded project paths in runner

### ❌ Handmatig Editen van Generated Files
**Probleem**: Edits gaan verloren bij regenerate
**Goed**: Edit charter → regenerate
**Slecht**: Direct prompt.md editen

### ❌ Fase-Based Directories
**Probleem**: Complexiteit zonder voordeel
**Goed**: Flat structure met fase-prefix
**Slecht**: a/, b/, c/, d/ subdirectories

### ❌ Agents Uitvoeren in Agent-Capabilities
**Probleem**: Mixing concerns
**Goed**: Agents run in project workspaces
**Slecht**: Output naar agent-capabilities/artefacten/

### ❌ Dupliceren van Charter-Content
**Probleem**: Inconsistentie en onderhouds-overhead
**Goed**: Charter referentie in prompt
**Slecht**: Charter content kopiëren naar prompt

### ❌ Impliciete Dependencies
**Probleem**: Onvoorspelbaar gedrag
**Goed**: Expliciete dependency checks in scripts
**Slecht**: Assumeren dat standard/ bestaat

### ❌ Versioning in Component Files
**Probleem**: Conflicten met charter-versioning
**Goed**: Versie alleen in charter
**Slecht**: v1.2.3 in prompt-filename
