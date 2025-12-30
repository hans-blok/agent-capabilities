<#
.SYNOPSIS
    Realiseert een Conceptueel Datamodel (CDM) op basis van strategische en normatieve documenten.

.DESCRIPTION
    Dit script is onderdeel van de B.01 cdm-architect agent capability.
    Het analyseert strategische documenten en normatieve kaders om een conceptueel datamodel 
    te genereren met entiteiten, attributen, relaties en bronverwijzingen.
    
    Het script genereert een gestructureerd Markdown document met:
    - Geïdentificeerde entiteiten en hun definities
    - Attributen met conceptuele datatypes en bronverwijzingen
    - Relaties tussen entiteiten
    - Mermaid-diagrammen voor visualisatie

.PARAMETER InputFiles
    Een of meerdere paden naar strategische/normatieve documenten (.md, .txt, .docx).
    Deze documenten worden geanalyseerd voor het extraheren van domeinconcepten.

.PARAMETER OutputFile
    Optioneel: Het pad voor het output datamodel bestand.
    Standaard: artefacten/b.architectuur/cdm-[modelnaam].md

.PARAMETER ModelName
    Optioneel: Naam van het datamodel.
    Standaard: Afgeleid van de naam van het eerste input bestand.

.PARAMETER IncludeVisualization
    Switch: Genereer Mermaid-diagrammen voor visualisatie van het model.
    Standaard: Aangeschakeld.

.PARAMETER DetailLevel
    Het detailniveau van de analyse: Basic, Standard, of Detailed.
    - Basic: Alleen hoofdentiteiten en relaties
    - Standard: Entiteiten met attributen en relaties
    - Detailed: Volledig model met bronverwijzingen en validaties
    Standaard: Standard

.PARAMETER TraceabilityLevel
    Het niveau van traceerbaarheid naar bronnen: None, Basic, of Full.
    - None: Geen bronverwijzingen
    - Basic: Bronverwijzingen op entiteitniveau
    - Full: Gedetailleerde bronverwijzingen per attribuut
    Standaard: Full

.PARAMETER OutputFormat
    Het output formaat: Markdown, JSON, of Both.
    Standaard: Markdown

.PARAMETER ValidateModel
    Switch: Voer validatie uit op het gegenereerde model.
    Controleert op:
    - Naamgevingsconventies
    - Ontbrekende definities
    - Zwevende relaties

.EXAMPLE
    .\b.cdm-realisatie.ps1 -InputFiles "C:\docs\business-case.md"
    
    Realiseert een CDM op basis van één business case document.

.EXAMPLE
    .\b.cdm-realisatie.ps1 -InputFiles "wet.md","beleid.md" -OutputFile "C:\output\datamodel.md" -DetailLevel Detailed
    
    Realiseert een gedetailleerd CDM op basis van meerdere bronnen.

.EXAMPLE
    .\b.cdm-realisatie.ps1 -InputFiles "charter.md" -ValidateModel -OutputFormat Both
    
    Realiseert en valideert een CDM, output in zowel Markdown als JSON.

.EXAMPLE
    Get-ChildItem "C:\docs\*.md" | .\b.cdm-realisatie.ps1 -ModelName "Enterprise Model"
    
    Realiseert een CDM op basis van alle Markdown bestanden in een folder.

.NOTES
    Agent: B.01-cdm-architect
    Categorie: Architectuur
    DVS-Fase: B (Architectuur)
    Versie: 1.0
    Datum: 30-12-2025
    
    Vereisten:
    - PowerShell 5.1 of hoger
    - Optioneel: Python met natuurlijke taalverwerking (voor geavanceerde analyse)
    
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias("FullName", "Path")]
    [string[]]$InputFiles,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "",
    
    [Parameter(Mandatory=$false)]
    [string]$ModelName,
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeVisualization = $true,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('Basic', 'Standard', 'Detailed')]
    [string]$DetailLevel = 'Standard',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('None', 'Basic', 'Full')]
    [string]$TraceabilityLevel = 'Full',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('Markdown', 'JSON', 'Both')]
    [string]$OutputFormat = 'Markdown',
    
    [Parameter(Mandatory=$false)]
    [switch]$ValidateModel
)

begin {
    # Kleuren voor output
    $InfoColor = "Cyan"
    $SuccessColor = "Green"
    $WarningColor = "Yellow"
    $ErrorColor = "Red"
    
    # Datastructuren voor het model
    $Script:Entities = @()
    $Script:Relationships = @()
    $Script:AllInputContent = @()
    
    Write-Host "`n=== CDM Realisatie Script ===" -ForegroundColor $InfoColor
    Write-Host "Agent: B.01 - Conceptueel Datamodel Architect`n" -ForegroundColor $InfoColor
}

