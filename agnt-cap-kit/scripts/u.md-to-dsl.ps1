<#
.SYNOPSIS
    Converteert Markdown architectuurbeschrijvingen naar Structurizr DSL workspace bestanden.

.DESCRIPTION
    Dit script is onderdeel van de u.md-to-dsl utility agent.
    Het converteert Markdown architectuurbeschrijvingen naar syntactisch correcte Structurizr DSL.
    
    Het script parseert Markdown voor C4 elementen en genereert een workspace.dsl bestand.

.PARAMETER InputFile
    Het pad naar het Markdown bestand dat geconverteerd moet worden.

.PARAMETER OutputFile
    Optioneel: Het pad voor het output DSL bestand.
    Standaard: workspace.dsl in dezelfde folder als input.

.PARAMETER WorkspaceName
    Optioneel: Naam van de workspace (voor DSL header).
    Standaard: Afgeleid van input bestandsnaam.

.PARAMETER WorkspaceDescription
    Optioneel: Beschrijving van de workspace.
    Standaard: "Generated from Markdown architecture description".

.PARAMETER UseHierarchical
    Switch: Gebruik hierarchical identifiers in DSL.
    Aanbevolen voor complexe modellen met meerdere containers.

.PARAMETER Validate
    Switch: Valideer de gegenereerde DSL syntax.
    Vereist Structurizr CLI in PATH.

.EXAMPLE
    .\u.md-to-dsl.ps1 -InputFile "architecture.md"
    
    Converteert architecture.md naar workspace.dsl in dezelfde folder.

.EXAMPLE
    .\u.md-to-dsl.ps1 -InputFile "C:\docs\arch.md" -OutputFile "C:\output\model.dsl" -UseHierarchical
    
    Converteert met hierarchical identifiers naar specifieke output locatie.

.EXAMPLE
    .\u.md-to-dsl.ps1 -InputFile "design.md" -Validate
    
    Converteert en valideert de gegenereerde DSL met Structurizr CLI.

.NOTES
    Agent: u.md-to-dsl
    Versie: 1.0
    Type: Utility Agent - Converter
    
    Requirements:
    - PowerShell 5.1 of hoger
    - Structurizr CLI (optioneel, voor validatie)
    
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias("FullName", "Path")]
    [string]$InputFile,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile,
    
    [Parameter(Mandatory=$false)]
    [string]$WorkspaceName,
    
    [Parameter(Mandatory=$false)]
    [string]$WorkspaceDescription = "Generated from Markdown architecture description",
    
    [Parameter(Mandatory=$false)]
    [switch]$UseHierarchical,
    
    [Parameter(Mandatory=$false)]
    [switch]$Validate
)

begin {
    # Kleuren voor output
    $ColorSuccess = "Green"
    $ColorError = "Red"
    $ColorWarning = "Yellow"
    $ColorInfo = "Cyan"
    
    Write-Host "`n=== Markdown naar Structurizr DSL Converter ===" -ForegroundColor $ColorInfo
    Write-Host "Agent: u.md-to-dsl`n" -ForegroundColor $ColorInfo
    
    # Helper functie: Parse Markdown sectie
    function Get-MarkdownSection {
        param([string[]]$Lines, [string]$Header)
        $inSection = $false
        $sectionLines = @()
        
        foreach ($line in $Lines) {
            if ($line -match "^##\s+$Header") {
                $inSection = $true
                continue
            }
            if ($inSection -and $line -match "^##\s+") {
                break
            }
            if ($inSection -and $line.Trim()) {
                $sectionLines += $line
            }
        }
        return $sectionLines
    }
    
    # Helper functie: Parse element uit Markdown
    function Parse-Element {
        param([string]$Line)
        
        if ($Line -match '^\s*-\s+([^:]+):\s+(.+)$') {
            return @{
                Name = $matches[1].Trim()
                Description = $matches[2].Trim()
            }
        }
        return $null
    }
    
    # Helper functie: Genereer DSL identifier
    function Get-DslIdentifier {
        param([string]$Name)
        
        # Converteer naar camelCase identifier
        $identifier = $Name -replace '[^a-zA-Z0-9\s]', ''
        $identifier = $identifier -replace '\s+', ' '
        $words = $identifier.Split(' ')
        
        if ($words.Count -eq 1) {
            return $words[0].ToLower()
        }
        
        $result = $words[0].ToLower()
        for ($i = 1; $i -lt $words.Count; $i++) {
            if ($words[$i].Length -gt 0) {
                $result += $words[$i].Substring(0,1).ToUpper() + $words[$i].Substring(1).ToLower()
            }
        }
        
        return $result
    }
}

