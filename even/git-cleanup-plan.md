# Plan: Git Repository Opschoning naar v1.0.0

**Doel**: Repository opschonen tot één initiële commit en taggen als versie 1.0.0  
**Repository**: agent-capabilities  
**Datum**: 2026-01-09  
**Verantwoordelijk**: Moeder Agent Capabilities + Menselijke review

---

## 1. Huidige Situatie

- Repository heeft 15+ commits met iteratieve ontwikkeling
- Huidige HEAD: `e9e6f90 - Verbeter scripts en realiseer eerste taak`
- Ontwikkelingshistorie: charter refactoring, workflow orchestrator, Git expertise toevoegingen
- Gewenst: Schone history met één commit voor v1.0.0

---

## 2. Strategie: Orphan Branch Method

**Waarom deze methode?**
- Veilig: Oude history blijft beschikbaar in oude branch
- Schoon: Nieuwe history start vanaf nul
- Eenvoudig: Geen complexe rebase operaties
- Toekomstbestendig: Werkt identiek voor GitHub en GitLab

**Proces**:
1. Maak orphan branch (geen history)
2. Voeg huidige state toe
3. Commit als initiële versie
4. Tag als v1.0.0
5. Force push naar main

---

## 3. Stap-voor-Stap Uitvoering

### Stap 1: Backup maken (veiligheid)
```powershell
# Maak backup branch van huidige state
git branch backup-before-v1.0 main
git push origin backup-before-v1.0
```

### Stap 2: Orphan branch creëren
```powershell
# Maak nieuwe orphan branch (geen history)
git checkout --orphan v1.0-clean

# Voeg alle bestanden toe
git add .

# Commit als initiële versie met uitgebreide message
git commit -m "Initial release v1.0.0

Agent-Capabilities Repository - SAFe DVS Agent Ecosysteem

Dit is de eerste officiële release van de Agent-Capabilities repository,
die herbruikbare agent-componenten beheert voor het SAFe DVS ecosysteem.

Bevat:
- Governance (Beleid, Workspace Architectuur)
- 19 Agent Charters (governance/agent-charters/)
  * Fase A-E: founding-hypothesis-owner, business-case-analyst, cdm-architect, etc.
  * Utilities U01-89: moeder-workspace, c4-modelleur, md-to-archi-xml, layout-optimizer
  * Meta U90-99: make-agent, prompt-builder, runner-builder, orchestration-builder, pipeline-bouwer, python-script-schrijver
  * Phase 0: logos
- Agent Componenten (agent-componenten/)
  * Prompts: minimale contract-based prompts
  * Runners: Python executables met argparse CLI
  * Orchestrations: YAML workflow definities
  * Buildplans: JSON metadata met charter-path traceerbaarheid
  * Pipelines: GitHub Actions + GitLab CI (multi-platform)
- Workspace Meta-Agents (agent-charters/)
  * moeder-agent-capabilities: orchestrator met Git/GitHub/GitLab expertise
  * agent-charter-schrijver: charter author volgens normering
- Infrastructure Scripts (scripts/)
  * make-agent.py: component generator
  * sync-agents.py: distributie naar project workspaces
  * pipeline-builder.py: CI/CD pipeline generator
  * fetch-agents.py: component fetcher
  * run-workflow.py: workflow orchestrator (hypothesis-to-cdm)
- Theorie & Documentatie
  * een-lerend-agent-ecosysteem.md: evolutionair leren principes

Architectuur:
- Charter-first: charters zijn single source of truth
- Component generatie vanuit charters (make-agent.py)
- Distributie naar project workspaces (sync-agents.py)
- Multi-platform CI/CD: GitHub Actions + GitLab CI parallel
- Git/GitHub expertise met GitLab migratie readiness
- Workflow orchestration: chain agents together (run-workflow.py)

Version: 1.0.0
Date: 2026-01-09"
```

### Stap 3: Tag creëren
```powershell
# Maak annotated tag (aanbevolen voor releases)
git tag -a v1.0.0 -m "Release v1.0.0 - Initial Agent-Capabilities Repository

Eerste officiële release van de Agent-Capabilities repository.
Bevat 19 agent charters, component generators, workflow orchestrator.

Zie CHANGELOG.md voor details."
```

### Stap 4: Main branch vervangen
```powershell
# Verwijder oude main branch lokaal
git branch -D main

# Hernoem nieuwe branch naar main
git branch -m main

# Force push naar remote (PAS OP: destructief!)
git push origin main --force

# Push tag
git push origin v1.0.0
```

### Stap 5: Verificatie
```powershell
# Check dat history schoon is (zou 1 commit moeten tonen)
git log --oneline

# Check tag
git tag -l

# Check remote
git remote show origin
```

---

## 4. Rollback Procedure (indien nodig)

Als iets misgaat:

```powershell
# Herstel vanaf backup
git checkout backup-before-v1.0
git branch -D main
git checkout -b main
git push origin main --force
```

---

## 5. GitHub Specifieke Acties

### Na force push:
1. **GitHub Release creëren**:
   - Ga naar repository op GitHub (agent-capabilities)
   - Releases → Draft a new release
   - Tag: v1.0.0
   - Title: "v1.0.0 - Initial Agent-Capabilities Repository"
   - Beschrijving: Agent component management voor SAFe DVS ecosysteem
     * 19 agent charters
     * Component generators (make-agent, prompt-builder, runner-builder, orchestration-builder, pipeline-builder)
     * Workflow orchestrator (run-workflow)
     * Multi-platform CI/CD (GitHub Actions + GitLab CI)
     * Git/GitHub/GitLab expertise
   - Publish release

