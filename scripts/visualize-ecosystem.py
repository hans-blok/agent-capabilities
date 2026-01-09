#!/usr/bin/env python3
"""
visualize-ecosystem.py

Gebruikt de C4-modelleur om het agent-ecosysteem te visualiseren.
Genereert C4 diagrammen op Context, Container en Component niveau.
Kan zowel ecosystem relationships als generation flow visualiseren.

GEBRUIK:
  python scripts/visualize-ecosystem.py                    # Genereer ecosystem diagram
  python scripts/visualize-ecosystem.py --mode generation  # Genereer generation flow
  python scripts/visualize-ecosystem.py --mode both        # Genereer beide

Agent: visualize-ecosystem.py
Versie: 2.0
Datum: 09-01-2026
"""

import argparse
import sys
from pathlib import Path

def log(message: str, prefix: str = "INFO"):
    """Log een bericht."""
    colors = {
        "INFO": "\033[96m",
        "SUCCESS": "\033[92m",
        "WARNING": "\033[93m",
        "ERROR": "\033[91m"
    }
    reset = "\033[0m"
    color = colors.get(prefix, "")
    print(f"{color}[{prefix}] {message}{reset}")

def get_ecosystem_context() -> str:
    """Bouw de context beschrijving van het agent-ecosysteem."""
    return """# Agent-Capabilities Ecosysteem

## Overzicht
Dit ecosysteem bouwt, beheert en distribueert agents volgens SAFe Development Value Stream principes.

## Kerncomponenten

### 1. Charters (standard repository)
- **Locatie**: c:\\gitrepo\\standard\\artefacten\\3-charters-agents\\
- **Functie**: Single source of truth voor agent definities
- **Naamgeving**: std.agent.charter.<fase>.<naam>.md
- **Fases**: a (Trigger), b (Architectuur), c (Specificatie), d (Ontwerp), e (Bouw), f (Validatie), g (Deploy), u (Utility)

### 2. Agent-Capabilities (deze workspace)
- **Locatie**: c:\\gitrepo\\agent-capabilities\\
- **Functie**: Agent component generator en distributie hub

#### 2.1 Scripts
- **make-agent.py**: Genereert componenten vanuit charter (met auto git pull)
- **fetch-agents.py**: Distribueert agents naar project workspaces
- **visualize-ecosystem.py**: Genereert C4 diagrammen van ecosysteem

#### 2.2 Agent Componenten
**Prompts** (agent-componenten/prompts/):
- Minimale instructie files
- Refereren naar charter
- Format: <fase>.<naam>.prompt.md

**Runners** (agent-componenten/runners/):
- Python executables
- CLI interface
- Format: <fase>.<naam>.py

**Orchestrations** (agent-componenten/orchestrations/):
- YAML configuraties
- Workflow definities
- Format: <fase>.<naam>.orchestration.yaml

**Buildplans** (agent-componenten/buildplans/):
- JSON metadata
- Traceerbaarheid (charter path, URLs)
- Format: <fase>.<naam>.json

**Pipelines** (agent-componenten/pipelines/):
- definitions/: Platform-agnostisch (source of truth)
- generated/: Platform-specifiek (disposable)
  - github-actions/
  - gitlab-ci/
  - azure-pipelines/

**Agents** (agent-componenten/agents/):
- Agent definitie documenten
- Samenvatting van charter
- Format: <fase>.<naam>.agent.md

### 3. Project Workspaces
- **Voorbeelden**: c:\\gitrepo\\mak-ea\\
- **Functie**: Executie omgeving voor agents
- **Structuur**:
  - .github/prompts/: Gesyncte prompts
  - .github/workflows/: Platform-specifieke pipelines
  - agent-componenten/: Gesyncte componenten
  - artefacten/: Output van agents

## Workflows

### Agent Lifecycle
1. **Charter schrijven** in standard repository
2. **make-agent.py uitvoeren** in agent-capabilities
   - Leest charter (auto git pull)
   - Extraheert fase uit bestandsnaam
   - Valideert fase tegen charter inhoud
   - Genereert componenten met fase prefix
3. **Componenten committen** naar agent-capabilities
4. **fetch-agents.py uitvoeren** in project workspace
   - Kloont agent-capabilities
   - Kopieert alle componenten
   - Kopieert platform-specifieke pipelines
   - Kopieert workflow pipelines
5. **Agent gebruiken** in project

### Pipeline Generation
1. **Platform-agnostische definitie** schrijven in definitions/
2. **make-agent.py --regenerate-all-pipelines** uitvoeren
3. **Generator translates** naar platform-specifieke templates
4. **Generated pipelines** worden gedistribueerd via fetch-agents.py

## SAFe DVS Fases

**a (Trigger)**:
- a1: founding-hypothesis-owner
- a2: business-case-analyst

**b (Architectuur)**:
- b1: cdm-architect

**c (Specificatie)**:
- c2: logisch-data-modelleur
- c3: schema-custodian

**d (Ontwerp)**:
- d1: service-architect
- d2: technisch-data-modelleur

**e (Bouw)**:
- e1: ddl-dba

**u (Utility)**:
- u01: workspace-moeder
- u03: c4-modelleur
- u04: md-to-archi-xml
- u90: make-agent
- u91: prompt-builder
- u92: runner-builder
- u93: orchestration-builder
- u94: pipeline-bouwer

## Governance Principes

1. **Charter-first**: Charters zijn single source of truth
2. **Git pull mandatory**: Altijd pull voor charter access
3. **Idempotency**: Veilig regenereren van componenten
4. **Explicit over implicit**: Alles traceerbaar
5. **Flat file structure**: Fase-prefixen voor schaalbaarheid
6. **Platform-agnostic**: Definitie layer gescheiden van implementatie
7. **Separation of concerns**: standard/ (def), agent-capabilities/ (gen), workspaces/ (exec)

## Leren in het Ecosysteem

**Evolutionair leren principes**:
- Experience Packages: succesvolle toepassingen als ervaringspakketten
- Selectie boven training: evalueer composities, elimineer slechte, promoot goede
- Meta-agents: herkennen eerdere cases, stellen composities voor
- Institutionalisering: verankeren in artefacten en governance

"""