process {
    try {
        # Stap 1: Valideer input bestand
        Write-Host "[1/7] Valideren input bestand..." -ForegroundColor $ColorInfo
        
        if (-not (Test-Path $InputFile)) {
            throw "Het bestand '$InputFile' is niet gevonden. Controleer het pad en probeer opnieuw."
        }
        
        $inputItem = Get-Item $InputFile
        
        if ($inputItem.Extension -ne ".md") {
            Write-Warning "Het bestand heeft geen .md extensie. Doorgaan met conversie..."
        }
        
        Write-Host "  ✓ Input bestand: $($inputItem.FullName)" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ Grootte: $([math]::Round($inputItem.Length / 1KB, 2)) KB`n" -ForegroundColor $ColorSuccess
        
        # Stap 2: Bepaal output bestand
        Write-Host "[2/7] Bepalen output locatie..." -ForegroundColor $ColorInfo
        
        if ([string]::IsNullOrWhiteSpace($OutputFile)) {
            $OutputFile = Join-Path $inputItem.DirectoryName "workspace.dsl"
        }
        
        if ([string]::IsNullOrWhiteSpace($WorkspaceName)) {
            $WorkspaceName = [System.IO.Path]::GetFileNameWithoutExtension($inputItem.Name)
        }
        
        Write-Host "  ✓ Output bestand: $OutputFile" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ Workspace naam: $WorkspaceName" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ Hierarchical: $UseHierarchical`n" -ForegroundColor $ColorSuccess
        
        # Stap 3: Parse Markdown
        Write-Host "[3/7] Parsen Markdown architectuur..." -ForegroundColor $ColorInfo
        
        $content = Get-Content $InputFile -Raw
        $lines = Get-Content $InputFile
        
        # Parse secties
        $systems = Get-MarkdownSection -Lines $lines -Header "Systemen|Systems"
        $containers = Get-MarkdownSection -Lines $lines -Header "Containers"
        $components = Get-MarkdownSection -Lines $lines -Header "Components|Componenten"
        $relationships = Get-MarkdownSection -Lines $lines -Header "Relaties|Relationships"
        
        Write-Host "  ✓ Gevonden: $($systems.Count) systemen" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ Gevonden: $($containers.Count) containers" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ Gevonden: $($components.Count) componenten" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ Gevonden: $($relationships.Count) relaties`n" -ForegroundColor $ColorSuccess
        
        # Stap 4: Bouw DSL model
        Write-Host "[4/7] Bouwen DSL model..." -ForegroundColor $ColorInfo
        
        $dslBuilder = @()
        $dslBuilder += "workspace `"$WorkspaceName`" `"$WorkspaceDescription`" {"
        $dslBuilder += ""
        
        if ($UseHierarchical) {
            $dslBuilder += "    !identifiers hierarchical"
            $dslBuilder += ""
        }
        
        $dslBuilder += "    model {"
        
        # Parse systems
        $personElements = @()
        $externalSystems = @()
        $primarySystem = $null
        
        foreach ($line in $systems) {
            $element = Parse-Element -Line $line
            if ($element) {
                $identifier = Get-DslIdentifier -Name $element.Name
                
                # Detect person vs system
                if ($element.Description -match 'user|gebruiker|engineer|developer|admin') {
                    $personElements += @{
                        Identifier = $identifier
                        Name = $element.Name
                        Description = $element.Description
                    }
                }
                elseif ($element.Description -match 'extern|external') {
                    $externalSystems += @{
                        Identifier = $identifier
                        Name = $element.Name
                        Description = $element.Description -replace '\s*\(extern.*\)', ''
                    }
                }
                else {
                    # Primary system (eerste niet-externe)
                    if (-not $primarySystem) {
                        $primarySystem = @{
                            Identifier = $identifier
                            Name = $element.Name
                            Description = $element.Description
                        }
                    }
                }
            }
        }
        
        # Schrijf persons
        foreach ($person in $personElements) {
            $dslBuilder += "        $($person.Identifier) = person `"$($person.Name)`" `"$($person.Description)`""
        }
        
        if ($personElements.Count -gt 0) {
            $dslBuilder += ""
        }
        
        # Schrijf external systems
        foreach ($ext in $externalSystems) {
            $dslBuilder += "        $($ext.Identifier) = softwareSystem `"$($ext.Name)`" `"$($ext.Description)`" `"External`""
        }
        
        if ($externalSystems.Count -gt 0) {
            $dslBuilder += ""
        }
        
        # Schrijf primary system
        if ($primarySystem) {
            $dslBuilder += "        $($primarySystem.Identifier) = softwareSystem `"$($primarySystem.Name)`" `"$($primarySystem.Description)`" {"
            
            # Containers
            if ($containers.Count -gt 0) {
                foreach ($line in $containers) {
                    $element = Parse-Element -Line $line
                    if ($element) {
                        $identifier = Get-DslIdentifier -Name $element.Name
                        $dslBuilder += "            $identifier = container `"$($element.Name)`" `"$($element.Description)`" `"Technology`""
                    }
                }
            }
            
            $dslBuilder += "        }"
        }
        
        $dslBuilder += "    }"
        $dslBuilder += ""
        
        Write-Host "  ✓ Model gebouwd met elementen" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ Persons: $($personElements.Count)" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ External systems: $($externalSystems.Count)" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ Primary system: $($primarySystem -ne $null)`n" -ForegroundColor $ColorSuccess
        
        # Stap 5: Genereer views
        Write-Host "[5/7] Genereren views..." -ForegroundColor $ColorInfo
        
        $dslBuilder += "    views {"
        
        if ($primarySystem) {
            $dslBuilder += "        systemContext $($primarySystem.Identifier) `"SystemContext`" {"
            $dslBuilder += "            include *"
            $dslBuilder += "        }"
            $dslBuilder += ""
            
            if ($containers.Count -gt 0) {
                $dslBuilder += "        container $($primarySystem.Identifier) `"Containers`" {"
                $dslBuilder += "            include *"
                $dslBuilder += "        }"
                $dslBuilder += ""
            }
        }
        
        # Styles
        $dslBuilder += "        styles {"
        $dslBuilder += "            element `"Person`" {"
        $dslBuilder += "                shape person"
        $dslBuilder += "                background #08427b"
        $dslBuilder += "                color #ffffff"
        $dslBuilder += "            }"
        $dslBuilder += "            element `"Software System`" {"
        $dslBuilder += "                background #1168bd"
        $dslBuilder += "                color #ffffff"
        $dslBuilder += "            }"
        $dslBuilder += "            element `"External`" {"
        $dslBuilder += "                background #999999"
        $dslBuilder += "                color #ffffff"
        $dslBuilder += "            }"
        $dslBuilder += "            element `"Container`" {"
        $dslBuilder += "                background #438dd5"
        $dslBuilder += "                color #ffffff"
        $dslBuilder += "            }"
        $dslBuilder += "        }"
        $dslBuilder += "    }"
        
        $dslBuilder += "}"
        
        Write-Host "  ✓ Views gegenereerd" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ Styles toegevoegd`n" -ForegroundColor $ColorSuccess
        
        # Stap 6: Schrijf output
        Write-Host "[6/7] Schrijven DSL bestand..." -ForegroundColor $ColorInfo
        
        $dslBuilder | Set-Content -Path $OutputFile -Encoding UTF8
        
        $outputItem = Get-Item $OutputFile
        Write-Host "  ✓ DSL bestand aangemaakt" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ Grootte: $([math]::Round($outputItem.Length / 1KB, 2)) KB`n" -ForegroundColor $ColorSuccess
        
        # Stap 7: Validatie (optioneel)
        Write-Host "[7/7] Validatie..." -ForegroundColor $ColorInfo
        
        if ($Validate) {
            try {
                $structurizr = Get-Command structurizr-cli -ErrorAction Stop
                Write-Host "  → Structurizr CLI gevonden: $($structurizr.Source)" -ForegroundColor $ColorInfo
                
                & structurizr-cli validate -workspace $OutputFile 2>&1 | Out-Null
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✓ DSL validatie succesvol`n" -ForegroundColor $ColorSuccess
                } else {
                    Write-Warning "DSL validatie gefaald. Controleer de syntax handmatig."
                }
            }
            catch {
                Write-Host "  ⚠ Structurizr CLI niet gevonden - validatie overgeslagen" -ForegroundColor $ColorWarning
                Write-Host "    Installeer via: https://structurizr.com/help/cli`n" -ForegroundColor $ColorWarning
            }
        } else {
            Write-Host "  ⊘ Validatie overgeslagen (gebruik -Validate om te activeren)`n" -ForegroundColor $ColorWarning
        }
        
        # Succesbericht
        Write-Host "════════════════════════════════════════" -ForegroundColor $ColorSuccess
        Write-Host "✅ CONVERSIE SUCCESVOL!" -ForegroundColor $ColorSuccess
        Write-Host "════════════════════════════════════════" -ForegroundColor $ColorSuccess
        Write-Host ""
        Write-Host "Input:      $($inputItem.FullName)" -ForegroundColor White
        Write-Host "Output:     $($outputItem.FullName)" -ForegroundColor White
        Write-Host "Workspace:  $WorkspaceName" -ForegroundColor White
        Write-Host "Elementen:  $($personElements.Count + $externalSystems.Count + ($primarySystem -ne $null ? 1 : 0))" -ForegroundColor White
        Write-Host ""
        Write-Host "Volgende stap:" -ForegroundColor $ColorInfo
        Write-Host "  1. Open workspace.dsl in Structurizr Lite" -ForegroundColor White
        Write-Host "  2. Positioneer elementen handmatig (geen autolayout)" -ForegroundColor White
        Write-Host "  3. Exporteer diagrammen naar PNG/SVG" -ForegroundColor White
        Write-Host ""
        
    }
    catch {
        # Foutafhandeling
        Write-Host "`n════════════════════════════════════════" -ForegroundColor $ColorError
        Write-Host "❌ CONVERSIE MISLUKT" -ForegroundColor $ColorError
        Write-Host "════════════════════════════════════════" -ForegroundColor $ColorError
        Write-Host ""
        Write-Host "Fout: $($_.Exception.Message)" -ForegroundColor $ColorError
        Write-Host ""
        Write-Host "Mogelijke oplossingen:" -ForegroundColor $ColorWarning
        Write-Host "  1. Controleer of de Markdown correct gestructureerd is" -ForegroundColor $ColorWarning
        Write-Host "  2. Gebruik headers: ## Systemen, ## Containers, ## Relaties" -ForegroundColor $ColorWarning
        Write-Host "  3. Format: - Naam: Beschrijving" -ForegroundColor $ColorWarning
        Write-Host "  4. Gebruik @github /u.md-to-dsl voor AI-ondersteuning" -ForegroundColor $ColorWarning
        Write-Host ""
        
        throw
    }
}

end {
    Write-Host "=== Conversie voltooid ===" -ForegroundColor $ColorInfo
    Write-Host ""
}
