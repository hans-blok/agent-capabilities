<#
.SYNOPSIS
    Converteert Markdown bestanden naar Microsoft Word DOCX formaat.

.DESCRIPTION
    Dit script is onderdeel van de u.md-to-docx agent capability (Utility).
    Het converteert een Markdown (.md) bestand naar DOCX formaat met behoud van structuur.
    
    Het script probeert Pandoc te gebruiken (aanbevolen), en valt terug op alternatieve methoden indien nodig.

.PARAMETER InputFile
    Het pad naar het Markdown bestand dat geconverteerd moet worden.

.PARAMETER OutputFile
    Optioneel: Het pad voor het output DOCX bestand.
    Standaard: Zelfde locatie als input met .docx extensie.

.PARAMETER Force
    Overschrijf bestaand output bestand zonder te vragen.

.EXAMPLE
    .\u.md-to-docx.ps1 -InputFile "C:\docs\specificatie.md"
    
    Converteert specificatie.md naar specificatie.docx in dezelfde folder.

.EXAMPLE
    .\u.md-to-docx.ps1 -InputFile "README.md" -OutputFile "C:\output\README.docx"
    
    Converteert README.md naar een specifieke output locatie.

.EXAMPLE
    Get-ChildItem *.md | ForEach-Object { .\u.md-to-docx.ps1 -InputFile $_.FullName -Force }
    
    Batch conversie van alle .md bestanden in de huidige folder.

.NOTES
    Agent: u.md-to-docx
    Categorie: Utility
    Versie: 1.1
    Vereisten: Pandoc (aanbevolen) of Python met python-docx
    
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias("FullName", "Path")]
    [string]$InputFile,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

begin {
    # Kleuren voor output
    $ColorSuccess = "Green"
    $ColorError = "Red"
    $ColorWarning = "Yellow"
    $ColorInfo = "Cyan"
    
    Write-Host "`n=== Markdown naar DOCX Converter ===" -ForegroundColor $ColorInfo
    Write-Host "Agent: u.md-to-docx (Utility)`n" -ForegroundColor $ColorInfo
}

process {
    try {
        # Stap 1: Valideer input bestand
        Write-Host "[1/4] Valideren input bestand..." -ForegroundColor $ColorInfo
        
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
        Write-Host "[2/4] Bepalen output locatie..." -ForegroundColor $ColorInfo
        
        if ([string]::IsNullOrWhiteSpace($OutputFile)) {
            $OutputFile = [System.IO.Path]::ChangeExtension($inputItem.FullName, ".docx")
        }
        
        # Controleer of output bestand al bestaat
        if ((Test-Path $OutputFile) -and -not $Force) {
            $response = Read-Host "Output bestand '$OutputFile' bestaat al. Overschrijven? (J/N)"
            if ($response -ne "J" -and $response -ne "j") {
                Write-Host "  ✗ Conversie geannuleerd door gebruiker.`n" -ForegroundColor $ColorWarning
                return
            }
        }
        
        Write-Host "  ✓ Output bestand: $OutputFile`n" -ForegroundColor $ColorSuccess
        
        # Stap 3: Conversie uitvoeren
        Write-Host "[3/4] Conversie uitvoeren..." -ForegroundColor $ColorInfo
        
        $conversionSuccess = $false
        $conversionMethod = ""
        
        # Methode 1: Probeer Pandoc (primaire methode)
        try {
            $pandocVersion = & pandoc --version 2>&1 | Select-Object -First 1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  → Pandoc gevonden: $pandocVersion" -ForegroundColor $ColorInfo
                Write-Host "  → Conversie starten met Pandoc..." -ForegroundColor $ColorInfo
                
                & pandoc -f markdown -t docx -o "$OutputFile" "$($inputItem.FullName)" 2>&1 | Out-Null
                
                if ($LASTEXITCODE -eq 0) {
                    $conversionSuccess = $true
                    $conversionMethod = "Pandoc"
                    Write-Host "  ✓ Conversie succesvol met Pandoc`n" -ForegroundColor $ColorSuccess
                }
            }
        }
        catch {
            Write-Host "  ⚠ Pandoc niet beschikbaar" -ForegroundColor $ColorWarning
        }
        
        # Methode 2: Python + python-docx (fallback)
        if (-not $conversionSuccess) {
            try {
                $pythonVersion = & python --version 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  → Python gevonden: $pythonVersion" -ForegroundColor $ColorInfo
                    Write-Host "  → Conversie via Python wordt momenteel niet ondersteund" -ForegroundColor $ColorWarning
                    # TODO: Implementeer Python-gebaseerde conversie
                }
            }
            catch {
                Write-Host "  ⚠ Python niet beschikbaar" -ForegroundColor $ColorWarning
            }
        }
        
        # Methode 3: PowerShell basis conversie (laatste fallback)
        if (-not $conversionSuccess) {
            Write-Host "  → Basis PowerShell conversie (beperkte functionaliteit)" -ForegroundColor $ColorWarning
            Write-Host "  ⚠ Installeer Pandoc voor betere resultaten: https://pandoc.org/`n" -ForegroundColor $ColorWarning
            
            throw "Basis PowerShell conversie nog niet geïmplementeerd. Installeer Pandoc voor volledige functionaliteit."
        }
        
        # Stap 4: Valideer output
        Write-Host "[4/4] Valideren output..." -ForegroundColor $ColorInfo
        
        if (-not (Test-Path $OutputFile)) {
            throw "Output bestand is niet aangemaakt. Conversie gefaald."
        }
        
        $outputItem = Get-Item $OutputFile
        
        if ($outputItem.Length -eq 0) {
            throw "Output bestand is leeg. Conversie gefaald."
        }
        
        Write-Host "  ✓ DOCX bestand aangemaakt" -ForegroundColor $ColorSuccess
        Write-Host "  ✓ Grootte: $([math]::Round($outputItem.Length / 1KB, 2)) KB`n" -ForegroundColor $ColorSuccess
        
        # Succesbericht
        Write-Host "════════════════════════════════════════" -ForegroundColor $ColorSuccess
        Write-Host "✅ CONVERSIE SUCCESVOL!" -ForegroundColor $ColorSuccess
        Write-Host "════════════════════════════════════════" -ForegroundColor $ColorSuccess
        Write-Host ""
        Write-Host "Input:   $($inputItem.FullName)" -ForegroundColor White
        Write-Host "Output:  $($outputItem.FullName)" -ForegroundColor White
        Write-Host "Methode: $conversionMethod" -ForegroundColor White
        Write-Host "Grootte: $([math]::Round($inputItem.Length / 1KB, 2)) KB → $([math]::Round($outputItem.Length / 1KB, 2)) KB" -ForegroundColor White
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
        Write-Host "  1. Installeer Pandoc: https://pandoc.org/installing.html" -ForegroundColor $ColorWarning
        Write-Host "  2. Controleer of het Markdown bestand valide is" -ForegroundColor $ColorWarning
        Write-Host "  3. Controleer of je schrijfrechten hebt voor de output locatie" -ForegroundColor $ColorWarning
        Write-Host ""
        
        # Re-throw voor pipeline
        throw
    }
}

end {
    Write-Host "=== Conversie voltooid ===" -ForegroundColor $ColorInfo
    Write-Host ""
}