def generate_c4_diagrams(level: str = "all"):
    """Genereer C4 diagrammen van het ecosysteem."""
    log("DEPRECATED: Gebruik nu generate_structurizr_dsl() voor productie-ready diagrammen", "WARNING")
    repo_root = Path.cwd()
    output_dir = repo_root / "architectuur-agent-ecosysteem" / "c4-diagrams"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # C4 modelleur runner
    runner_path = repo_root / "agent-componenten" / "runners" / "u03.c4-modelleur.py"
    
    if not runner_path.exists():
        log(f"C4-modelleur runner niet gevonden: {runner_path}", "ERROR")
        log("Voer eerst uit: python scripts/make-agent.py --agent-name c4-modelleur", "INFO")
        return False
    
    context = get_ecosystem_context()
    
    levels = []
    if level == "all":
        levels = ["context", "container", "component"]
    else:
        levels = [level]
    
    log(f"Genereren C4 diagrammen: {', '.join(levels)}")
    
    for c4_level in levels:
        output_file = output_dir / f"agent-ecosystem-{c4_level}.md"
        
        log(f"Genereren {c4_level} diagram...")
        
        # Roep C4-modelleur aan
        # TODO: Implementeer LLM aanroep met prompt + context
        # Voor nu: placeholder
        
        placeholder_content = f"""# Agent Ecosysteem - C4 {c4_level.title()} Diagram

{context}

## {c4_level.title()} Diagram

```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_{c4_level.title()}.puml

' TODO: Genereer met C4-modelleur LLM aanroep
' Dit is een placeholder

@enduml
```

---
*Gegenereerd door: visualize-ecosystem.py*
*Datum: {Path(__file__).stat().st_mtime}*
"""
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(placeholder_content)
        
        log(f"Geschreven: {output_file.relative_to(repo_root)}", "SUCCESS")
    
    log(f"C4 diagrammen gegenereerd in: {output_dir.relative_to(repo_root)}", "SUCCESS")
    log("", "INFO")
    log("VOLGENDE STAPPEN:", "INFO")
    log("1. Implementeer LLM integratie in dit script", "INFO")
    log("2. Of roep handmatig de C4-modelleur aan met deze context", "INFO")
    log("3. Gebruik de gegenereerde PlantUML code in ArchiMate tools", "INFO")
    
    return True