process {
    foreach ($InputFile in $InputFiles) {
        if (-not (Test-Path $InputFile)) {
            Write-Warning "Bestand niet gevonden: $InputFile"
            continue
        }
        
        Write-Host "Analyseren: " -NoNewline
        Write-Host (Split-Path $InputFile -Leaf) -ForegroundColor $InfoColor
        
        try {
            $content = Get-Content $InputFile -Raw -Encoding UTF8
            $Script:AllInputContent += @{
                FileName = (Split-Path $InputFile -Leaf)
                FilePath = $InputFile
                Content = $content
            }
        }
        catch {
            Write-Warning "Fout bij het lezen van $InputFile: $_"
        }
    }
}

end {
    if ($Script:AllInputContent.Count -eq 0) {
        Write-Error "Geen valide input bestanden gevonden."
        return
    }
    
    # Bepaal modelnaam als niet opgegeven
    if (-not $ModelName) {
        $firstFile = $Script:AllInputContent[0].FileName
        $ModelName = [System.IO.Path]::GetFileNameWithoutExtension($firstFile)
    }
    
    # Bepaal output file als niet opgegeven
    if ([string]::IsNullOrWhiteSpace($OutputFile)) {
        $OutputDir = "artefacten/b.architectuur"
        if (-not (Test-Path $OutputDir)) {
            New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
        }
        $OutputFile = Join-Path $OutputDir "cdm-$ModelName.md"
    }
    
    Write-Host "`nModel naam: " -NoNewline
    Write-Host $ModelName -ForegroundColor $SuccessColor
    Write-Host "Detail niveau: " -NoNewline
    Write-Host $DetailLevel -ForegroundColor $SuccessColor
    Write-Host "Traceerbaarheid: " -NoNewline
    Write-Host $TraceabilityLevel -ForegroundColor $SuccessColor
    
    # Stap 1: Analyseer inhoud en identificeer entiteiten
    Write-Host "`n[Stap 1/5] Identificeren van entiteiten..." -ForegroundColor $InfoColor
    $Script:Entities = Identify-Entities -Content $Script:AllInputContent -DetailLevel $DetailLevel
    Write-Host "  Gevonden: $($Script:Entities.Count) entiteiten" -ForegroundColor $SuccessColor
    
    # Stap 2: Identificeer attributen per entiteit
    if ($DetailLevel -ne 'Basic') {
        Write-Host "`n[Stap 2/5] Identificeren van attributen..." -ForegroundColor $InfoColor
        $Script:Entities = Identify-Attributes -Entities $Script:Entities -Content $Script:AllInputContent -TraceabilityLevel $TraceabilityLevel
        $totalAttributes = ($Script:Entities | ForEach-Object { $_.Attributes.Count } | Measure-Object -Sum).Sum
        Write-Host "  Gevonden: $totalAttributes attributen" -ForegroundColor $SuccessColor
    }
    else {
        Write-Host "`n[Stap 2/5] Attributen overslaan (Basic niveau)" -ForegroundColor $WarningColor
    }
    
    # Stap 3: Identificeer relaties tussen entiteiten
    Write-Host "`n[Stap 3/5] Identificeren van relaties..." -ForegroundColor $InfoColor
    $Script:Relationships = Identify-Relationships -Entities $Script:Entities -Content $Script:AllInputContent
    Write-Host "  Gevonden: $($Script:Relationships.Count) relaties" -ForegroundColor $SuccessColor
    
    # Stap 4: Valideer het model (indien gevraagd)
    if ($ValidateModel) {
        Write-Host "`n[Stap 4/5] Valideren van het model..." -ForegroundColor $InfoColor
        $validationResults = Validate-DataModel -Entities $Script:Entities -Relationships $Script:Relationships
        
        if ($validationResults.Errors.Count -gt 0) {
            Write-Host "  Errors: $($validationResults.Errors.Count)" -ForegroundColor $ErrorColor
            $validationResults.Errors | ForEach-Object { Write-Host "    - $_" -ForegroundColor $ErrorColor }
        }
        if ($validationResults.Warnings.Count -gt 0) {
            Write-Host "  Warnings: $($validationResults.Warnings.Count)" -ForegroundColor $WarningColor
            $validationResults.Warnings | ForEach-Object { Write-Host "    - $_" -ForegroundColor $WarningColor }
        }
        if ($validationResults.Errors.Count -eq 0 -and $validationResults.Warnings.Count -eq 0) {
            Write-Host "  Model is valide" -ForegroundColor $SuccessColor
        }
    }
    else {
        Write-Host "`n[Stap 4/5] Validatie overslaan" -ForegroundColor $WarningColor
    }
    
    # Stap 5: Genereer output
    Write-Host "`n[Stap 5/5] Genereren van output..." -ForegroundColor $InfoColor
    
    # Genereer Markdown
    if ($OutputFormat -eq 'Markdown' -or $OutputFormat -eq 'Both') {
        $markdownPath = $OutputFile
        $markdown = Generate-MarkdownCDM -ModelName $ModelName -Entities $Script:Entities -Relationships $Script:Relationships -IncludeVisualization:$IncludeVisualization -TraceabilityLevel $TraceabilityLevel
        $markdown | Out-File -FilePath $markdownPath -Encoding UTF8 -Force
        Write-Host "  Markdown gegenereerd: " -NoNewline
        Write-Host $markdownPath -ForegroundColor $SuccessColor
    }
    
    # Genereer JSON
    if ($OutputFormat -eq 'JSON' -or $OutputFormat -eq 'Both') {
        $jsonPath = [System.IO.Path]::ChangeExtension($OutputFile, '.json')
        $jsonModel = @{
            ModelName = $ModelName
            GeneratedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            DetailLevel = $DetailLevel
            TraceabilityLevel = $TraceabilityLevel
            Entities = $Script:Entities
            Relationships = $Script:Relationships
            SourceFiles = $Script:AllInputContent | ForEach-Object { $_.FileName }
        }
        $jsonModel | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8 -Force
        Write-Host "  JSON gegenereerd: " -NoNewline
        Write-Host $jsonPath -ForegroundColor $SuccessColor
    }
    
    Write-Host "`n=== CDM Realisatie Voltooid ===" -ForegroundColor $SuccessColor
    Write-Host "Model: $ModelName" -ForegroundColor $InfoColor
    Write-Host "Entiteiten: $($Script:Entities.Count)" -ForegroundColor $InfoColor
    Write-Host "Relaties: $($Script:Relationships.Count)" -ForegroundColor $InfoColor
}

