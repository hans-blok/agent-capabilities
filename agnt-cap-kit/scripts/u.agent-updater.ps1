#Requires -Version 5.1

<#
.SYNOPSIS
    Update agents vanuit GitHub repository hans-blok/agent-capabilities

.DESCRIPTION
    Haalt agent-bestanden op van GitHub en installeert deze in de juiste locaties.
    Kan specifieke versies ophalen of de laatste versie van main branch.
    Verplaatst oude bestanden uit root naar .github folder indien aanwezig.

.PARAMETER AgentName
    Naam van de agent (bijv. 'c.feature-analist', 'd.ldm', 'u.md-to-docx')

.PARAMETER Version
    Git versie: tag (v1.0.0), branch (main), of commit hash
    Default: main (laatste versie)

.PARAMETER UpdateType
    Type update: 'full' (alle bestanden) of 'definition-only' (alleen agent-definitie)
    Default: full

.PARAMETER TargetPath
    Basis directory waar bestanden worden geïnstalleerd
    Default: huidige directory

.PARAMETER CleanupRoot
    Verwijder oude agent-bestanden uit root folder
    Default: $true

.EXAMPLE
    .\u.agent-updater.ps1 -AgentName "c.feature-analist"
    Haalt de laatste versie op van main branch

.EXAMPLE
    .\u.agent-updater.ps1 -AgentName "d.ldm" -Version "v1.0.0"
    Haalt specifieke versie v1.0.0 op

.EXAMPLE
    .\u.agent-updater.ps1 -AgentName "b.cdm-architect" -UpdateType "definition-only"
    Haalt alleen de agent-definitie op

.EXAMPLE
    .\u.agent-updater.ps1 -AgentName "c.feature-analist" -CleanupRoot $true
    Haalt agent op en verplaatst oude bestanden uit root naar .github

.NOTES
    Auteur: Agent-Capabilities
    Datum: 2025-12-30
    Repository: https://github.com/hans-blok/agent-capabilities
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AgentName,

    [Parameter(Mandatory = $false)]
    [string]$Version = "main",

    [Parameter(Mandatory = $false)]
    [ValidateSet("full", "definition-only")]
    [string]$UpdateType = "full",

    [Parameter(Mandatory = $false)]
    [string]$TargetPath = ".",

    [Parameter(Mandatory = $false)]
    [bool]$CleanupRoot = $true
)

# Constanten
$GitHubRepo = "hans-blok/agent-capabilities"
$BaseUrl = "https://raw.githubusercontent.com/$GitHubRepo/$Version"

# Helper functies
function Write-Status {
    param([string]$Message, [string]$Type = "Info")
    $color = switch ($Type) {
        "Success" { "Green" }
        "Error" { "Red" }
        "Warning" { "Yellow" }
        default { "Cyan" }
    }
    Write-Host $Message -ForegroundColor $color
}

function Get-StreamFolder {
    param([string]$Stream)
    
    $mapping = @{
        'a' = 'a.trigger'
        'b' = 'b.architectuur'
        'c' = 'c.specificatie'
        'd' = 'd.ontwerp'
        'e' = 'e.bouw'
        'f' = 'f.validatie'
        'g' = 'g.deployment'
        'u' = 'utility'
    }
    
    if ($mapping.ContainsKey($Stream.ToLower())) {
        return $mapping[$Stream.ToLower()]
    }
    
    return $null
}

function Get-AgentPaths {
    param([string]$AgentName)
    
    # Parse agent naam
    if ($AgentName -match '^([a-gu])\.(.+)$') {
        $stream = $Matches[1].ToLower()
        $taskName = $Matches[2]
        $streamFolder = Get-StreamFolder -Stream $stream
        
        if ($null -eq $streamFolder) {
            throw "Onbekende stream: $stream"
        }
        
        # Bepaal prefix (hoofdletter + nummer) - voor beschrijving
        # Dit is een simplificatie, in werkelijkheid zou je dit moeten opzoeken
        $prefix = $stream.ToUpper()
        
        return @{
            AgentDefinition = ".github/agents/$streamFolder/$taskName.agent.md"
            Prompt = ".github/prompts/$stream.$taskName.prompt.md"
            Description = "desc-agents/$streamFolder/$prefix.*-$taskName.md"
            StreamFolder = $streamFolder
            Stream = $stream
            TaskName = $taskName
        }
    }
    elseif ($AgentName -eq "agnt-cap.moeder") {
        # Speciale behandeling voor governance agent
        return @{
            AgentDefinition = ".github/agents/agnt-cap.moeder.agent.md"
            Prompt = ".github/prompts/agnt-cap.moeder.prompt.md"
            Description = "desc-agents/00-agnt-cap-moeder-agent.md"
            StreamFolder = ""
            Stream = "governance"
            TaskName = "moeder"
        }
    }
    else {
        throw "Ongeldige agent naam format: $AgentName (verwacht: {stream}.{taaknaam})"
    }
}

function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop
        
        # Maak parent directory aan
        $parentDir = Split-Path -Parent $OutputPath
        if (-not (Test-Path $parentDir)) {
            New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
        }
        
        # Schrijf bestand
        [System.IO.File]::WriteAllText($OutputPath, $response.Content, [System.Text.Encoding]::UTF8)
        
        return $true
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Status "⚠️  Bestand niet gevonden: $Url" "Warning"
        }
        else {
            Write-Status "❌ Fout bij downloaden: $($_.Exception.Message)" "Error"
        }
        return $false
    }
}

function Find-DescriptionFile {
    param(
        [string]$DescriptionPattern,
        [string]$BasePath
    )
    
    # Converteer pattern naar zoek pattern
    $searchPath = Join-Path $BasePath $DescriptionPattern
    $searchPath = $searchPath -replace '\*', '*'
    
    # Zoek bestanden
    $files = Get-ChildItem -Path (Split-Path $searchPath) -Filter (Split-Path $searchPath -Leaf) -ErrorAction SilentlyContinue
    
    if ($files.Count -gt 0) {
        return $files[0].FullName
    }
    
    return $null
}

function Move-RootFilesToGitHub {
    param([string]$BasePath)
    
    Write-Status "`n🔄 Controleren op oude bestanden in root..." "Info"
    
    $moved = 0
    
    # Zoek naar .agent.md bestanden in root
    $agentFiles = Get-ChildItem -Path $BasePath -Filter "*.agent.md" -File -ErrorAction SilentlyContinue
    
    foreach ($file in $agentFiles) {
        Write-Status "  📦 Gevonden: $($file.Name)" "Info"
        
        # Bepaal doel locatie
        if ($file.Name -match '^([a-gu])\.(.+)\.agent\.md$') {
            $stream = $Matches[1].ToLower()
            $taskName = $Matches[2]
            $streamFolder = Get-StreamFolder -Stream $stream
            
            if ($streamFolder) {
                $targetDir = Join-Path $BasePath ".github\agents\$streamFolder"
                $targetFile = Join-Path $targetDir $file.Name -replace "^$stream\.", ""
                
                if (-not (Test-Path $targetDir)) {
                    New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
                }
                
                Move-Item -Path $file.FullName -Destination $targetFile -Force
                Write-Status "  ✅ Verplaatst naar: .github\agents\$streamFolder\$($file.Name)" "Success"
                $moved++
            }
        }
    }
    
    # Zoek naar .prompt.md bestanden in root
    $promptFiles = Get-ChildItem -Path $BasePath -Filter "*.prompt.md" -File -ErrorAction SilentlyContinue
    
    foreach ($file in $promptFiles) {
        Write-Status "  📦 Gevonden: $($file.Name)" "Info"
        
        $targetDir = Join-Path $BasePath ".github\prompts"
        $targetFile = Join-Path $targetDir $file.Name
        
        if (-not (Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
        }
        
        Move-Item -Path $file.FullName -Destination $targetFile -Force
        Write-Status "  ✅ Verplaatst naar: .github\prompts\$($file.Name)" "Success"
        $moved++
    }
    
    if ($moved -eq 0) {
        Write-Status "  ℹ️  Geen oude bestanden gevonden in root" "Info"
    }
    else {
        Write-Status "`n✅ $moved bestand(en) verplaatst van root naar .github" "Success"
    }
}

# Main logic
Write-Status "🚀 Agent Updater - hans-blok/agent-capabilities" "Info"
Write-Status "================================================`n" "Info"

# Valideer input
Write-Status "📋 Configuratie:" "Info"
Write-Status "  Agent: $AgentName" "Info"
Write-Status "  Versie: $Version" "Info"
Write-Status "  Update type: $UpdateType" "Info"
Write-Status "  Target path: $TargetPath`n" "Info"

# Bepaal paden
try {
    $paths = Get-AgentPaths -AgentName $AgentName
}
catch {
    Write-Status "❌ Fout: $($_.Exception.Message)" "Error"
    exit 1
}

# Verplaats oude bestanden indien gewenst
if ($CleanupRoot) {
    Move-RootFilesToGitHub -BasePath $TargetPath
}

# Download bestanden
Write-Status "`n📥 Bestanden downloaden van GitHub..." "Info"

$downloaded = @()
$failed = @()

# Agent definitie (altijd)
$url = "$BaseUrl/$($paths.AgentDefinition)"
$localPath = Join-Path $TargetPath $paths.AgentDefinition
Write-Status "  Downloading: $($paths.AgentDefinition)" "Info"

if (Download-File -Url $url -OutputPath $localPath) {
    $downloaded += @{
        Type = "Agent-definitie"
        Path = $paths.AgentDefinition
    }
    Write-Status "  ✅ Agent-definitie gedownload" "Success"
}
else {
    $failed += "Agent-definitie"
}

# Prompt en beschrijving (alleen bij full update)
if ($UpdateType -eq "full") {
    # Prompt
    $url = "$BaseUrl/$($paths.Prompt)"
    $localPath = Join-Path $TargetPath $paths.Prompt
    Write-Status "  Downloading: $($paths.Prompt)" "Info"
    
    if (Download-File -Url $url -OutputPath $localPath) {
        $downloaded += @{
            Type = "Prompt"
            Path = $paths.Prompt
        }
        Write-Status "  ✅ Prompt gedownload" "Success"
    }
    else {
        $failed += "Prompt"
    }
    
    # Beschrijving (wildcards, moet bestanden vinden)
    Write-Status "  Zoeken naar beschrijving: $($paths.Description)" "Info"
    
    # Voor beschrijving moeten we eerst kijken welke bestanden er zijn
    # Simplificatie: probeer direct te downloaden met gekend patroon
    $descPattern = $paths.Description -replace '\*', '01'  # Aanname: meestal 01
    $url = "$BaseUrl/$descPattern"
    $localPath = Join-Path $TargetPath $descPattern
    
    if (Download-File -Url $url -OutputPath $localPath) {
        $downloaded += @{
            Type = "Beschrijving"
            Path = $descPattern
        }
        Write-Status "  ✅ Beschrijving gedownload" "Success"
    }
    else {
        $failed += "Beschrijving"
    }
}

# Rapportage
Write-Status "`n📊 Resultaat:" "Info"
Write-Status "=============" "Info"

if ($downloaded.Count -gt 0) {
    Write-Status "`n✅ Geïnstalleerde bestanden:" "Success"
    foreach ($item in $downloaded) {
        Write-Status "  - $($item.Type): $($item.Path)" "Success"
    }
}

if ($failed.Count -gt 0) {
    Write-Status "`n⚠️  Niet gevonden:" "Warning"
    foreach ($item in $failed) {
        Write-Status "  - $item" "Warning"
    }
}

Write-Status "`n✅ Agent '$AgentName' bijgewerkt naar versie '$Version'" "Success"
Write-Status "Datum: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "Info"

if ($downloaded.Count -eq 0) {
    Write-Status "`n❌ Geen bestanden succesvol gedownload" "Error"
    exit 1
}

exit 0