def generate_structurizr_dsl(mode: str = "ecosystem"):
    """Genereer Structurizr DSL workspace file.
    
    Args:
        mode: 'ecosystem' voor agent relationships, 'generation' voor make-agent flow, 'both' voor beide
    """
    repo_root = Path.cwd()
    structurizr_dir = repo_root / "architectuur-agent-ecosysteem" / ".structurizr"
    structurizr_dir.mkdir(parents=True, exist_ok=True)
    
    if mode in ["ecosystem", "both"]:
        dsl_file = structurizr_dir / "workspace-ecosystem.dsl"
        log(f"Genereren ecosystem DSL naar: {dsl_file.relative_to(repo_root)}")
        
        dsl_content = generate_ecosystem_dsl()
        
        with open(dsl_file, 'w', encoding='utf-8') as f:
            f.write(dsl_content)
        
        log(f"Geschreven: {dsl_file.relative_to(repo_root)}", "SUCCESS")
    
    if mode in ["generation", "both"]:
        dsl_file = structurizr_dir / "workspace.dsl"
        log(f"Genereren generation flow DSL naar: {dsl_file.relative_to(repo_root)}")
        
        dsl_content = generate_generation_flow_dsl()
        
        with open(dsl_file, 'w', encoding='utf-8') as f:
            f.write(dsl_content)
        
        log(f"Geschreven: {dsl_file.relative_to(repo_root)}", "SUCCESS")
    
    log("", "INFO")
    log("VOLGENDE STAPPEN:", "INFO")
    log("1. Start Structurizr Lite: docker run -it --rm -p 8080:8080 -v $(pwd)/architectuur-agent-ecosysteem/.structurizr:/usr/local/structurizr structurizr/lite", "INFO")
    log("2. Open browser: http://localhost:8080", "INFO")
    log("3. DSL wijzigingen worden automatisch herladen (hot reload)", "INFO")
    
    return True