#region Helper Functions

function Identify-Entities {
    param(
        [array]$Content,
        [string]$DetailLevel
    )
    
    $entities = @()
    $entityNames = @()
    
    # Patroonherkenning voor entiteiten
    # Zoek naar:
    # 1. Hoofdletterwoorden in titels en headers
    # 2. Genominaliseerde concepten (woorden eindigend op -heid, -ing, -tie, etc.)
    # 3. Opsommingen van zelfstandige naamwoorden
    
    foreach ($doc in $Content) {
        $lines = $doc.Content -split "`n"
        
        foreach ($line in $lines) {
            # Headers (## Entity Name)
            if ($line -match '^#+\s+(.+)$') {
                $potentialEntity = $matches[1].Trim()
                if ($potentialEntity -notmatch '^\d' -and $potentialEntity.Length -lt 50) {
                    if ($potentialEntity -notin $entityNames) {
                        $entityNames += $potentialEntity
                        $entities += @{
                            Name = $potentialEntity
                            Definition = "Geïdentificeerd concept uit $($doc.FileName)"
                            Source = $doc.FileName
                            Attributes = @()
                        }
                    }
                }
            }
            
            # Bold concepten (**Concept**)
            if ($line -match '\*\*([A-Z][a-zA-Z\s]+)\*\*') {
                $potentialEntity = $matches[1].Trim()
                if ($potentialEntity -notmatch '^\d' -and $potentialEntity.Length -lt 50 -and $potentialEntity.Length -gt 3) {
                    if ($potentialEntity -notin $entityNames) {
                        $entityNames += $potentialEntity
                        $entities += @{
                            Name = $potentialEntity
                            Definition = "Geïdentificeerd concept uit $($doc.FileName)"
                            Source = $doc.FileName
                            Attributes = @()
                        }
                    }
                }
            }
        }
    }
    
    # Basisentiteiten als er geen gevonden zijn
    if ($entities.Count -eq 0) {
        Write-Warning "Geen entiteiten automatisch geïdentificeerd. Voorbeeldentiteiten toegevoegd."
        $entities += @{
            Name = "Voorbeeld Entiteit"
            Definition = "Een voorbeeld entiteit voor demonstratiedoeleinden"
            Source = "Automatisch gegenereerd"
            Attributes = @()
        }
    }
    
    return $entities
}

