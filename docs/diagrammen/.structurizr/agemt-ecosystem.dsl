workspace "Agent Ecosysteem" "Gegoverned ecosysteem van gespecialiseerde AI-agents voor software delivery" {

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
                agentU = component "Utility Agents" "Utility" "Charter schrijver, MD-to-DSL converter"
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
        agentEcosysteem -> llmProvider "Gebruikt voor inferentie" "API"
        agentEcosysteem -> github "Leest standards, persisteert output" "Git"
        
        # User to Capabilities
        user -> agentEcosysteem.capabilities "Activeert agent via prompt" "Natural language"
        
        # Capabilities to Standards
        agentEcosysteem.capabilities -> agentEcosysteem.standards "Leest charters en regels" "File I/O"
        agentEcosysteem.capabilities.moeder -> agentEcosysteem.standards "Leest governance" "File I/O"
        agentEcosysteem.capabilities.agentA -> agentEcosysteem.standards.agentCharters "Leest eigen charter" "Read"
        agentEcosysteem.capabilities.agentB -> agentEcosysteem.standards.agentCharters "Leest eigen charter" "Read"
        agentEcosysteem.capabilities.agentC -> agentEcosysteem.standards.agentCharters "Leest eigen charter" "Read"
        agentEcosysteem.capabilities.agentD -> agentEcosysteem.standards.agentCharters "Leest eigen charter" "Read"
        agentEcosysteem.capabilities.agentE -> agentEcosysteem.standards.agentCharters "Leest eigen charter" "Read"
        agentEcosysteem.capabilities.agentF -> agentEcosysteem.standards.agentCharters "Leest eigen charter" "Read"
        agentEcosysteem.capabilities.agentG -> agentEcosysteem.standards.agentCharters "Leest eigen charter" "Read"
        agentEcosysteem.capabilities.agentU -> agentEcosysteem.standards.agentCharters "Leest eigen charter" "Read"
        
        # Capabilities to Delivery Framework
        agentEcosysteem.capabilities.agentA -> agentEcosysteem.standards.deliveryFramework "Opereert in Fase A" "Process adherence"
        agentEcosysteem.capabilities.agentB -> agentEcosysteem.standards.deliveryFramework "Opereert in Fase B" "Process adherence"
        agentEcosysteem.capabilities.agentC -> agentEcosysteem.standards.deliveryFramework "Opereert in Fase C" "Process adherence"
        agentEcosysteem.capabilities.agentD -> agentEcosysteem.standards.deliveryFramework "Opereert in Fase D" "Process adherence"
        agentEcosysteem.capabilities.agentE -> agentEcosysteem.standards.deliveryFramework "Opereert in Fase E" "Process adherence"
        agentEcosysteem.capabilities.agentF -> agentEcosysteem.standards.deliveryFramework "Opereert in Fase F" "Process adherence"
        agentEcosysteem.capabilities.agentG -> agentEcosysteem.standards.deliveryFramework "Opereert in Fase G" "Process adherence"
        agentEcosysteem.capabilities.agentU -> agentEcosysteem.standards.deliveryFramework "Opereert in Fase U" "Process adherence"
        
        # Capabilities to Workspace
        agentEcosysteem.capabilities -> agentEcosysteem.workspace "Schrijft/leest artefacten" "File I/O"
        agentEcosysteem.capabilities.agentC -> agentEcosysteem.workspace.specs "Schrijft features, user stories" "Write"
        agentEcosysteem.capabilities.agentC -> agentEcosysteem.workspace.designs "Leest datamodel" "Read"
        agentEcosysteem.capabilities.agentD -> agentEcosysteem.workspace.designs "Schrijft solution design, contracts" "Write"
        agentEcosysteem.capabilities.agentE -> agentEcosysteem.workspace.code "Schrijft code" "Write"
        agentEcosysteem.capabilities.agentF -> agentEcosysteem.workspace.tests "Schrijft en voert tests uit" "Write"
        
        # Capabilities to LLM
        agentEcosysteem.capabilities -> llmProvider "Gebruikt voor inferentie" "API"
        
        # Workspace to LLM (voor intelligent workspace features)
        agentEcosysteem.workspace -> llmProvider "Semantische zoeken, validatie, cross-referencing" "API"
        
        # Standards to GitHub
        agentEcosysteem.standards -> github "Gepersisteerd in standards repo" "Git"
        agentEcosysteem.capabilities -> github "Gepersisteerd in standards repo" "Git"
        
        # Workspace to GitHub
        agentEcosysteem.workspace -> github "Gepersisteerd in project repo" "Git"
        
        # Governance hierarchy within Standards
        agentEcosysteem.standards.constitutie -> agentEcosysteem.standards.beleid "Overschrijft" "Hierarchy"
        agentEcosysteem.standards.beleid -> agentEcosysteem.standards.agentCharters "Overschrijft" "Hierarchy"
        agentEcosysteem.standards.deliveryFramework -> agentEcosysteem.standards.faseCharters "Definieert fases voor" "Reference"
        agentEcosysteem.standards.faseCharters -> agentEcosysteem.standards.agentCharters "Definieert kwaliteitseisen voor" "Reference"
        
        # Moeder Agent orchestration
        agentEcosysteem.capabilities.moeder -> agentEcosysteem.capabilities.agentA "Activeert" "Orchestration"
        agentEcosysteem.capabilities.moeder -> agentEcosysteem.capabilities.agentB "Activeert" "Orchestration"
    }

    views {
        systemContext agentEcosysteem "SystemContext" {
            include *
        }

        container agentEcosysteem "Containers" {
            include *
        }
        
        component agentEcosysteem.standards "GitHubStandards" {
            include *
        }
        
        component agentEcosysteem.capabilities "GitHubAgentCapabilities" {
            include *
        }
        
        component agentEcosysteem.workspace "ProjectWorkspace" {
            include *
        }

        styles {
            element "Software System" {
                background #1168bd
                color #ffffff
                shape roundedbox
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
                shape roundedbox
            }
            element "Component" {
                background #85bbf0
                color #000000
                shape roundedbox
            }
            element "Git Repository" {
                shape cylinder
                background #2e7d32
                color #ffffff
            }
            element "Proces Model" {
                background #fff3e0
                color #000000
                shape hexagon
            }
            element "Meta-agent" {
                background #fff9c4
                color #000000
            }
            element "Trigger" {
                background #ffebee
                color #000000
            }
            element "Architectuur" {
                background #e3f2fd
                color #000000
            }
            element "Specificatie" {
                background #f3e5f5
                color #000000
            }
            element "Ontwerp" {
                background #e0f2f1
                color #000000
            }
            element "Bouw" {
                background #fff9c4
                color #000000
            }
            element "Validatie" {
                background #fce4ec
                color #000000
            }
            element "Deployment" {
                background #e8f5e9
                color #000000
            }
            element "Utility" {
                background #f5f5f5
                color #000000
            }
            relationship "Relationship" {
                thickness 2
                color #707070
            }
            relationship "Hierarchy" {
                thickness 3
                color #d9232b
                style dashed
            }
            relationship "Process adherence" {
                thickness 2
                color #ff9800
                style dotted
            }
            relationship "Orchestration" {
                thickness 3
                color #4caf50
            }
        }
    }

    configuration {
        scope softwaresystem
    }

}