def generate_ecosystem_dsl() -> str:
    """Genereer Structurizr DSL voor ecosystem relationships."""
    return """workspace "Agent Ecosysteem" "Gegoverned ecosysteem van gespecialiseerde AI-agents voor software delivery" {

    !identifiers hierarchical

    model {
        user = person "Gebruiker" "Software engineer, architect, product owner die opdrachten geeft aan het agent ecosysteem"
        
        llmProvider = softwareSystem "LLM Provider" "Claude, GPT-4 - AI inference" "External"
        github = softwareSystem "GitHub" "Code repository, standards repository" "External"
        
        agentEcosysteem = softwareSystem "Agent Ecosysteem" "Gegoverned netwerk van AI-agents voor software delivery" {
            
            # GitHub Standards Container
            standards = container "GitHub Standards" "Git Repository" "Governance regels, charters, templates" {
                constitutie = component "Constitutie" "Markdown" "Universele principes"
                beleid = component "Beleid" "Markdown" "Repository-specifieke regels"
                agentCharters = component "Agent Charters" "Markdown" "Operationele bevoegdheden per agent (std.agent.charter.*.md)"
                faseCharters = component "Fase Charters" "Markdown" "Kwaliteitseisen per SAFe-fase (std.fase.charter.*.md)"
                deliveryFramework = component "Delivery Framework" "Markdown" "SAFe Development Value Stream definitie (A-G+U fases)"
                templates = component "Templates" "Markdown" "Charter templates"
            }
            
            # GitHub Agent-Capabilities Container
            capabilities = container "GitHub Agent-Capabilities" "Git Repository" "Agent-definities en prompts" {
                moeder = component "Moeder Agent" "Meta-agent" "Agent factory, charter designer"
                agentA = component "Fase A Agents" "Trigger" "Business case analyse"
                agentB = component "Fase B Agents" "Architectuur" "ADR's, patterns"
                agentC = component "Fase C Agents" "Specificatie" "Features, datamodellen"
                agentD = component "Fase D Agents" "Ontwerp" "Solution design"
                agentE = component "Fase E Agents" "Bouw" "Code generatie"
                agentF = component "Fase F Agents" "Validatie" "Testing"
                agentG = component "Fase G Agents" "Deployment" "Release management"
                agentU = component "Utility Agents" "Utility" "Charter schrijver, C4-modelleur, MD-to-DSL converter"
            }
            
            # Project Workspace Container
            workspace = container "Project Workspace" "Git Repository" "Gegenereerde artefacten per project" {
                specs = component "Specificaties" "Markdown" "Requirements, features, user stories"
                designs = component "Designs" "Markdown/Diagrams" "Solution designs, API contracts"
                code = component "Code" "Source files" "Gegenereerde en handgeschreven code"
                tests = component "Tests" "Test files" "Test cases en validatie resultaten"
                docs = component "Documentatie" "Markdown" "Technische documentatie en runbooks"
            }
        }
        
        # User interactions
        user -> agentEcosysteem "Geeft opdracht (≤5 regels)" "Natural language"
        agentEcosysteem -> user "Levert artefacten" "Markdown, code"
        
        # External system interactions
        standards -> github "Leeft in" "Git"
        capabilities -> github "Leeft in" "Git"
        workspace -> github "Leeft in" "Git"
        
        # Governance hierarchy
        constitutie -> agentCharters "Overstijgt" "Principes"
        beleid -> agentCharters "Constrain" "Regels"
        agentCharters -> moeder "Definieert" "Charter"
        agentCharters -> agentA "Definieert" "Charter"
        agentCharters -> agentB "Definieert" "Charter"
        agentCharters -> agentC "Definieert" "Charter"
        agentCharters -> agentD "Definieert" "Charter"
        agentCharters -> agentE "Definieert" "Charter"
        agentCharters -> agentF "Definieert" "Charter"
        agentCharters -> agentG "Definieert" "Charter"
        agentCharters -> agentU "Definieert" "Charter"
        
        faseCharters -> deliveryFramework "Operationaliseert" "Kwaliteitseisen"
        
        # Agent workflows
        moeder -> agentCharters "Schrijft" "Charter"
        moeder -> templates "Gebruikt" "Template"
        
        agentU -> llmProvider "Aanroept" "API"
        moeder -> llmProvider "Aanroept" "API"
        agentA -> llmProvider "Aanroept" "API"
        agentB -> llmProvider "Aanroept" "API"
        agentC -> llmProvider "Aanroept" "API"
        agentD -> llmProvider "Aanroept" "API"
        agentE -> llmProvider "Aanroept" "API"
        agentF -> llmProvider "Aanroept" "API"
        agentG -> llmProvider "Aanroept" "API"
        
        # Delivery chain
        agentA -> specs "Produceert" "Requirements"
        agentB -> designs "Produceert" "Architecture"
        agentC -> specs "Produceert" "Features"
        agentD -> designs "Produceert" "Solution design"
        agentE -> code "Produceert" "Code"
        agentF -> tests "Produceert" "Tests"
        agentG -> docs "Produceert" "Runbooks"
    }

    views {
        systemContext agentEcosysteem "SystemContext" {
            include *
            # autoLayout lr
        }

        container agentEcosysteem "Containers" {
            include *
            # autoLayout tb
        }

        component standards "StandardsComponents" {
            include *
            # autoLayout tb
            title "Standards Repository - Component Diagram"
        }

        component capabilities "CapabilitiesComponents" {
            include *
            # autoLayout lr
            title "Agent Capabilities - Component Diagram"
        }

        component workspace "WorkspaceComponents" {
            include *
            # autoLayout tb
            title "Project Workspace - Component Diagram"
        }

        styles {
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
        }

        theme default
    }
}
"""