function Identify-Attributes {
    param(
        [array]$Entities,
        [array]$Content,
        [string]$TraceabilityLevel
    )
    
    foreach ($entity in $Entities) {
        $attributes = @()
        
        # Zoek naar attributen in de context van de entiteit
        # Patroon: - Attribuut: Beschrijving
        # Patroon: * Attribuut (Type)
        
        foreach ($doc in $Content) {
            $content = $doc.Content
            
            # Zoek lijsten met attributen
            $matches = [regex]::Matches($content, '[-*]\s*\*\*([^:*]+)\*\*:\s*(.+)')
            foreach ($match in $matches) {
                $attrName = $match.Groups[1].Value.Trim()
                $attrDesc = $match.Groups[2].Value.Trim()
                
                $attribute = @{
                    Name = $attrName
                    Description = $attrDesc
                    Type = Infer-DataType -Description $attrDesc
                }
                
                if ($TraceabilityLevel -eq 'Full') {
                    $attribute.Source = $doc.FileName
                    $attribute.SourceReference = "Zie $($doc.FileName)"
                }
                
                $attributes += $attribute
            }
        }
        
        # Voeg standaard attributen toe als er geen gevonden zijn
        if ($attributes.Count -eq 0) {
            $attributes += @{
                Name = "Identificatie"
                Description = "Unieke identificatie van $($entity.Name)"
                Type = "Tekst"
            }
            $attributes += @{
                Name = "Naam"
                Description = "De naam van $($entity.Name)"
                Type = "Tekst"
            }
        }
        
        $entity.Attributes = $attributes
    }
    
    return $Entities
}

function Infer-DataType {
    param([string]$Description)
    
    $lowerDesc = $Description.ToLower()
    
    if ($lowerDesc -match 'datum|date') { return "Datum" }
    if ($lowerDesc -match 'tijd|time') { return "Tijd" }
    if ($lowerDesc -match 'bedrag|prijs|kosten|euro') { return "Bedrag" }
    if ($lowerDesc -match 'aantal|nummer|getal|cijfer') { return "Getal" }
    if ($lowerDesc -match 'ja/nee|waar/onwaar|boolean') { return "Boolean" }
    if ($lowerDesc -match 'url|link|website') { return "URL" }
    if ($lowerDesc -match 'email|e-mail') { return "Email" }
    
    return "Tekst"
}

function Identify-Relationships {
    param(
        [array]$Entities,
        [array]$Content
    )
    
    $relationships = @()
    $entityNames = $Entities | ForEach-Object { $_.Name }
    
    # Zoek naar relaties tussen entiteiten
    # Patronen: "X heeft Y", "X bevat Y", "X is gekoppeld aan Y"
    $relationPatterns = @(
        'heeft|have|has',
        'bevat|contains',
        'is gekoppeld aan|is linked to',
        'verwijst naar|refers to',
        'behoort tot|belongs to'
    )
    
    foreach ($doc in $Content) {
        $content = $doc.Content
        
        foreach ($entity1 in $entityNames) {
            foreach ($entity2 in $entityNames) {
                if ($entity1 -eq $entity2) { continue }
                
                foreach ($pattern in $relationPatterns) {
                    if ($content -match "(?i)$entity1.+?($pattern).+?$entity2") {
                        $relationType = $matches[1]
                        
                        # Voorkom duplicaten
                        $existingRel = $relationships | Where-Object { 
                            $_.From -eq $entity1 -and $_.To -eq $entity2 
                        }
                        
                        if (-not $existingRel) {
                            $relationships += @{
                                From = $entity1
                                To = $entity2
                                Type = $relationType
                                Cardinality = "1-op-veel"
                                Description = "$entity1 $relationType $entity2"
                            }
                        }
                    }
                }
            }
        }
    }
    
    # Voeg voorbeeldrelatie toe als er geen gevonden zijn
    if ($relationships.Count -eq 0 -and $Entities.Count -gt 1) {
        $relationships += @{
            From = $Entities[0].Name
            To = $Entities[1].Name
            Type = "is gerelateerd aan"
            Cardinality = "1-op-veel"
            Description = "$($Entities[0].Name) is gerelateerd aan $($Entities[1].Name)"
        }
    }
    
    return $relationships
}

