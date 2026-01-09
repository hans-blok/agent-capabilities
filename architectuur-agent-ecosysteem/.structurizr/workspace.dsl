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
            
            # Container: Scripts
            scripts = container "Scripts" "Python scripts voor generation en distributie" "Python 3.11" {
                makeAgent = component "make-agent.py" "Hoofdorchestrator voor agent generation" "Python Script" {
                    tags "MainScript"
                }
                promptBuilder = component "prompt-builder.py" "Genereert minimale prompt files" "Python Script"
                runnerBuilder = component "runner-builder.py" "Genereert Python CLI executables" "Python Script"
                orchestrationBuilder = component "orchestration-builder.py" "Genereert YAML workflow configs" "Python Script"
                pipelineGenerator = component "PipelineGenerator" "Translates platform-agnostic naar specifiek" "Python Class" {
                    tags "Generator"
                }
                githubActionsGen = component "GitHubActionsGenerator" "Genereert GitHub Actions workflows" "Python Class"
                gitlabCIGen = component "GitLabCIGenerator" "Genereert GitLab CI pipelines" "Python Class"
                fetchAgents = component "fetch-agents.py" "Distribueert agents naar workspaces" "Python Script" {
                    tags "Distribution"
                }
            }

            # Container: Buildplans
            buildplans = container "Buildplans" "JSON metadata met traceerbaarheid" "JSON Files" {
                tags "Data"
            }

            # Container: Agent Componenten
            components = container "Agent Componenten" "Gegenereerde agent artefacten" "File System" {
                prompts = component "Prompts" "Minimale instructie files" "Markdown"
                runners = component "Runners" "CLI executables" "Python"
                orchestrations = component "Orchestrations" "Workflow definities" "YAML"
                agentDefs = component "Agent Definitions" "Samenvatting documenten" "Markdown"
                pipelineDefs = component "Pipeline Definitions" "Platform-agnostisch" "YAML" {
                    tags "PlatformAgnostic"
                }
                generatedPipelines = component "Generated Pipelines" "Platform-specifiek" "YAML" {
                    tags "Disposable"
                }
            }

            # Container: Governance
            governance = container "Governance" "Beleid en principes" "Markdown" {
                tags "Documentation"
            }
        }

        # Relaties - Developer interactions
        developer -> standardRepo "Schrijft charter in" "Git"
        developer -> makeAgent "Voert uit met agent-name" "CLI"
        developer -> fetchAgents "Voert uit in project" "CLI"

        # Relaties - make-agent.py workflow
        makeAgent -> standardRepo "Leest charter (auto git pull)" "File System"
        makeAgent -> buildplans "Schrijft buildplan" "JSON"
        makeAgent -> promptBuilder "Roept aan" "subprocess"
        makeAgent -> runnerBuilder "Roept aan" "subprocess"
        makeAgent -> orchestrationBuilder "Roept aan" "subprocess"
        makeAgent -> pipelineGenerator "Gebruikt voor pipeline generation" "Python import"

        # Relaties - Builders
        promptBuilder -> buildplans "Leest metadata" "JSON"
        promptBuilder -> standardRepo "Leest charter" "File System"
        promptBuilder -> prompts "Schrijft prompt.md" "File System"

        runnerBuilder -> buildplans "Leest metadata" "JSON"
        runnerBuilder -> runners "Schrijft runner.py" "File System"

        orchestrationBuilder -> buildplans "Leest metadata" "JSON"
        orchestrationBuilder -> orchestrations "Schrijft orchestration.yaml" "File System"

        # Relaties - Pipeline generation
        pipelineGenerator -> pipelineDefs "Leest definitie" "YAML"
        pipelineGenerator -> generatedPipelines "Genereert platform-specifieke pipelines" "File System"
        githubActionsGen -> pipelineGenerator "Extends" "Inheritance"
        gitlabCIGen -> pipelineGenerator "Extends" "Inheritance"
        githubActionsGen -> generatedPipelines "Schrijft .workflow.yml" "File System"
        gitlabCIGen -> generatedPipelines "Schrijft .gitlab-ci.yml" "File System"

        # Relaties - Agent generation
        makeAgent -> agentDefs "Genereert agent.md" "File System"

        # Relaties - Distribution
        fetchAgents -> projectWorkspace "Kopieert componenten naar" "File System"
        fetchAgents -> prompts "Leest" "File System"
        fetchAgents -> runners "Leest" "File System"
        fetchAgents -> orchestrations "Leest" "File System"
        fetchAgents -> generatedPipelines "Leest platform-specifieke" "File System"

        # Relaties - Governance
        makeAgent -> governance "Volgt principes" "Reference"
        fetchAgents -> governance "Volgt principes" "Reference"

        # Deployment
        deploymentEnvironment "Developer Machine" {
            deploymentNode "Windows 11" {
                deploymentNode "Python 3.11" {
                    scriptsInstance = containerInstance scripts
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
            # autoLayout lr
        }

        container agentCapabilities "Containers" {
            include *
            # autoLayout tb
        }

        component scripts "ScriptsComponents" {
            include *
            # autoLayout tb
            title "Agent Generation Scripts - Component Diagram"
        }

        component components "AgentComponents" {
            include *
            # autoLayout lr
            title "Generated Agent Components - Component Diagram"
        }

        dynamic agentCapabilities "GenerationFlow" "Agent generation workflow (container level)" {
            developer -> scripts "1. Voert uit: make-agent.py --agent-name X"
            scripts -> standardRepo "2. Git pull + lees charter"
            scripts -> buildplans "3. Schrijft buildplan met metadata"
            scripts -> components "4. Genereert prompts, runners, orchestrations"
            # autoLayout lr
            title "Agent Generation Flow - Container Level"
        }

        dynamic scripts "DetailedGenerationFlow" "Agent generation workflow (component level)" {
            makeAgent -> promptBuilder "1. Roept aan met buildplan"
            promptBuilder -> prompts "2. Genereert prompt.md"
            makeAgent -> runnerBuilder "3. Roept aan met buildplan"
            runnerBuilder -> runners "4. Genereert runner.py"
            makeAgent -> orchestrationBuilder "5. Roept aan met buildplan"
            orchestrationBuilder -> orchestrations "6. Genereert orchestration.yaml"
            makeAgent -> pipelineGenerator "7. Gebruikt voor pipelines"
            pipelineGenerator -> generatedPipelines "8. Genereert platform-specifieke pipelines"
            # autoLayout tb
            title "Agent Generation Flow - Component Level"
        }

        dynamic agentCapabilities "DistributionFlow" "Agent distribution workflow" {
            developer -> scripts "1. Voert uit: fetch-agents.py in project"
            scripts -> components "2. Leest prompts, runners, orchestrations, pipelines"
            scripts -> projectWorkspace "3. Kopieert naar .github/ en agent-componenten/"
            # autoLayout lr
            title "Agent Distribution Flow - Container Level"
        }

        deployment agentCapabilities "Developer Machine" "Deployment" {
            include *
            # autoLayout tb
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
            element "Generator" {
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
            element "PlatformAgnostic" {
                background #ffd93d
                color #000000
            }
            element "Disposable" {
                background #cccccc
                color #000000
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
