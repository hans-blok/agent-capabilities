# Advies: Pipeline Templates in Agent-Capabilities

**Datum**: 2026-01-08  
**Context**: Architecturale beslissing over locatie van CI/CD pipeline templates  
**Advies**: Ja, pipeline templates horen in agent-capabilities workspace

---

## 1. Kernvraag

Moeten we CI/CD pipeline templates in agent-capabilities maken en via fetch/sync distribueren naar project workspaces? En hoe gaan we om met verschillende platforms (GitHub Actions, GitLab CI, Azure Pipelines)?

## 2. Advies: JA ✅ met Platform-Agnostische Architectuur

Pipeline templates passen perfect in de huidige agent-capabilities architectuur als een nieuw component-type. **Belangrijker nog**: gebruik een **platform-agnostische definitie** die kan worden vertaald naar meerdere CI/CD platforms.

**Kernprincipe**: Eén pipeline-definitie → meerdere platform-specifieke templates

---

## 3. Rationale

### 3.1 Consistentie met Bestaande Architectuur

Pipeline templates zijn een logische uitbreiding van het huidige component model:

```
agent-componenten/
├─ prompts/              ✓ Herbruikbare agent-prompts
├─ runners/              ✓ Herbruikbare executables
├─ orchestrations/       ✓ Herbruikbare workflows
├─ buildplans/           ✓ Herbruikbare metadata
└─ pipelines/            ⭐ NIEUW: Herbruikbare CI/CD pipelines
   ├─ definitions/       ⭐ Platform-agnostische definities
   │  ├─ a.founding-hypothesis-owner.pipeline.yml
   │  └─ b.cdm-architect.pipeline.yml
   └─ generated/         ⭐ Platform-specifieke templates
      ├─ github-actions/
      ├─ gitlab-ci/
      └─ azure-pipelines/
```

**Design Principes Behouden**:
- ✅ Single source of truth (agent-capabilities)
- ✅ Separation of concerns (definitie vs. executie)
- ✅ DRY principe (één template, meerdere projecten)
- ✅ Sync-mechanisme hergebruik

### 3.2 Herbruikbaarheid

**Probleem**: Elk project maakt nu eigen pipelines
- Duplicatie van logica
- Inconsistente configuraties
- Moeilijk onderhoud
- Geen leren tussen projecten

**Oplossing**: Templates als startpunt
- Agents in dezelfde fase hebben vergelijkbare pipeline-behoeften
- b.cdm-architect heeft altijd dezelfde trigger/output patroon
- Template biedt best practices
- Project kan aanpassen waar nodig

### 3.3 Platform-Agnostische Architectuur 🌟

**Uitdaging**: Organisaties gebruiken verschillende CI/CD platforms
- Huidig: GitHub Actions
- Toekomst: GitLab CI (migratie gepland)
- Enterprise: Azure Pipelines

**Oplossing**: **Twee-laags architectuur**

**Laag 1: Platform-Agnostische Definitie**
```yaml
# definitions/a.founding-hypothesis-owner.pipeline.yml
pipeline:
  name: Founding Hypothesis Owner Agent
  
  trigger:
    on: manual | commit | schedule
    schedule: "0 2 * * *"
    branches: [main, develop]
  
  environment:
    runner: ubuntu-latest
    python: "3.11"
  
  steps:
    - checkout
    - setup-python: ${{ environment.python }}
    - install-deps: requirements.txt
    - run: |
        python runners/a.founding-hypothesis-owner.py \
          --input ${{ input.business_case }}
    - upload-artifact:
        name: founding-hypothesis
        path: output/founding-hypothesis.md
  
  notifications:
    on-failure:
      slack: "#agent-alerts"
```