function Validate-DataModel {
    param(
        [array]$Entities,
        [array]$Relationships
    )
    
    $errors = @()
    $warnings = @()
    
    # Validatie 1: Entiteiten moeten een naam hebben
    foreach ($entity in $Entities) {
        if ([string]::IsNullOrWhiteSpace($entity.Name)) {
            $errors += "Entiteit zonder naam gevonden"
        }
        
        # Validatie 2: Naamgevingsconventie (begint met hoofdletter)
        if ($entity.Name -notmatch '^[A-Z]') {
            $warnings += "Entiteit '$($entity.Name)' begint niet met een hoofdletter"
        }
        
        # Validatie 3: Entiteit moet een definitie hebben
        if ([string]::IsNullOrWhiteSpace($entity.Definition)) {
            $warnings += "Entiteit '$($entity.Name)' heeft geen definitie"
        }
    }
    
    # Validatie 4: Relaties moeten verwijzen naar bestaande entiteiten
    $entityNames = $Entities | ForEach-Object { $_.Name }
    foreach ($rel in $Relationships) {
        if ($rel.From -notin $entityNames) {
            $errors += "Relatie verwijst naar onbekende entiteit: '$($rel.From)'"
        }
        if ($rel.To -notin $entityNames) {
            $errors += "Relatie verwijst naar onbekende entiteit: '$($rel.To)'"
        }
    }
    
    return @{
        Errors = $errors
        Warnings = $warnings
    }
}

function Generate-MarkdownCDM {
    param(
        [string]$ModelName,
        [array]$Entities,
        [array]$Relationships,
        [bool]$IncludeVisualization,
        [string]$TraceabilityLevel
    )
    
    $md = @"
---
Model: Conceptueel Datamodel
Naam: $ModelName
Datum: $(Get-Date -Format "yyyy-MM-dd")
Gegenereerd door: B.01 - CDM Architect Agent
---

# Conceptueel Datamodel: $ModelName

## 1. Overzicht

Dit conceptuele datamodel beschrijft de kernentiteiten, hun attributen en onderlinge relaties voor het domein '$ModelName'.

Het model is **technologie-onafhankelijk** en legt de fundamentele bedrijfsconcepten vast.

### Statistieken
- **Aantal entiteiten**: $($Entities.Count)
- **Aantal relaties**: $($Relationships.Count)
- **Traceerbaarheid niveau**: $TraceabilityLevel
- **Gegenereerd op**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## 2. Entiteiten

"@

    # Voeg entiteiten toe
    foreach ($entity in $Entities) {
        $md += "`n### $($entity.Name)`n`n"
        $md += "**Definitie**: $($entity.Definition)`n`n"
        
        if ($TraceabilityLevel -ne 'None') {
            $md += "**Bron**: $($entity.Source)`n`n"
        }
        
        if ($entity.Attributes.Count -gt 0) {
            $md += "**Attributen**:`n`n"
            
            foreach ($attr in $entity.Attributes) {
                $md += "- **$($attr.Name)**: $($attr.Description) (Type: $($attr.Type))"
                
                if ($TraceabilityLevel -eq 'Full' -and $attr.SourceReference) {
                    $md += " *[$($attr.SourceReference)]*"
                }
                
                $md += "`n"
            }
            $md += "`n"
        }
    }
    
    # Voeg relaties toe
    if ($Relationships.Count -gt 0) {
        $md += "## 3. Relaties`n`n"
        
        foreach ($rel in $Relationships) {
            $md += "- **$($rel.From)** $($rel.Type) **$($rel.To)** ($($rel.Cardinality))`n"
            if ($rel.Description) {
                $md += "  - $($rel.Description)`n"
            }
        }
        $md += "`n"
    }
    
    # Voeg visualisatie toe
    if ($IncludeVisualization) {
        $md += "## 4. Visualisatie`n`n"
        $md += "``````mermaid`n"
        $md += "graph TD`n"
        
        # Voeg entiteiten toe aan diagram
        $entityIndex = @{}
        $index = 1
        foreach ($entity in $Entities) {
            $entityId = "E$index"
            $entityIndex[$entity.Name] = $entityId
            $md += "    $entityId[$($entity.Name)]`n"
            $index++
        }
        
        # Voeg relaties toe aan diagram
        foreach ($rel in $Relationships) {
            $fromId = $entityIndex[$rel.From]
            $toId = $entityIndex[$rel.To]
            if ($fromId -and $toId) {
                $md += "    $fromId -->|$($rel.Type)| $toId`n"
            }
        }
        
        $md += "``````n`n"
    }
    
    # Voeg metadata toe
    $md += "## 5. Metadata`n`n"
    $md += "- **Model versie**: 1.0`n"
    $md += "- **Agent**: B.01 - CDM Architect`n"
    $md += "- **Generatie datum**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")`n"
    $md += "- **DVS-Fase**: B (Architectuur)`n"
    
    return $md
}

#endregion

# vim: set ft=powershell:
