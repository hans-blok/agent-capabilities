<#
.SYNOPSIS
    Synchroniseert agents van agent-capabilities naar de parent repository.

.DESCRIPTION
    Dit script kopieert alle agent-definities en prompts van de agent-capabilities 
    .github folder naar de parent repository .github folder, zodat ze beschikbaar 
    zijn voor GitHub Copilot.
    
    Dit script wordt automatisch aangeroepen na een git pull in agent-capabilities,
    of kan handmatig worden uitgevoerd om de synchronisatie te forceren.

.PARAMETER Force
    Switch: Overschrijf bestaande bestanden zonder waarschuwing.

.EXAMPLE
    .\u.sync-agents-to-parent.ps1
    Synchroniseert alle agents naar de parent repository.

.EXAMPLE
    .\u.sync-agents-to-parent.ps1 -Force
    Forceert synchronisatie en overschrijft bestaande bestanden.

.NOTES
    Auteur: Agent Capabilities Team
    Versie: 1.0.0
    Laatste update: 30-12-2025
    
    Stream: Utility (u.*)
    Vereisten: Script moet worden uitgevoerd vanuit agent-capabilities repository.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# Functie om info te tonen
function Write-Info-Message {
    param([string]$Message)
    Write-Host "INFO: $Message" -ForegroundColor Cyan
}

# Functie om succesmeldingen te tonen
function Write-Success-Message {
    param([string]$Message)
    Write-Host "SUCCES: $Message" -ForegroundColor Green
}

# Functie om waarschuwingen te tonen
function Write-Warning-Message {
    param([string]$Message)
    Write-Host "WAARSCHUWING: $Message" -ForegroundColor Yellow
}

# Functie om foutmeldingen te tonen
function Write-Error-Message {
    param([string]$Message)
    Write-Host "FOUT: $Message" -ForegroundColor Red
}

try {
    Write-Host "`nAgent Synchronisatie Script" -ForegroundColor Magenta
    Write-Host "============================`n" -ForegroundColor Magenta
    
    # Bepaal de repository root
    $agentCapPath = git rev-parse --show-toplevel 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Message "Kan repository root niet bepalen. Zorg dat je in een git repository zit."
        exit 1
    }
    
    Write-Info-Message "Agent-capabilities path: $agentCapPath"
    
    # Bepaal parent repository path
    $parentPath = Split-Path -Parent $agentCapPath
    Write-Info-Message "Parent repository path: $parentPath"
    
    # Definieer source en target paden
    $sourceAgentsPath = Join-Path $agentCapPath ".github\agents"
    $sourcePromptsPath = Join-Path $agentCapPath ".github\prompts"
    $targetAgentsPath = Join-Path $parentPath ".github\agents"
    $targetPromptsPath = Join-Path $parentPath ".github\prompts"
    
    # Controleer of source folders bestaan
    if (-not (Test-Path $sourceAgentsPath)) {
        Write-Error-Message ".github/agents folder niet gevonden in agent-capabilities."
        exit 1
    }
    
    if (-not (Test-Path $sourcePromptsPath)) {
        Write-Error-Message ".github/prompts folder niet gevonden in agent-capabilities."
        exit 1
    }
    
    # Controleer of parent .github folder bestaat
    $parentGithubPath = Join-Path $parentPath ".github"
    if (-not (Test-Path $parentGithubPath)) {
        Write-Warning-Message "Parent repository heeft geen .github folder."
        
        if (-not $Force) {
            $response = Read-Host "Wil je de .github folder aanmaken in de parent repository? (j/n)"
            if ($response -ne 'j' -and $response -ne 'J') {
                Write-Info-Message "Synchronisatie geannuleerd door gebruiker."
                exit 0
            }
        }
        
        New-Item -ItemType Directory -Path $parentGithubPath -Force | Out-Null
        Write-Success-Message ".github folder aangemaakt in parent repository."
    }
    
    # Maak target folders als ze niet bestaan
    if (-not (Test-Path $targetAgentsPath)) {
        New-Item -ItemType Directory -Path $targetAgentsPath -Force | Out-Null
        Write-Info-Message "agents folder aangemaakt in parent .github"
    }
    
    if (-not (Test-Path $targetPromptsPath)) {
        New-Item -ItemType Directory -Path $targetPromptsPath -Force | Out-Null
        Write-Info-Message "prompts folder aangemaakt in parent .github"
    }
    
    # Kopieer agents
    Write-Info-Message "Kopiëren van agent-definities..."
    Copy-Item -Path "$sourceAgentsPath\*" -Destination $targetAgentsPath -Recurse -Force
    
    $agentCount = (Get-ChildItem -Path $sourceAgentsPath -Recurse -Filter "*.agent.md" -File).Count
    Write-Success-Message "$agentCount agent-definitie(s) gekopieerd naar parent repository."
    
    # Kopieer prompts
    Write-Info-Message "Kopiëren van prompt-bestanden..."
    Copy-Item -Path "$sourcePromptsPath\*" -Destination $targetPromptsPath -Recurse -Force
    
    $promptCount = (Get-ChildItem -Path $sourcePromptsPath -Filter "*.prompt.md" -File).Count
    Write-Success-Message "$promptCount prompt-bestand(en) gekopieerd naar parent repository."
    
    # Toon samenvatting
    Write-Host "`nSamenvatting:" -ForegroundColor Green
    Write-Host "=============" -ForegroundColor Green
    Write-Host "  Agents:  $agentCount" -ForegroundColor Cyan
    Write-Host "  Prompts: $promptCount" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Success-Message "Synchronisatie voltooid!"
    Write-Info-Message "Agents zijn nu beschikbaar voor GitHub Copilot in de parent repository.`n"
    
} catch {
    Write-Error-Message "Er is een onverwachte fout opgetreden: $($_.Exception.Message)"
    exit 1
}
