#Requires -Version 5.1

<#
.SYNOPSIS
    Genereert een Founding Hypothesis volgens Knapp-methodologie

.DESCRIPTION
    Dit script is onderdeel van de A.01 founding-hypothesis-owner agent capability.
    Het genereert een founding hypothesis volgens Jake Knapp methodologie (Sprint/Click)
    met focus op unique value proposition, competitief voordeel en testbare success criteria.
    
    Het script genereert een gestructureerd Markdown document met:
    - Doelgroep (target audience)
    - Situatie/context
    - Onze oplossing
    - Concurrent/alternatief
    - Unieke waarde (waarom beter)
    - Testbare success criteria
    - Expliciet gemarkeerde aannames (max 3)
    - Business value
    - Hypothesis statement

.PARAMETER BusinessContext
    Beschrijving van de business context of het probleem dat wordt aangepakt.
    Dit is de primaire input voor het genereren van de hypothesis.

.PARAMETER TargetAudience
    Optioneel: Beschrijving van de doelgroep.
    Als niet opgegeven, wordt de doelgroep afgeleid uit de business context.

.PARAMETER CompetitiveContext
    Optioneel: Informatie over concurrenten en alternatieven.
    Als niet opgegeven, wordt gevraagd om deze informatie tijdens de generatie.

.PARAMETER OutputFile
    Optioneel: Het pad voor het output hypothesis bestand.
    Standaard: founding-hypothesis-[naam].md in de output folder.

.PARAMETER HypothesisName
    Optioneel: Naam van de hypothesis (gebruikt in bestandsnaam en titel).
    Standaard: Afgeleid van business context of interactief gevraagd.

.PARAMETER OutputFormat
    Het output formaat: Markdown, JSON, of Both.
    Standaard: Markdown

.PARAMETER ValidateOutput
    Switch: Valideer de gegenereerde hypothesis tegen quality gates.
    Standaard: Aangeschakeld ($true)

.EXAMPLE
    .\a.founding-hypothesis-owner.ps1 -BusinessContext "E-commerce personalisatie zonder data science expertise"
    Genereert een founding hypothesis voor e-commerce personalisatie

.EXAMPLE
    .\a.founding-hypothesis-owner.ps1 -BusinessContext "Automatische documentatie sync" -TargetAudience "Development teams bij scale-ups" -OutputFile "output\codedocs-hypothesis.md"
    Genereert hypothesis met specifieke doelgroep en output locatie

.EXAMPLE
    .\a.founding-hypothesis-owner.ps1 -BusinessContext "Team collaboration tool" -OutputFormat "Both"
    Genereert hypothesis in zowel Markdown als JSON formaat

.NOTES
    Auteur: Agent-Capabilities
    Datum: 2025-12-30
    Agent: A.01 - Founding Hypothesis Owner
    Charter: https://github.com/hans-blok/standard/blob/main/charters.agents/a.trigger/std.agent.charter.a.founding-hypothesis-owner.md
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$BusinessContext,

    [Parameter(Mandatory = $false)]
    [string]$TargetAudience,

    [Parameter(Mandatory = $false)]
    [string]$CompetitiveContext,

    [Parameter(Mandatory = $false)]
    [string]$OutputFile,

    [Parameter(Mandatory = $false)]
    [string]$HypothesisName,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Markdown", "JSON", "Both")]
    [string]$OutputFormat = "Markdown",

    [Parameter(Mandatory = $false)]
    [bool]$ValidateOutput = $true
)

# Constanten
$OutputDir = "artefacten/a.trigger"
$ErrorActionPreference = "Stop"

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

function Get-HypothesisName {
    param([string]$Context)
    
    if ($script:HypothesisName) {
        return $script:HypothesisName
    }
    
    # Probeer naam af te leiden uit context
    $words = $Context -split '\s+' | Select-Object -First 3
    $name = ($words -join '-').ToLower() -replace '[^a-z0-9-]', ''
    
    return $name
}

function Get-UserInput {
    param(
        [string]$Prompt,
        [bool]$Required = $false,
        [string]$DefaultValue = ""
    )
    
    $fullPrompt = $Prompt
    if ($DefaultValue) {
        $fullPrompt += " (default: $DefaultValue)"
    }
    $fullPrompt += ": "
    
    do {
        $input = Read-Host -Prompt $fullPrompt
        if ([string]::IsNullOrWhiteSpace($input) -and $DefaultValue) {
            return $DefaultValue
        }
        if ([string]::IsNullOrWhiteSpace($input) -and $Required) {
            Write-Status "Dit veld is verplicht. Probeer opnieuw." "Warning"
        }
    } while ([string]::IsNullOrWhiteSpace($input) -and $Required)
    
    return $input
}