def generate_generation_flow_dsl() -> str:
    """Genereer Structurizr DSL voor agent generation flow.
    
    Volgt de DSL constraints uit charter u03.c4-modelleur:
    - AutoLayout altijd uitgecommentarieerd
    - Geen parent-child relaties
    - System-scoped dynamic views: alleen containers
    - Container-scoped dynamic views: alleen componenten
    - Alle relaties eerst in model definiëren
    
    Layering volgens Sugiyama framework:
    - Laag 0: Actor (Developer)
    - Laag 1: External systems (Standard Repository, Project Workspace)
    - Laag 2: Orchestrators (make-agent.py, fetch-agents.py)
    - Laag 3: Builders (prompt-builder, runner-builder, orchestration-builder)
    - Laag 4: Storage (Buildplans, Components, Governance)
    """
    return """workspace "Agent Generation Pipeline" "C4 model van het agent generation proces" {

    model {
        # Externe systemen
        developer = person "Developer" "Schrijft charters en voert scripts uit"
        standardRepo = softwareSystem "Standard Repository" "Bevat agent charters als single source of truth" {
            tags "External"
        }
        projectWorkspace = softwareSystem "Project Workspace" "Gebruikt gegenereerde agents voor development" {
            tags "External"
        }

        # Hoofd systeem: Agent-Capabilities
        agentCapabilities = softwareSystem "Agent-Capabilities" "Genereert en distribueert agent componenten" {
            
            # Container: Main Orchestrator
            makeAgent = container "make-agent.py" "Hoofdorchestrator voor agent generation" "Python Script" {
                tags "MainScript"
                charterReader = component "Charter Reader" "Leest charter uit standard repo" "Python Function"
                phaseValidator = component "Phase Validator" "Valideert fase uit charter" "Python Function"
                buildPlanWriter = component "BuildPlan Writer" "Schrijft JSON buildplan" "Python Function"
                builderOrchestrator = component "Builder Orchestrator" "Roept builders aan" "Python Function"
                pipelineGenerator = component "Pipeline Generator" "Base class voor pipeline generation" "Python Class"
                githubActionsGen = component "GitHub Actions Generator" "Translates naar GH Actions" "Python Class"
                gitlabCIGen = component "GitLab CI Generator" "Translates naar GitLab CI" "Python Class"
            }
            
            # Container: Prompt Builder
            promptBuilder = container "prompt-builder.py" "Genereert minimale prompt files" "Python Script" {
                tags "Builder"
                promptGenerator = component "Prompt Generator" "Genereert prompt.md" "Python Function"
                charterLinker = component "Charter Linker" "Linkt naar charter URL" "Python Function"
            }
            
            # Container: Runner Builder
            runnerBuilder = container "runner-builder.py" "Genereert Python CLI executables" "Python Script" {
                tags "Builder"
                cliGenerator = component "CLI Generator" "Genereert runner.py" "Python Function"
                argparseBuilder = component "Argparse Builder" "Bouwt CLI interface" "Python Function"
            }
            
            # Container: Orchestration Builder
            orchestrationBuilder = container "orchestration-builder.py" "Genereert YAML workflow configs" "Python Script" {
                tags "Builder"
                yamlGenerator = component "YAML Generator" "Genereert orchestration.yaml" "Python Function"
                workflowDefiner = component "Workflow Definer" "Definieert workflow structuur" "Python Function"
            }
            
            # Container: Fetch Agents
            fetchAgents = container "fetch-agents.py" "Distribueert agents naar workspaces" "Python Script" {
                tags "Distribution"
                repoCloner = component "Repo Cloner" "Kloont agent-capabilities" "Python Function"
                fileCopier = component "File Copier" "Kopieert componenten" "Python Function"
                platformSelector = component "Platform Selector" "Selecteert platform pipelines" "Python Function"
            }

            # Container: Buildplans Storage
            buildplans = container "Buildplans" "JSON metadata met traceerbaarheid" "JSON Files" {
                tags "Data"
            }

            # Container: Agent Componenten Storage
            components = container "Agent Componenten" "Gegenereerde agent artefacten" "File System" {
                tags "Data"
                prompts = component "Prompts" "Minimale instructie files" "Markdown"
                runners = component "Runners" "CLI executables" "Python"
                orchestrations = component "Orchestrations" "Workflow definities" "YAML"
                agentDefs = component "Agent Definitions" "Samenvatting documenten" "Markdown"
                pipelineDefs = component "Pipeline Definitions" "Platform-agnostisch" "YAML"
                generatedPipelines = component "Generated Pipelines" "Platform-specifiek" "YAML"
            }

            # Container: Governance
            governance = container "Governance" "Beleid en principes" "Markdown" {
                tags "Documentation"
            }
        }

        # Relaties - Developer interactions
        developer -> standardRepo "Schrijft charter in" "Git"
        developer -> makeAgent "Voert uit met --agent-name" "CLI"
        developer -> fetchAgents "Voert uit in project" "CLI"

        # Relaties - make-agent.py workflow (container level)
        makeAgent -> standardRepo "Leest charter (auto git pull)" "Git + File System"
        makeAgent -> buildplans "Schrijft buildplan" "JSON"
        makeAgent -> promptBuilder "Roept aan" "subprocess"
        makeAgent -> runnerBuilder "Roept aan" "subprocess"
        makeAgent -> orchestrationBuilder "Roept aan" "subprocess"
        makeAgent -> components "Schrijft pipelines + agent.md" "File System"
        makeAgent -> governance "Volgt principes" "Reference"

        # Relaties - Builders (container level)
        promptBuilder -> buildplans "Leest metadata" "JSON"
        promptBuilder -> standardRepo "Leest charter" "File System"
        promptBuilder -> components "Schrijft prompt.md" "File System"

        runnerBuilder -> buildplans "Leest metadata" "JSON"
        runnerBuilder -> components "Schrijft runner.py" "File System"

        orchestrationBuilder -> buildplans "Leest metadata" "JSON"
        orchestrationBuilder -> components "Schrijft orchestration.yaml" "File System"

        # Relaties - Distribution (container level)
        fetchAgents -> components "Leest componenten" "File System"
        fetchAgents -> projectWorkspace "Kopieert naar .github/ en agent-componenten/" "File System"
        fetchAgents -> governance "Volgt principes" "Reference"

        # Relaties - make-agent.py internals (component level)
        charterReader -> phaseValidator "Valideert fase" "Python call"
        phaseValidator -> buildPlanWriter "Schrijft plan" "Python call"
        buildPlanWriter -> builderOrchestrator "Roept builders aan" "Python call"
        builderOrchestrator -> pipelineGenerator "Genereert pipelines" "Python call"
        pipelineGenerator -> githubActionsGen "Translates" "Inheritance"
        pipelineGenerator -> gitlabCIGen "Translates" "Inheritance"

        # Relaties - prompt-builder.py internals (component level)
        promptGenerator -> charterLinker "Linkt charter" "Python call"

        # Relaties - runner-builder.py internals (component level)
        cliGenerator -> argparseBuilder "Bouwt CLI" "Python call"

        # Relaties - orchestration-builder.py internals (component level)
        yamlGenerator -> workflowDefiner "Definieert workflow" "Python call"

        # Relaties - fetch-agents.py internals (component level)
        repoCloner -> fileCopier "Kopieert files" "Python call"
        fileCopier -> platformSelector "Selecteert platform" "Python call"

        # Deployment
        deploymentEnvironment "Developer Machine" {
            deploymentNode "Windows 11" {
                deploymentNode "Python 3.11" {
                    makeAgentInstance = containerInstance makeAgent
                    promptBuilderInstance = containerInstance promptBuilder
                    runnerBuilderInstance = containerInstance runnerBuilder
                    orchestrationBuilderInstance = containerInstance orchestrationBuilder
                    fetchAgentsInstance = containerInstance fetchAgents
                }
                deploymentNode "File System" {
                    buildplansInstance = containerInstance buildplans
                    componentsInstance = containerInstance components
                    governanceInstance = containerInstance governance
                }
            }
            deploymentNode "Git Repositories" {
                standardRepoInstance = softwareSystemInstance standardRepo
                projectWorkspaceInstance = softwareSystemInstance projectWorkspace
            }
        }
    }

    views {
        systemContext agentCapabilities "SystemContext" {
            include *
            # autolayout lr
            title "Agent-Capabilities - System Context"
        }

        container agentCapabilities "Containers" {
            include *
            # autolayout tb
            title "Agent Generation Pipeline - Container Diagram"
            description "Layering: Developer → Orchestrators → Builders → Storage (Sugiyama framework)"
        }

        component makeAgent "MakeAgentComponents" {
            include *
            # autolayout tb
            title "make-agent.py - Component Diagram"
        }

        component promptBuilder "PromptBuilderComponents" {
            include *
            # autolayout lr
            title "prompt-builder.py - Component Diagram"
        }

        component runnerBuilder "RunnerBuilderComponents" {
            include *
            # autolayout lr
            title "runner-builder.py - Component Diagram"
        }

        component orchestrationBuilder "OrchestrationBuilderComponents" {
            include *
            # autolayout lr
            title "orchestration-builder.py - Component Diagram"
        }

        component fetchAgents "FetchAgentsComponents" {
            include *
            # autolayout lr
            title "fetch-agents.py - Component Diagram"
        }

        component components "StorageComponents" {
            include *
            # autolayout tb
            title "Agent Componenten Storage - Component Diagram"
        }

        dynamic agentCapabilities "GenerationFlow" "Agent generation workflow" {
            developer -> makeAgent "1. Voert uit: make-agent.py --agent-name X"
            makeAgent -> standardRepo "2. Git pull + lees charter"
            makeAgent -> buildplans "3. Schrijft buildplan met metadata"
            makeAgent -> promptBuilder "4. Roept prompt-builder.py aan"
            promptBuilder -> components "5. Schrijft prompt.md"
            makeAgent -> runnerBuilder "6. Roept runner-builder.py aan"
            runnerBuilder -> components "7. Schrijft runner.py"
            makeAgent -> orchestrationBuilder "8. Roept orchestration-builder.py aan"
            orchestrationBuilder -> components "9. Schrijft orchestration.yaml"
            makeAgent -> components "10. Genereert pipelines + agent.md"
            title "Agent Generation Flow - Container Level"
        }

        dynamic agentCapabilities "DistributionFlow" "Agent distribution workflow" {
            developer -> fetchAgents "1. Voert uit: fetch-agents.py in project"
            fetchAgents -> components "2. Leest prompts, runners, orchestrations, pipelines"
            fetchAgents -> projectWorkspace "3. Kopieert naar .github/ en agent-componenten/"
            title "Agent Distribution Flow - Container Level"
        }

        dynamic makeAgent "MakeAgentFlow" "Interne werking van make-agent.py" {
            charterReader -> phaseValidator "1. Valideert fase"
            phaseValidator -> buildPlanWriter "2. Schrijft buildplan"
            buildPlanWriter -> builderOrchestrator "3. Orchestreert builders"
            builderOrchestrator -> pipelineGenerator "4. Genereert pipelines"
            pipelineGenerator -> githubActionsGen "5a. GitHub Actions"
            pipelineGenerator -> gitlabCIGen "5b. GitLab CI"
            title "make-agent.py Internals - Component Level"
        }

        deployment agentCapabilities "Developer Machine" "Deployment" {
            include *
            # autolayout tb
        }

        styles {
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            element "MainScript" {
                background #ff6b6b
                color #ffffff
            }
            element "Builder" {
                background #4ecdc4
                color #ffffff
            }
            element "Distribution" {
                background #95e1d3
                color #000000
            }
            element "Data" {
                shape cylinder
                background #f38181
                color #ffffff
            }
            element "Documentation" {
                shape folder
                background #a8e6cf
                color #000000
            }
        }

        theme default
    }
}
"""

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Visualiseer het agent-ecosysteem met C4 diagrammen in Structurizr DSL',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Voorbeelden:
  python scripts/visualize-ecosystem.py                    # Genereer generation flow (default)
  python scripts/visualize-ecosystem.py --mode ecosystem   # Genereer ecosystem relationships
  python scripts/visualize-ecosystem.py --mode both        # Genereer beide diagrammen
  
Output:
  - workspace.dsl: Agent generation flow (actief in Structurizr)
  - workspace-ecosystem.dsl: Agent ecosystem relationships (backup)
  
Start Structurizr Lite:
  docker run -it --rm -p 8080:8080 -v $(pwd)/architectuur-agent-ecosysteem/.structurizr:/usr/local/structurizr structurizr/lite
  Open: http://localhost:8080
"""
    )
    
    parser.add_argument(
        '--mode',
        choices=['ecosystem', 'generation', 'both'],
        default='generation',
        help='Welk diagram te genereren: ecosystem (agent relationships), generation (make-agent flow), of both'
    )
    
    parser.add_argument(
        '--legacy',
        action='store_true',
        help='Gebruik legacy PlantUML generator (deprecated)'
    )
    
    args = parser.parse_args()
    
    log("Starten ecosysteem visualisatie...")
    
    if args.legacy:
        # Legacy mode: PlantUML placeholders
        success = generate_c4_diagrams("all")
    else:
        # Production mode: Structurizr DSL
        success = generate_structurizr_dsl(args.mode)
    
    return 0 if success else 1

if __name__ == '__main__':
    sys.exit(main())