2. **Branch Protection updaten** (optioneel):
   - Settings → Branches
   - Overweeg: Require pull request before merging
   - Overweeg: Require status checks

3. **Default branch check**:
   - Zorg dat `main` de default branch is

---

## 6. GitLab Compatibiliteit

**Waarom Agent Capabilities heeft Git/GitHub/GitLab expertise (charter v2.0)
- Strategische flexibiliteit voor de toekomst
- Self-hosted mogelijkheden
- Betere CI/CD integratie (GitLab CI)
- Multi-platform pipelines al in plaats (GitHub Actions + GitLab CI)

**Dit plan werkt identiek voor GitLab**:
- Orphan branch methode is platform-agnostisch
- Tags werken hetzelfde
- Force push werkt hetzelfde
- Alleen UI verschillen voor release-creatie

**Toekomstige migratie naar GitLab**:
```powershell
# Voeg GitLab remote toe (toekomstig)
git remote add gitlab https://gitlab.com/org/agent-capabilities.git

# Push naar beide platforms
git push origin main --force
git push gitlab main --force
git push origin --tags
git push gitlab --tags
```

**Agent-Capabilities is GitLab-ready**:
- .gitlab-ci.yml templates in pipeline-builder.py
- Platform-agnostic repository structuur
- Geen GitHub vendor lock-in push gitlab --tags
```

---

## 7. Documentatie Updates

Na succesvolle cleanup:

### Te creëren/updaten:
1. **CHANGELOG.md** (nieuw):
   ```markdownAgent-Capabilities Repository
   - 19 Agent charters in governance/agent-charters/
   - Agent component generators (make-agent.py, prompt-builder.py, runner-builder.py, orchestration-builder.py)
   - Pipeline builder met multi-platform support (GitHub Actions + GitLab CI)
   - Workflow orchestrator (run-workflow.py) met hypothesis-to-cdm workflow
   - Workspace meta-agents (moeder-agent-capabilities, agent-charter-schrijver)
   - Git/GitHub/GitLab expertise in moeder-agent charter v2.0
   - Governance framework (beleid.md, workspace-architectuur.md)
   - Theorie: evolutionair leren (een-lerend-agent-ecosysteem.md)
   - Sync mechanism naar project workspaces (sync-agents.py)
   - Fetch mechanism voor components (fetch-agents.py)
   
   ### Architecture
   - Charter-first development
   - Component generation from charters
   - Multi-platform CI/CD (GitHub + GitLab ready)
   - Workflow orchestration capability
   ```

2. **README.md**: Update met v1.0.0 referentie en agent inventoryace Architectuur)
   - Agent Charter Normering
   - Delivery Framework (SAFe)
   - Meta-agent charters (Moeder Standard, Charter Schrijver)
   ```

2. **README.md**: Update met v1.0.0 referentie

3. **VERSION** bestand (optioneel):
   ```
   1.0.0
   ```

---

## 8. Risico's en Mitigaties

| Risico | Impact | Mitigatie |
|--------|--------|-----------|
| Force push faalt | Hoog | Backup branch eerst maken |
| Team heeft lokale commits | Medium | Communicatie: iedereen moet re-clonen |
| Tag conflict | Laag | Check eerst of tag bestaat |
| Verlies van history | Laag | Backup branch blijft bestaan |
| GitHub Actions falen | Laag | Workflows testen na push |

---

## 9. Communicatie

**Voor de cleanup**:
- Waarschuw team dat force push komt
- Vraag team om lokale wijzigingen te committen/pushen
- Plan moment (bijv. buiten werktijd)

**Na de cleanup**:
- Informeer team dat repo is opgeschoond
- Instructies om lokale repo te vernieuwen:
  ```powershell
  git fetch origin
  git reset --hard origin/main
  ```

---

## 10. Post-Cleanup Checklist

- [ ] BStatus Moeder Agent Capabilities Charter

**Charter is al bijgewerkt** (v2.0, commit 45a3afe):

✅ **Binnen Scope (reeds toegevoegd)**:
- Git/GitHub repository beheer en best practices
- Git history management en cleanup operaties
- Tag en release management
- Platform-agAgent Capabilities charter v2.0 is actief (✅ reeds gedaan)
- Repository structuur optimalisatie
- Multi-platform CI/CD (GitHub Actions + GitLab CI)

✅ **Expertise (reeds in charter)**:
- Git expert: branching, tagging, history management
- GitHub kennis: releases, actions, branch protection
- GitLab awareness: toekomstige migratie-ready
- Repository governance en best practices
- Repository hygiene checklist (10 items)

**Charter locatie**: `agent-charters/0.moeder-agent-capabilities.agent.charter`
**Binnen Scope (toevoegen)**:
- Git/GitHub repository beheer en best practices
- Git history management en cleanup operaties
- Tag en release management
- Platform-agnostische Git workflows (GitHub/GitLab ready)
- Repository structuur optimalisatie

**Expertise**:
- Git expert: branching, tagging, history management
- GitHub kennis: releases, actions, branch protection
- GitLab awareness: toekomstige migratie-ready
- Repository governance en best practices

---

## 12. Conclusie

Deze aanpak is:
- ✅ Veilig (backup branch)
- ✅ Schoon (één commit voor v1.0.0)
- ✅ Toekomstbestendig (werkt voor GitHub én GitLab)
- ✅ Omkeerbaar (via backup)
- ✅ Professioneel (proper tagging en releases)

**Aanbeveling**: Uitvoeren na menselijke review en team-communicatie.