function Generate-HypothesisMarkdown {
    param(
        [hashtable]$Data
    )
    
    $markdown = @"
# Founding Hypothesis: $($Data.Name)

**Datum**: $(Get-Date -Format 'yyyy-MM-dd')  
**Status**: Draft  
**Versie**: 1.0.0

---

## Doelgroep
$($Data.TargetAudience)

## Situatie/Context
$($Data.Situation)

## Onze Oplossing
$($Data.Solution)

## Concurrent/Alternatief
$($Data.Competitor)

## Unieke Waarde
$($Data.UniqueValue)

## Success Criteria
$($Data.SuccessCriteria)

## Aannames
$($Data.Assumptions)

## Business Value
$($Data.BusinessValue)

---

## Hypothesis Statement

$($Data.HypothesisStatement)

---

**Gegenereerd door**: A.01 Founding Hypothesis Owner  
**Methodologie**: Jake Knapp (Sprint/Click)  
**Charter**: https://github.com/hans-blok/standard/blob/main/charters.agents/a.trigger/std.agent.charter.a.founding-hypothesis-owner.md
"@
    
    return $markdown
}

function Generate-HypothesisJson {
    param([hashtable]$Data)
    
    $jsonObject = @{
        name = $Data.Name
        date = Get-Date -Format 'yyyy-MM-dd'
        status = "Draft"
        version = "1.0.0"
        targetAudience = $Data.TargetAudience
        situation = $Data.Situation
        solution = $Data.Solution
        competitor = $Data.Competitor
        uniqueValue = $Data.UniqueValue
        successCriteria = $Data.SuccessCriteriaList
        assumptions = $Data.AssumptionsList
        businessValue = $Data.BusinessValue
        hypothesisStatement = $Data.HypothesisStatement
        metadata = @{
            agent = "A.01 Founding Hypothesis Owner"
            methodology = "Jake Knapp (Sprint/Click)"
            charter = "https://github.com/hans-blok/standard/blob/main/charters.agents/a.trigger/std.agent.charter.a.founding-hypothesis-owner.md"
        }
    }
    
    return $jsonObject | ConvertTo-Json -Depth 10
}

function Validate-Hypothesis {
    param([hashtable]$Data)
    
    $issues = @()
    
    # Quality Gates uit charter
    if (-not $Data.HypothesisStatement -match "Als .+ boven .+, omdat .+") {
        $issues += "⚠️ Hypothesis volgt niet de juiste structuur"
    }
    
    if ($Data.TargetAudience -match "(iedereen|alle bedrijven|elk|alle)") {
        $issues += "⚠️ Doelgroep is te vaag"
    }
    
    if ([string]::IsNullOrWhiteSpace($Data.Competitor)) {
        $issues += "⚠️ Competitief voordeel ontbreekt"
    }
    
    if ($Data.AssumptionsList.Count -eq 0) {
        $issues += "⚠️ Geen aannames gemarkeerd"
    }
    
    if ($Data.AssumptionsList.Count -gt 3) {
        $issues += "⚠️ Te veel aannames (max 3)"
    }
    
    if ($Data.SuccessCriteriaList.Count -lt 3) {
        $issues += "⚠️ Te weinig success criteria (min 3)"
    }
    
    # Technisch jargon check (basis)
    $technicalTerms = @("API", "database", "server", "microservice", "kubernetes", "docker", "REST", "GraphQL")
    $hasTechnicalJargon = $false
    foreach ($term in $technicalTerms) {
        if ($Data.HypothesisStatement -match $term) {
            $hasTechnicalJargon = $true
            break
        }
    }
    if ($hasTechnicalJargon) {
        $issues += "⚠️ Bevat mogelijk technisch jargon"
    }
    
    return $issues
}

# Main logic
Write-Status "🚀 Founding Hypothesis Owner - A.01" "Info"
Write-Status "====================================`n" "Info"

# Verzamel informatie
Write-Status "📋 Verzamel informatie voor founding hypothesis..." "Info"
Write-Status "Business Context: $BusinessContext`n" "Info"

# Bepaal hypothesis naam
$name = Get-HypothesisName -Context $BusinessContext
Write-Status "Hypothesis naam: $name`n" "Info"

# Interactieve invoer indien niet opgegeven
if (-not $TargetAudience) {
    Write-Status "`n🎯 DOELGROEP" "Info"
    Write-Status "Beschrijf de specifieke doelgroep (niet 'iedereen' of 'alle bedrijven'):" "Info"
    $TargetAudience = Get-UserInput -Prompt "Doelgroep" -Required $true
}

Write-Status "`n📍 SITUATIE/CONTEXT" "Info"
Write-Status "In welke situatie bevindt de doelgroep zich?" "Info"
$situation = Get-UserInput -Prompt "Situatie" -Required $true

Write-Status "`n💡 ONZE OPLOSSING" "Info"
Write-Status "Wat bieden wij? (kort en bondig)" "Info"
$solution = Get-UserInput -Prompt "Oplossing" -Required $true

if (-not $CompetitiveContext) {
    Write-Status "`n🥊 CONCURRENT/ALTERNATIEF" "Info"
    Write-Status "Wat zijn de huidige alternatieven of concurrenten?" "Info"
    $CompetitiveContext = Get-UserInput -Prompt "Concurrent" -Required $true
}

Write-Status "`n⭐ UNIEKE WAARDE" "Info"
Write-Status "Waarom kiezen klanten voor ons boven de concurrent?" "Info"
$uniqueValue = Get-UserInput -Prompt "Unieke waarde" -Required $true

Write-Status "`n🎯 SUCCESS CRITERIA (minimaal 3)" "Info"
$successCriteria = @()
for ($i = 1; $i -le 5; $i++) {
    $criterion = Get-UserInput -Prompt "Criterium $i (of Enter om te stoppen)" -Required ($i -le 3)
    if ([string]::IsNullOrWhiteSpace($criterion)) {
        break
    }
    $successCriteria += $criterion
}

Write-Status "`n🔹 AANNAMES (maximaal 3)" "Info"
$assumptions = @()
for ($i = 1; $i -le 3; $i++) {
    $assumption = Get-UserInput -Prompt "Aanname $i (of Enter om te stoppen)" -Required $false
    if ([string]::IsNullOrWhiteSpace($assumption)) {
        break
    }
    $assumptions += $assumption
}

Write-Status "`n💰 BUSINESS VALUE" "Info"
Write-Status "Waarom is dit waardevol voor de organisatie?" "Info"
$businessValue = Get-UserInput -Prompt "Business value" -Required $true

# Genereer hypothesis statement
$hypothesisStatement = @"
Als $TargetAudience $situation, 
dan kiezen zij voor $solution 
boven $CompetitiveContext, 
omdat $uniqueValue.
"@

# Bouw data structuur
$successCriteriaText = ($successCriteria | ForEach-Object { $i = 1 } { "$i. $_"; $i++ }) -join "`n"
$assumptionsText = if ($assumptions.Count -gt 0) {
    ($assumptions | ForEach-Object { $i = 1 } { "$i. 🔹 $_"; $i++ }) -join "`n"
} else {
    "_Geen aannames geïdentificeerd_"
}

$hypothesisData = @{
    Name = $name
    TargetAudience = $TargetAudience
    Situation = $situation
    Solution = $solution
    Competitor = $CompetitiveContext
    UniqueValue = $uniqueValue
    SuccessCriteria = $successCriteriaText
    SuccessCriteriaList = $successCriteria
    Assumptions = $assumptionsText
    AssumptionsList = $assumptions
    BusinessValue = $businessValue
    HypothesisStatement = $hypothesisStatement
}

# Validatie
if ($ValidateOutput) {
    Write-Status "`n✅ Validatie..." "Info"
    $validationIssues = Validate-Hypothesis -Data $hypothesisData
    
    if ($validationIssues.Count -gt 0) {
        Write-Status "`nKwaliteitswaarschuwingen:" "Warning"
        foreach ($issue in $validationIssues) {
            Write-Status "  $issue" "Warning"
        }
        Write-Status ""
    } else {
        Write-Status "✅ Alle quality gates voldaan" "Success"
    }
}

# Maak output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -Path $OutputDir -ItemType Directory | Out-Null
}

# Bepaal output bestand
if (-not $OutputFile) {
    $OutputFile = Join-Path $OutputDir "founding-hypothesis-$name.md"
}

# Genereer output
Write-Status "`n📝 Genereer hypothesis documenten..." "Info"

$outputs = @()

if ($OutputFormat -eq "Markdown" -or $OutputFormat -eq "Both") {
    $markdown = Generate-HypothesisMarkdown -Data $hypothesisData
    [System.IO.File]::WriteAllText($OutputFile, $markdown, [System.Text.Encoding]::UTF8)
    Write-Status "✅ Markdown gegenereerd: $OutputFile" "Success"
    $outputs += $OutputFile
}

if ($OutputFormat -eq "JSON" -or $OutputFormat -eq "Both") {
    $jsonFile = $OutputFile -replace '\.md$', '.json'
    $json = Generate-HypothesisJson -Data $hypothesisData
    [System.IO.File]::WriteAllText($jsonFile, $json, [System.Text.Encoding]::UTF8)
    Write-Status "✅ JSON gegenereerd: $jsonFile" "Success"
    $outputs += $jsonFile
}

# Samenvatting
Write-Status "`n📊 Samenvatting:" "Info"
Write-Status "===============" "Info"
Write-Status "Hypothesis: $name" "Info"
Write-Status "Doelgroep: $TargetAudience" "Info"
Write-Status "Success criteria: $($successCriteria.Count)" "Info"
Write-Status "Aannames: $($assumptions.Count)" "Info"
Write-Status "Output bestanden: $($outputs.Count)" "Info"

Write-Status "`n✅ Founding Hypothesis succesvol gegenereerd!" "Success"
Write-Status "Datum: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "Info"

exit 0
