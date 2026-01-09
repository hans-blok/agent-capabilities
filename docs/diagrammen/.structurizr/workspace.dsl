workspace "Agent Generation Pipeline" "C4 model van het agent generation proces" {

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