**Laag 2: Platform-Specifieke Generators**
```python
# Pipeline generator architectuur
class PipelineGenerator:
    def translate(self, definition: dict) -> str:
        """Vertaal platform-agnostische definitie naar platform-specifiek."""
        pass

class GitHubActionsGenerator(PipelineGenerator):
    def translate(self, definition):
        # Vertaal naar .github/workflows/xxx.yml
        pass

class GitLabCIGenerator(PipelineGenerator):
    def translate(self, definition):
        # Vertaal naar .gitlab-ci.yml
        pass

class AzurePipelinesGenerator(PipelineGenerator):
    def translate(self, definition):
        # Vertaal naar azure-pipelines.yml
        pass
```

**Voordelen**:
- ✅ **Platform Flexibiliteit**: Switch eenvoudig tussen platforms
- ✅ **Toekomstbestendig**: Nieuwe platforms toevoegen zonder legacy aanpassen
- ✅ **Evolutionair Leren**: Leer "wat werkt", niet "hoe het werkt op platform X"
- ✅ **Migratie-Ready**: GitLab migratie? Regenereer alle pipelines
- ✅ **Consistentie**: Zelfde logica op elk platform

### 3.4 Charter-Driven Generation

Pipeline configuratie kan in charter worden opgenomen:

```yaml
# In agent charter
pipeline:
  platform: github-actions
  trigger: 
    type: manual | scheduled | on-commit
    schedule: "0 2 * * *"  # Voor scheduled
  agents: 
    - b.cdm-architect
    - c.logisch-data-modelleur
  outputs:
    - type: artifact
      path: output/cdm.md
  notifications:
    slack: "#agent-alerts"
```

`make-agent.py` genereert dan automatisch pipeline template.

### 3.5 Evolutionair Leren

Pipelines worden onderdeel van **Experience Packages**:

```
experience/
└─ app-x/
   ├─ context.md
   ├─ agent-landschap.md
   ├─ pipeline-config.yml       ⭐ Pipeline setup die werkte
   ├─ kwaliteitsmetrics.md
   └─ lessons-learned.md
```

Goede pipeline-patronen kunnen worden:
- Gepromoot naar templates
- Hergebruikt in andere projecten
- Geëvalueerd op effectiviteit

---

## 4. Voorgestelde Implementatie

### 4.1 Directory Structuur

```
agent-componenten/
└─ pipelines/
   ├─ definitions/                      ⭐ Platform-agnostisch (source of truth)
   │  ├─ 0.workspace-moeder.pipeline.yml
   │  ├─ a.founding-hypothesis-owner.pipeline.yml
   │  ├─ b.cdm-architect.pipeline.yml
   │  ├─ c.logisch-data-modelleur.pipeline.yml
   │  ├─ c.schema-custodian.pipeline.yml
   │  ├─ d.service-architect.pipeline.yml
   │  ├─ d.technisch-data-modelleur.pipeline.yml
   │  └─ u.c4-modelleur.pipeline.yml
   │
   └─ generated/                        ⭐ Platform-specifiek (gegenereerd)
      ├─ github-actions/
      │  ├─ a.founding-hypothesis-owner.workflow.yml
      │  └─ ...
      ├─ gitlab-ci/
      │  ├─ a.founding-hypothesis-owner.gitlab-ci.yml
      │  └─ ...
      └─ azure-pipelines/
         ├─ a.founding-hypothesis-owner.azure-pipeline.yml
         └─ ...
```

**Naming Conventions**:
- **Definitions**: `<fase>.<agent-naam>.pipeline.yml` (platform-agnostisch)
- **Generated**: `<fase>.<agent-naam>.<platform-extensie>` (platform-specifiek)
- Fase-prefix voor groepering
- Generated files zijn disposable (kunnen altijd opnieuw gegenereerd)

### 4.2 Pipeline Definitie Anatomie

**Platform-Agnostische Definitie** (single source of truth):

```yaml
# definitions/a.founding-hypothesis-owner.pipeline.yml
pipeline:
  name: Founding Hypothesis Owner Agent
  description: Vertaalt strategische richting naar testbare founding hypothesis
  
  trigger:
    type: manual
    inputs:
      business_case:
        description: Path to business case document
        required: true
        type: string
  
  environment:
    runner: ubuntu-latest
    python-version: "3.11"
  
  steps:
    - id: checkout
      action: checkout
    
    - id: setup-python
      action: setup-python
      with:
        version: ${{ environment.python-version }}
    
    - id: install-deps
      action: run
      command: pip install -r requirements.txt
    
    - id: run-agent
      action: run
      command: |
        python agent-componenten/runners/a.founding-hypothesis-owner.py \
          --input ${{ inputs.business_case }}
    
    - id: upload-artifacts
      action: upload-artifact
      with:
        name: founding-hypothesis
        path: output/founding-hypothesis.md
  
  notifications:
    on-failure:
      slack:
        channel: agent-alerts
        message: Agent a.founding-hypothesis-owner failed
```

**Gegenereerde GitHub Actions Template**:

```yaml
# generated/github-actions/a.founding-hypothesis-owner.workflow.yml
name: Founding Hypothesis Owner Agent

on:
  workflow_dispatch:  # Manual trigger
    inputs:
      business_case:
        description: 'Path to business case document'
        required: true
        type: string

jobs:
  run-agent:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install Dependencies
        run: |
          pip install -r requirements.txt
      
      - name: Run Agent
        run: |
          python agent-componenten/runners/a.founding-hypothesis-owner.py \
            --input ${{ inputs.business_case }}
      
      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: founding-hypothesis
          path: output/founding-hypothesis.md
      
      - name: Notify on Failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          channel-id: 'agent-alerts'
          slack-message: 'Agent a.founding-hypothesis-owner failed'
```

**Gegenereerde GitLab CI Template**:

```yaml
# generated/gitlab-ci/a.founding-hypothesis-owner.gitlab-ci.yml
founding-hypothesis-owner:
  stage: agents
  image: python:3.11
  
  rules:
    - if: $CI_PIPELINE_SOURCE == "web"
  
  variables:
    BUSINESS_CASE: $BUSINESS_CASE_INPUT
  
  script:
    - pip install -r requirements.txt
    - |
      python agent-componenten/runners/a.founding-hypothesis-owner.py \
        --input $BUSINESS_CASE
  
  artifacts:
    name: founding-hypothesis
    paths:
      - output/founding-hypothesis.md
  
  after_script:
    - |
      if [ $CI_JOB_STATUS == "failed" ]; then
        curl -X POST -H 'Content-type: application/json' \
          --data '{"text":"Agent a.founding-hypothesis-owner failed"}' \
          $SLACK_WEBHOOK
      fi
```

**Template Karakteristieken**:
- ✅ Platform best practices per CI/CD systeem
- ✅ Agent-specifieke configuratie
- ✅ Output artifact handling
- ✅ Error notificaties
- ✅ Aanpasbaar door project
- ✅ Gegenereerd uit platform-agnostische definitie

### 4.3 Generator Architectuur

**make-agent.py uitbreiding** voor pipeline generatie:

```python
from pathlib import Path
import yaml

class PipelineGenerator:
    """Base class voor platform-specifieke generators."""
    
    def translate(self, definition: dict) -> str:
        """Vertaal platform-agnostische definitie naar platform-specifiek."""
        raise NotImplementedError

class GitHubActionsGenerator(PipelineGenerator):
    def translate(self, definition: dict) -> str:
        # Map generic 'checkout' -> 'actions/checkout@v4'
        # Map generic 'setup-python' -> 'actions/setup-python@v5'
        # Map generic 'upload-artifact' -> 'actions/upload-artifact@v4'
        ...
        return github_actions_yaml

class GitLabCIGenerator(PipelineGenerator):
    def translate(self, definition: dict) -> str:
        # Map generic steps -> GitLab CI script blocks
        # Map triggers -> GitLab rules
        # Map artifacts -> GitLab artifacts config
        ...
        return gitlab_ci_yaml

PLATFORM_GENERATORS = {
    'github-actions': GitHubActionsGenerator,
    'gitlab-ci': GitLabCIGenerator,
    'azure-pipelines': AzurePipelinesGenerator,
}

def generate_pipelines(agent_name, phase, platforms=['github-actions', 'gitlab-ci']):
    """Genereer platform-specifieke pipelines uit definitie."""
    
    # 1. Lees platform-agnostische definitie
    definition_path = Path(f'agent-componenten/pipelines/definitions/{phase}.{agent_name}.pipeline.yml')
    with open(definition_path) as f:
        definition = yaml.safe_load(f)
    
    # 2. Genereer voor elk platform
    for platform in platforms:
        generator_class = PLATFORM_GENERATORS[platform]
        generator = generator_class()
        
        platform_yaml = generator.translate(definition['pipeline'])
        
        # 3. Schrijf naar generated/
        output_path = Path(f'agent-componenten/pipelines/generated/{platform}/{phase}.{agent_name}.workflow.yml')
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(platform_yaml)
        
        print(f"✓ Generated {platform} pipeline for {agent_name}")
```

**Gebruik**:
```bash
# Genereer voor specifiek platform
make-agent.py --agent founding-hypothesis-owner --platform gitlab-ci

# Genereer voor meerdere platforms
make-agent.py --agent founding-hypothesis-owner --platforms github-actions,gitlab-ci

# Regenereer alle pipelines voor nieuw platform (bijv. bij migratie)
make-agent.py --regenerate-all-pipelines --platform gitlab-ci
```

### 4.4 Sync Mechanisme

Uitbreiden van `sync-agents.py` met platform-keuze:

```python
# sync-agents.py enhancement
def sync_pipelines(source_path, target_path, platform='github-actions'):
    """
    Sync platform-specifieke pipeline templates naar project workspace.
    
    Args:
        source_path: agent-capabilities root
        target_path: project workspace root
        platform: 'github-actions', 'gitlab-ci', of 'azure-pipelines'
    """
    # Lees van generated/<platform>/
    source_dir = source_path / 'agent-componenten/pipelines/generated' / platform
    
    # Map platform naar target directory
    platform_targets = {
        'github-actions': '.github/workflows',
        'gitlab-ci': '.gitlab-ci',  # Of root voor .gitlab-ci.yml
        'azure-pipelines': '.azuredevops/pipelines',
    }
    
    target_dir = target_path / platform_targets[platform]
    target_dir.mkdir(parents=True, exist_ok=True)
    
    # Copy with confirmation
    for pipeline_file in source_dir.glob('*.yml'):
        target_file = target_dir / pipeline_file.name
        
        if target_file.exists():
            confirm = input(f"Overwrite {target_file}? (y/n): ")
            if confirm.lower() != 'y':
                continue
        
        shutil.copy(pipeline_file, target_file)
        print(f"✓ Synced {pipeline_file.name} ({platform})")
```

**Gebruik**:
```bash
# Sync voor huidig platform (GitHub Actions)
sync-agents.py \
  --source c:/gitrepo/agent-capabilities \
  --include pipelines \
  --platform github-actions

# Sync voor toekomstig platform (GitLab CI)
sync-agents.py \
  --source c:/gitrepo/agent-capabilities \
  --include pipelines \
  --platform gitlab-ci

# Migratie scenario: regenereer eerst, dan sync
make-agent.py --regenerate-all-pipelines --platform gitlab-ci
sync-agents.py --target ~/project --platform gitlab-ci
```

### 4.5 Charter Pipeline Configuratie (Optioneel)

Charter kan **optioneel** pipeline metadata bevatten:

```yaml
# In agent charter (optioneel)
pipeline:
  trigger: manual  # Of: commit, schedule
  schedule: "0 2 * * *"  # Alleen bij schedule
  custom-config:
    timeout: 30m
    retry: 2
```

Maar standaard gebruikt `make-agent.py` een **default template** per fase:
- a.trigger agents → manual trigger
- b.architectuur agents → on-commit trigger
- c.specificatie agents → on-commit + nightly
- etc.

Charter metadata **overschrijft** defaults indien aanwezig.

---

## 5. Governance Beleid Update

Toevoegen aan `/governance/beleid.md`:

### Nieuwe Sectie: Pipeline Templates

```markdown
## 7. Pipeline Templates
**Rationale**: Herbruikbare CI/CD configuratie voor consistente agent-executie

**Implementatie**:
- Pipeline templates opgeslagen in `agent-componenten/pipelines/`
- Ondersteunde platforms: GitHub Actions, Azure DevOps
- Per agent één of meerdere pipeline templates
- Templates gegenereerd door make-agent.py uit charter
- Gesynchroniseerd naar project workspaces via sync-agents.py
- Naming: `<fase>.<agent-naam>.workflow.yml`

**Project Gebruik**:
- Template wordt gekopieerd naar `.github/workflows/` (GitHub)
- Template wordt gekopieerd naar `.azuredevops/pipelines/` (Azure)
- Project MAG template aanpassen voor specifieke behoeften
- Template dient als startpunt en best practice

**Consequenties**:
- Charter kan pipeline-configuratie bevatten
- make-agent.py genereert pipeline template automatisch
- sync-agents.py kopieert naar platform-specifieke locatie
- Template als startpunt, niet als lock-in
- Overwrite bij sync vraagt confirmatie
- Pipeline templates onderdeel van Experience Packages

**Beperkingen**:
- Template bevat generieke agent-executie
- Project-specifieke secrets/vars niet in template
- Environment-specifieke config in project
```

---

## 6. Voordelen

### 6.1 Voor Agent-Capabilities Workspace
- ✅ Complete component-set (prompts, runners, orchestrations, pipelines, buildplans)
- ✅ Single source of truth voor alle agent-gerelateerde artefacten
- ✅ Platform-agnostische definities → toekomstbestendig
- ✅ Centrale plaats voor best practices
- ✅ Eenvoudiger onderhoud (één definitie → meerdere platforms)

### 6.2 Voor Project Workspaces
- ✅ Snelle start: sync naar gewenst platform
- ✅ Best practices out-of-the-box
- ✅ Consistente pipeline-structuur
- ✅ Minder duplicatie
- ✅ **Platform migratie**: Regenereer alle pipelines voor nieuw platform
- ✅ **Flexibiliteit**: Switch platform zonder logica te herschrijven

### 6.3 Voor Ecosysteem Evolutie
- ✅ Pipeline-patronen worden expliciete ervarings-eenheden
- ✅ Succesvolle configuraties kunnen worden gepromoot
- ✅ Slecht werkende patronen kunnen worden geëlimineerd
- ✅ Leren tussen projecten **en** tussen platforms
- ✅ **Platform-agnostisch leren**: "wat werkt" los van "hoe platform X werkt"

### 6.4 Voor Migratie Scenario's 🎯
- ✅ **GitLab migratie**: `make-agent.py --regenerate-all --platform gitlab-ci`
- ✅ **Multi-platform**: Ondersteun GitHub én GitLab parallel
- ✅ **Nieuwe platforms**: Voeg generator toe, regenereer alles
- ✅ **Zero rewrite**: Pipeline logica blijft identiek

---

## 7. Risico's & Mitigaties

### Risico 1: Template Drift
**Risico**: Project past template aan, verliest sync met centraal  
**Mitigatie**: 
- Template is startpunt, geen lock-in
- Project MAG aanpassen
- Sync vraagt confirmatie bij overwrite
- Best practices kunnen worden teruggeporteerd naar centraal

### Risico 2: Platform Lock-in
**Risico**: Te afhankelijk van specifiek CI/CD platform  
**Mitigatie**: ✅ **OPGELOST door platform-agnostische architectuur**
- Definities zijn platform-onafhankelijk
- Generators voor GitHub Actions, GitLab CI, Azure Pipelines
- GitLab migratie: regenereer alle pipelines in minuten
- Nieuwe platforms: voeg generator toe, hergebruik definities
**Risico**: Te veel abstraction layers  
**Mitigatie**:
- Templates blijven simpel en leesbaar
- Geen magic, alles expliciet
- Project kan altijd eigen pipeline maken

---

## 8. Implementatie Roadmap

### Fase 1: Foundation (Week 1)
- [ ] Directory structuur aanmaken (definitions/ + generated/)
- [ ] Governance beleid updaten
- [ ] Platform-agnostische schema definiëren (YAML spec)
- [ ] Voorbeeld definitie maken voor 2-3 agents
- [ ] Documentatie schrijven

### Fase 2: GitHub Actions Generator (Week 2)
- [ ] PipelineGenerator base class
- [ ] GitHubActionsGenerator implementeren
- [ ] make-agent.py integreren met generator
- [ ] Testen met bestaande agents
- [ ] Alle agents genereren voor GitHub Actions

### Fase 3: GitLab CI Generator (Week 3)
- [ ] GitLabCIGenerator implementeren
- [ ] Platform mapping logica (generic → GitLab specifiek)
- [ ] Regenerate functie voor alle agents
- [ ] Testen met GitLab instance
- [ ] Migratie documentatie

### Fase 4: Sync & Distribution (Week 4)
- [ ] sync-agents.py uitbreiden voor platform-keuze
- [ ] Multi-platform sync ondersteuning
- [ ] Testen met project workspace
- [ ] Documentatie voor project teams

### Fase 5: Experience Loop (Week 5)
- [ ] Experience Package format met pipeline metrics
- [ ] Platform-agnostische metrics verzamelen
- [ ] Feedback mechanisme voor definitie verbetering
- [ ] Azure Pipelines generator (optioneel)

---

## 9. Alternatieven Overwogen

### Alternatief A: Pipelines in Project Workspaces
**Pro**: Volledige project controle  
**Con**: Duplicatie, geen hergebruik, geen leren  
**Conclusie**: ❌ Strijd met ecosysteem principes

### Alternatief B: Shared Pipeline Repository
**Pro**: Centraal onderhoud  
**Con**: Extra repository, breekt agent-componenten model  
**Conclusie**: ❌ Onnodig complex

### Alternatief D: Direct Platform-Specifieke Templates (Geen Abstractie)
**Pro**: Eenvoudig, geen generator complexiteit  
**Con**: Platform lock-in, duplicatie bij migratie, geen GitLab voorbereiding  
**Conclusie**: ❌ Blokkeert GitLab migratie

### Alternatief C: Geen Templates, Alleen Documentatie
**Pro**: Minimale overhead  
**Con**: Elk project moet zelf implementeren, geen evolutie  
**Conclusie**: ❌ Mist kans op institutioneel leren

---

## 10. Conclusie

**Aanbeveling**: Implementeer **platform-agnostische** pipeline templates in agent-capabilities workspace.

**Kernredenen**:
1. **Toekomstbestendig**: GitLab migratie zonder herschrijven
2. **Platform flexibiliteit**: GitHub Actions → GitLab CI → toekomstig platform
3. Consistent met huidige architectuur
4. Maximaliseert hergebruik tussen projecten **en** platforms
5. Faciliteert evolutionair leren (platform-onafhankelijk)
6. Verlaagt barrier voor nieuwe projecten
7. Expliciet onderdeel van Experience Packages

**Critical Success Factor**: Platform-agnostische definitie als single source of truth.

**Volgende Stap**: Governance beleid updaten en beginnen met Fase 1 (Foundation).

---

## Vragen voor Review

1. **Scope**: Alleen CI/CD pipelines, of ook deployment pipelines?
2. **Platform Priority**: Start met GitHub Actions + GitLab CI? Azure Pipelines later?
3. **Definition Schema**: YAML formaat voldoende, of formele schema (JSON Schema)?
4. **Generator Complexity**: Basis mapping eerst, of direct advanced features?
5. **Ownership**: Wie is verantwoordelijk voor definitie updates en nieuwe generators?
6. **Versioning**: Definitie versioning nodig, of altijd latest?
7. **Migration Timeline**: Wanneer GitLab migratie? Bepaalt generator prioriteit

---

**Document Status**: Draft voor review  
**Auteur**: Moeder Agent (agent-cap-moeder)  
**Review Gevraagd**: 2026-01-08
