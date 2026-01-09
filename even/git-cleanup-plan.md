# Plan: Git Repository Opschoning naar v1.0.0

**Doel**: Repository opschonen tot één initiële commit en taggen als versie 1.0.0  
**Datum**: 2026-01-09  
**Verantwoordelijk**: Moeder Standard Agent + Menselijke review

---

## 1. Huidige Situatie

- Repository heeft 20+ commits met verschillende wijzigingen
- Huidige HEAD: `9fa21df - De 7 principes toegevoegd`
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

Standards Repository - Agent Eco-systeem

Dit is de eerste officiële release van de Standards repository,
die het fundament legt voor het Agent Eco-systeem.

Bevat:
- Governance (Constitutie, Workspace Architectuur, Beleid)
- Agent Charter Normering
- Delivery Framework (SAFe-gebaseerd)
- Meta-agent charters (Moeder Standard, Charter Schrijver)
- Templates voor agent-ontwikkeling
- Fase-charters (A-G)

Architectuur:
- Centrale governance voor workspace-overstijgende standaarden
- Meta-agents voor agent-landschap beheer
- Scheiding tussen standards en agent-capabilities
- Git/GitHub kennerbasis met toekomst-focus op GitLab

Version: 1.0.0
Date: 2026-01-09"
```

### Stap 3: Tag creëren
```powershell
# Maak annotated tag (aanbevolen voor releases)
git tag -a v1.0.0 -m "Release v1.0.0 - Initial Standards Repository

Eerste officiële release van het Agent Eco-systeem Standards repository.

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
   - Ga naar repository op GitHub
   - Releases → Draft a new release
   - Tag: v1.0.0
   - Title: "v1.0.0 - Initial Standards Repository"
   - Beschrijving: Zie commit message
   - Publish release

2. **Branch Protection updaten** (optioneel):
   - Settings → Branches
   - Overweeg: Require pull request before merging
   - Overweeg: Require status checks

3. **Default branch check**:
   - Zorg dat `main` de default branch is

---

## 6. GitLab Compatibiliteit

**Waarom denken we nu al aan GitLab?**
- Moeder Standard is kenner van Git en platforms
- Strategische flexibiliteit voor de toekomst
- Self-hosted mogelijkheden
- Betere CI/CD integratie (GitLab CI)

**Dit plan werkt identiek voor GitLab**:
- Orphan branch methode is platform-agnostisch
- Tags werken hetzelfde
- Force push werkt hetzelfde
- Alleen UI verschillen voor release-creatie

**Toekomstige migratie naar GitLab**:
```powershell
# Voeg GitLab remote toe (toekomstig)
git remote add gitlab https://gitlab.com/org/standard.git

# Push naar beide platforms
git push origin main --force
git push gitlab main --force
git push origin --tags
git push gitlab --tags
```

---

## 7. Documentatie Updates

Na succesvolle cleanup:

### Te creëren/updaten:
1. **CHANGELOG.md** (nieuw):
   ```markdown
   # Changelog
   
   ## [1.0.0] - 2026-01-09
   
   ### Added
   - Initial release Standards Repository
   - Governance framework (Constitutie, Workspace Architectuur)
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

- [ ] Backup branch bestaat: `backup-before-v1.0`
- [ ] Main branch heeft 1 commit
- [ ] Tag v1.0.0 bestaat lokaal
- [ ] Tag v1.0.0 bestaat op remote
- [ ] GitHub Release is gepubliceerd
- [ ] CHANGELOG.md is toegevoegd
- [ ] README.md is bijgewerkt
- [ ] Team is geïnformeerd
- [ ] Moeder Standard charter is bijgewerkt met Git/GitHub kennis

---

## 11. Moeder Standard Charter Aanpassingen

Voeg toe aan charter:

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
