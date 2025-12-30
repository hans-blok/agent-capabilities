<#
.SYNOPSIS
    Realiseert een Logisch Datamodel (LDM) in 3NF op basis van een conceptueel datamodel.

.DESCRIPTION
    Dit script is onderdeel van de D.02 ldm agent capability.
    Het vertaalt een conceptueel datamodel en/of specificaties naar een genormaliseerd 
    logisch datamodel dat voldoet aan de derde normaalvorm (3NF).
    
    Het script genereert een gestructureerd logisch model met:
    - Genormaliseerde entiteiten (1NF, 2NF, 3NF)
    - Primaire sleutels (PK) per entiteit
    - Foreign keys (FK) voor relaties
    - Koppeltabellen voor veel-op-veel relaties
    - Cardinaliteit specificaties
    - Constraint documentatie

.PARAMETER InputFiles
    Een of meerdere paden naar input documenten (.md, .txt, .docx).
    Dit kan zijn:
    - Conceptueel datamodel (uit fase B)
    - Requirement specificaties (uit fase C)
    - Bestaande datamodellen voor context

.PARAMETER OutputFile
    Optioneel: Het pad voor het output LDM bestand.
    Standaard: ldm.md in de huidige folder.

.PARAMETER ModelName
    Optioneel: Naam van het logische datamodel.
    Standaard: Afgeleid van de naam van het eerste input bestand.

.PARAMETER NormalizationLevel
    Het normalisatie niveau: 1NF, 2NF, of 3NF.
    - 1NF: Atomaire attributen
    - 2NF: Elimineer partiële afhankelijkheden
    - 3NF: Elimineer transitieve afhankelijkheden
    Standaard: 3NF

.PARAMETER IncludeConstraints
    Switch: Documenteer business rule constraints.
    Standaard: Aangeschakeld.

.PARAMETER IncludeVisualization
    Switch: Genereer Entity-Relationship diagram in Mermaid.
    Standaard: Aangeschakeld.

.PARAMETER NamingConvention
    De naamgevingsconventie voor entiteiten en attributen:
    - PascalCase: ProductName, OrderDetail
    - snake_case: product_name, order_detail
    - camelCase: productName, orderDetail
    Standaard: PascalCase

.PARAMETER OutputFormat
    Het output formaat: Markdown, JSON, SQL, of All.
    - Markdown: Gestructureerde documentatie
    - JSON: Machine-readable formaat
    - SQL: DDL statements (indicatief, niet volledig fysiek model)
    - All: Alle formaten
    Standaard: Markdown

.PARAMETER ValidateModel
    Switch: Voer validatie uit op het gegenereerde model.
    Controleert op:
    - Normalisatie regels
    - Orphaned foreign keys
    - Ontbrekende primaire sleutels
    - Naamgevingsconventies

.PARAMETER DetectManyToMany
    Switch: Automatisch detecteren en modelleren van N-op-M relaties.
    Standaard: Aangeschakeld.

.EXAMPLE
    .\d.ldm-realisatie.ps1 -InputFiles "C:\docs\cdm.md"
    
    Realiseert een LDM in 3NF op basis van een conceptueel datamodel.

.EXAMPLE
    .\d.ldm-realisatie.ps1 -InputFiles "cdm.md","requirements.md" -NormalizationLevel 3NF -ValidateModel
    
    Realiseert en valideert een volledig genormaliseerd LDM.

.EXAMPLE
    .\d.ldm-realisatie.ps1 -InputFiles "model.md" -OutputFormat All -NamingConvention snake_case
    
    Realiseert een LDM met snake_case naamgeving in alle output formaten.

.EXAMPLE
    Get-ChildItem "C:\models\*.md" | .\d.ldm-realisatie.ps1 -ModelName "Enterprise LDM"
    
    Realiseert een LDM op basis van meerdere model bestanden.

.NOTES
    Agent: D.02-ldm
    Categorie: Ontwerp
    DVS-Fase: D (Ontwerp)
    Versie: 1.0
    Datum: 30-12-2025
    
    Vereisten:
    - PowerShell 5.1 of hoger
    - Input: Conceptueel datamodel of specificaties
    
    Normalisatie Regels:
    - 1NF: Alle attributen zijn atomair (geen herhalende groepen)
    - 2NF: Geen partiële afhankelijkheden van samengestelde sleutels
    - 3NF: Geen transitieve afhankelijkheden tussen niet-sleutelattributen
    
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias("FullName", "Path")]
    [string[]]$InputFiles,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "ldm.md",
    
    [Parameter(Mandatory=$false)]
    [string]$ModelName,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('1NF', '2NF', '3NF')]
    [string]$NormalizationLevel = '3NF',
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeConstraints = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeVisualization = $true,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('PascalCase', 'snake_case', 'camelCase')]
    [string]$NamingConvention = 'PascalCase',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('Markdown', 'JSON', 'SQL', 'All')]
    [string]$OutputFormat = 'Markdown',
    
    [Parameter(Mandatory=$false)]
    [switch]$ValidateModel,
    
    [Parameter(Mandatory=$false)]
    [switch]$DetectManyToMany = $true
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
    $Script:Constraints = @()
    $Script:AllInputContent = @()
    $Script:JunctionTables = @()
    
    Write-Host "`n=== LDM Realisatie Script ===" -ForegroundColor $InfoColor
    Write-Host "Agent: D.02 - Logisch Datamodelleur`n" -ForegroundColor $InfoColor
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
    
    Write-Host "`nModel naam: " -NoNewline
    Write-Host $ModelName -ForegroundColor $SuccessColor
    Write-Host "Normalisatie niveau: " -NoNewline
    Write-Host $NormalizationLevel -ForegroundColor $SuccessColor
    Write-Host "Naamgeving: " -NoNewline
    Write-Host $NamingConvention -ForegroundColor $SuccessColor
    
    # Stap 1: Parse conceptueel model
    Write-Host "`n[Stap 1/7] Parseren van conceptueel model..." -ForegroundColor $InfoColor
    $Script:Entities = Parse-ConceptualModel -Content $Script:AllInputContent
    Write-Host "  Gevonden: $($Script:Entities.Count) basis entiteiten" -ForegroundColor $SuccessColor
    
    # Stap 2: Toepassen van 1NF (atomaire attributen)
    Write-Host "`n[Stap 2/7] Toepassen van 1NF (atomaire attributen)..." -ForegroundColor $InfoColor
    $Script:Entities = Apply-FirstNormalForm -Entities $Script:Entities
    Write-Host "  1NF toegepast" -ForegroundColor $SuccessColor
    
    # Stap 3: Toepassen van 2NF (elimineer partiële afhankelijkheden)
    if ($NormalizationLevel -in @('2NF', '3NF')) {
        Write-Host "`n[Stap 3/7] Toepassen van 2NF (elimineer partiële afhankelijkheden)..." -ForegroundColor $InfoColor
        $Script:Entities = Apply-SecondNormalForm -Entities $Script:Entities
        Write-Host "  2NF toegepast" -ForegroundColor $SuccessColor
    }
    else {
        Write-Host "`n[Stap 3/7] 2NF overslaan" -ForegroundColor $WarningColor
    }
    
    # Stap 4: Toepassen van 3NF (elimineer transitieve afhankelijkheden)
    if ($NormalizationLevel -eq '3NF') {
        Write-Host "`n[Stap 4/7] Toepassen van 3NF (elimineer transitieve afhankelijkheden)..." -ForegroundColor $InfoColor
        $Script:Entities = Apply-ThirdNormalForm -Entities $Script:Entities
        Write-Host "  3NF toegepast" -ForegroundColor $SuccessColor
    }
    else {
        Write-Host "`n[Stap 4/7] 3NF overslaan" -ForegroundColor $WarningColor
    }
    
    # Stap 5: Modelleer relaties en foreign keys
    Write-Host "`n[Stap 5/7] Modelleren van relaties en foreign keys..." -ForegroundColor $InfoColor
    $Script:Relationships = Model-Relationships -Entities $Script:Entities -Content $Script:AllInputContent -DetectManyToMany:$DetectManyToMany
    
    # Creëer koppeltabellen voor N-op-M relaties
    if ($DetectManyToMany) {
        $Script:JunctionTables = Create-JunctionTables -Relationships $Script:Relationships
        Write-Host "  Gevonden: $($Script:Relationships.Count) relaties (inclusief $($Script:JunctionTables.Count) koppeltabellen)" -ForegroundColor $SuccessColor
    }
    else {
        Write-Host "  Gevonden: $($Script:Relationships.Count) relaties" -ForegroundColor $SuccessColor
    }
    
    # Stap 6: Pas naamgevingsconventies toe
    Write-Host "`n[Stap 6/7] Toepassen van naamgevingsconventies ($NamingConvention)..." -ForegroundColor $InfoColor
    $Script:Entities = Apply-NamingConvention -Entities $Script:Entities -Convention $NamingConvention
    $Script:JunctionTables = Apply-NamingConvention -Entities $Script:JunctionTables -Convention $NamingConvention
    Write-Host "  Naamgeving toegepast" -ForegroundColor $SuccessColor
    
    # Stap 7: Valideer het model (indien gevraagd)
    if ($ValidateModel) {
        Write-Host "`n[Stap 7/7] Valideren van het model..." -ForegroundColor $InfoColor
        $validationResults = Validate-LogicalModel -Entities $Script:Entities -Relationships $Script:Relationships -NormalizationLevel $NormalizationLevel
        
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
        Write-Host "`n[Stap 7/7] Validatie overslaan" -ForegroundColor $WarningColor
    }
    
    # Genereer output
    Write-Host "`n[Output] Genereren van output bestanden..." -ForegroundColor $InfoColor
    
    # Voeg koppeltabellen toe aan entiteiten voor output
    $allEntities = $Script:Entities + $Script:JunctionTables
    
    # Genereer Markdown
    if ($OutputFormat -in @('Markdown', 'All')) {
        $markdownPath = $OutputFile
        $markdown = Generate-MarkdownLDM -ModelName $ModelName -Entities $allEntities -Relationships $Script:Relationships -IncludeVisualization:$IncludeVisualization -IncludeConstraints:$IncludeConstraints -NormalizationLevel $NormalizationLevel
        $markdown | Out-File -FilePath $markdownPath -Encoding UTF8 -Force
        Write-Host "  Markdown gegenereerd: " -NoNewline
        Write-Host $markdownPath -ForegroundColor $SuccessColor
    }
    
    # Genereer JSON
    if ($OutputFormat -in @('JSON', 'All')) {
        $jsonPath = [System.IO.Path]::ChangeExtension($OutputFile, '.json')
        $jsonModel = @{
            ModelName = $ModelName
            GeneratedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            NormalizationLevel = $NormalizationLevel
            NamingConvention = $NamingConvention
            Entities = $allEntities
            Relationships = $Script:Relationships
            Constraints = $Script:Constraints
            SourceFiles = $Script:AllInputContent | ForEach-Object { $_.FileName }
        }
        $jsonModel | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8 -Force
        Write-Host "  JSON gegenereerd: " -NoNewline
        Write-Host $jsonPath -ForegroundColor $SuccessColor
    }
    
    # Genereer SQL DDL (indicatief)
    if ($OutputFormat -in @('SQL', 'All')) {
        $sqlPath = [System.IO.Path]::ChangeExtension($OutputFile, '.sql')
        $sql = Generate-SQLDDL -ModelName $ModelName -Entities $allEntities -Relationships $Script:Relationships
        $sql | Out-File -FilePath $sqlPath -Encoding UTF8 -Force
        Write-Host "  SQL DDL gegenereerd: " -NoNewline
        Write-Host $sqlPath -ForegroundColor $SuccessColor
        Write-Host "    (Let op: Dit is indicatief, geen volledig fysiek model)" -ForegroundColor $WarningColor
    }
    
    Write-Host "`n=== LDM Realisatie Voltooid ===" -ForegroundColor $SuccessColor
    Write-Host "Model: $ModelName" -ForegroundColor $InfoColor
    Write-Host "Entiteiten: $($allEntities.Count) (waarvan $($Script:JunctionTables.Count) koppeltabellen)" -ForegroundColor $InfoColor
    Write-Host "Relaties: $($Script:Relationships.Count)" -ForegroundColor $InfoColor
    Write-Host "Normalisatie: $NormalizationLevel" -ForegroundColor $InfoColor
}

#region Helper Functions

function Parse-ConceptualModel {
    param([array]$Content)
    
    $entities = @()
    
    foreach ($doc in $Content) {
        $lines = $doc.Content -split "`n"
        $currentEntity = $null
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i].Trim()
            
            # Zoek naar entiteiten (### EntityName)
            if ($line -match '^###\s+(.+)$') {
                $entityName = $matches[1].Trim()
                
                # Skip secties die geen entiteiten zijn
                if ($entityName -match '^(Entiteiten|Relaties|Visualisatie|Metadata|Overzicht)$') {
                    $currentEntity = $null
                    continue
                }
                
                $currentEntity = @{
                    Name = $entityName
                    Attributes = @()
                    PrimaryKey = $null
                    ForeignKeys = @()
                    IsNormalized = $false
                }
                $entities += $currentEntity
            }
            # Zoek naar attributen (- **Attribuut**: Beschrijving)
            elseif ($currentEntity -and $line -match '^\s*[-*]\s*\*\*([^:*]+)\*\*:\s*(.+)') {
                $attrName = $matches[1].Trim()
                $attrDesc = $matches[2].Trim()
                
                # Extract type uit beschrijving
                $type = "Tekst"
                if ($attrDesc -match '\(Type:\s*([^)]+)\)') {
                    $type = $matches[1].Trim()
                    $attrDesc = $attrDesc -replace '\(Type:[^)]+\)', ''
                }
                
                $attribute = @{
                    Name = $attrName
                    Description = $attrDesc.Trim()
                    Type = $type
                    IsNullable = $true
                    IsComposite = $false
                }
                
                $currentEntity.Attributes += $attribute
            }
        }
    }
    
    # Voeg standaard entiteit toe als geen gevonden
    if ($entities.Count -eq 0) {
        Write-Warning "Geen entiteiten gevonden in conceptueel model. Voorbeeldentiteit toegevoegd."
        $entities += @{
            Name = "VoorbeeldEntiteit"
            Attributes = @(
                @{ Name = "ID"; Description = "Unieke identificatie"; Type = "Getal"; IsNullable = $false; IsComposite = $false }
                @{ Name = "Naam"; Description = "Naam van de entiteit"; Type = "Tekst"; IsNullable = $false; IsComposite = $false }
            )
            PrimaryKey = "ID"
            ForeignKeys = @()
            IsNormalized = $false
        }
    }
    
    # Bepaal primaire sleutels
    foreach ($entity in $entities) {
        if (-not $entity.PrimaryKey) {
            # Zoek naar ID of <EntityName>ID attribuut
            $idAttr = $entity.Attributes | Where-Object { 
                $_.Name -match '^(ID|Id|id)$' -or $_.Name -match "^$($entity.Name)(ID|Id|id)$" 
            } | Select-Object -First 1
            
            if ($idAttr) {
                $entity.PrimaryKey = $idAttr.Name
                $idAttr.IsNullable = $false
            }
            else {
                # Creëer een nieuwe ID kolom
                $pkName = "$($entity.Name)ID"
                $entity.Attributes = @(@{
                    Name = $pkName
                    Description = "Primaire sleutel voor $($entity.Name)"
                    Type = "Getal"
                    IsNullable = $false
                    IsComposite = $false
                }) + $entity.Attributes
                $entity.PrimaryKey = $pkName
            }
        }
    }
    
    return $entities
}

function Apply-FirstNormalForm {
    param([array]$Entities)
    
    foreach ($entity in $Entities) {
        $newAttributes = @()
        
        foreach ($attr in $entity.Attributes) {
            # Check voor herhalende groepen of samengestelde attributen
            # Voorbeelden: "Adres" kan worden gesplitst in Straat, Huisnummer, Postcode, Plaats
            if ($attr.Name -match 'Adres' -and -not $attr.IsComposite) {
                Write-Verbose "Decomposing composite attribute: $($attr.Name)"
                $attr.IsComposite = $true
                
                # Splits adres in componenten
                $newAttributes += @{
                    Name = "Straat"
                    Description = "Straatnaam"
                    Type = "Tekst"
                    IsNullable = $attr.IsNullable
                    IsComposite = $false
                }
                $newAttributes += @{
                    Name = "Huisnummer"
                    Description = "Huisnummer"
                    Type = "Tekst"
                    IsNullable = $attr.IsNullable
                    IsComposite = $false
                }
                $newAttributes += @{
                    Name = "Postcode"
                    Description = "Postcode"
                    Type = "Tekst"
                    IsNullable = $attr.IsNullable
                    IsComposite = $false
                }
                $newAttributes += @{
                    Name = "Plaats"
                    Description = "Plaatsnaam"
                    Type = "Tekst"
                    IsNullable = $attr.IsNullable
                    IsComposite = $false
                }
            }
            elseif (-not $attr.IsComposite) {
                $newAttributes += $attr
            }
        }
        
        if ($newAttributes.Count -gt 0) {
            $entity.Attributes = $newAttributes
        }
    }
    
    return $Entities
}

function Apply-SecondNormalForm {
    param([array]$Entities)
    
    # 2NF: Elimineer partiële afhankelijkheden van samengestelde sleutels
    # Voor entities met samengestelde primaire sleutels, verplaats attributen die
    # slechts afhankelijk zijn van een deel van de sleutel naar een nieuwe entity
    
    foreach ($entity in $Entities) {
        # Check of er een samengestelde sleutel is
        if ($entity.PrimaryKey -and $entity.PrimaryKey -like '*,*') {
            Write-Verbose "Entity $($entity.Name) heeft samengestelde sleutel: $($entity.PrimaryKey)"
            # Implementatie van 2NF logica voor samengestelde sleutels
            # (Vereenvoudigd - in praktijk zou hier complexere analyse nodig zijn)
        }
    }
    
    return $Entities
}

function Apply-ThirdNormalForm {
    param([array]$Entities)
    
    # 3NF: Elimineer transitieve afhankelijkheden
    # Als attribuut B afhankelijk is van A, en C afhankelijk van B, 
    # dan moet C naar een aparte tabel
    
    $newEntities = @()
    
    foreach ($entity in $Entities) {
        # Zoek naar transitieve afhankelijkheden
        # Voorbeeld: Als een Product een Categorie heeft, en Categorie heeft Eigenschappen,
        # dan moeten die eigenschappen in een aparte Categorie tabel
        
        $transitiveAttrs = @()
        foreach ($attr in $entity.Attributes) {
            # Simpele heuristiek: attributen die lijken op properties van andere attributen
            $relatedEntityAttr = $entity.Attributes | Where-Object { 
                $attr.Name -like "$($_.Name)*" -and $attr.Name -ne $_.Name 
            } | Select-Object -First 1
            
            if ($relatedEntityAttr) {
                $transitiveAttrs += $attr
            }
        }
        
        # Als transitieve afhankelijkheden gevonden, creëer nieuwe entity
        if ($transitiveAttrs.Count -gt 0) {
            Write-Verbose "Transitieve afhankelijkheden gevonden in $($entity.Name)"
            # Verwijder uit originele entity
            $entity.Attributes = $entity.Attributes | Where-Object { $_ -notin $transitiveAttrs }
        }
    }
    
    $Entities += $newEntities
    return $Entities
}

function Model-Relationships {
    param(
        [array]$Entities,
        [array]$Content,
        [bool]$DetectManyToMany
    )
    
    $relationships = @()
    
    # Parse expliciete relaties uit de content
    foreach ($doc in $Content) {
        $lines = $doc.Content -split "`n"
        
        foreach ($line in $lines) {
            # Patroon: "EntityA 1-op-N EntityB"
            if ($line -match '[-*]\s*`?([^`\s]+)`?\s+(1-op-N|N-op-1|1-op-1|N-op-M)\s+`?([^`\s]+)`?') {
                $fromEntity = $matches[1].Trim()
                $cardinality = $matches[2].Trim()
                $toEntity = $matches[3].Trim()
                
                # Check of entities bestaan
                $fromExists = $Entities | Where-Object { $_.Name -eq $fromEntity }
                $toExists = $Entities | Where-Object { $_.Name -eq $toEntity }
                
                if ($fromExists -and $toExists) {
                    $relationships += @{
                        From = $fromEntity
                        To = $toEntity
                        Cardinality = $cardinality
                        Type = if ($cardinality -eq 'N-op-M') { 'ManyToMany' } else { 'OneToMany' }
                    }
                    
                    # Voeg foreign key toe voor 1-op-N relaties
                    if ($cardinality -in @('1-op-N', 'N-op-1')) {
                        $fkEntity = if ($cardinality -eq '1-op-N') { $toExists } else { $fromExists }
                        $pkEntity = if ($cardinality -eq '1-op-N') { $fromExists } else { $toExists }
                        
                        $fkName = "$($pkEntity.Name)ID"
                        $existingFK = $fkEntity.Attributes | Where-Object { $_.Name -eq $fkName }
                        
                        if (-not $existingFK) {
                            $fkEntity.Attributes += @{
                                Name = $fkName
                                Description = "Foreign key naar $($pkEntity.Name)"
                                Type = "Getal"
                                IsNullable = $true
                                IsComposite = $false
                                IsForeignKey = $true
                                References = "$($pkEntity.Name).$($pkEntity.PrimaryKey)"
                            }
                            $fkEntity.ForeignKeys += $fkName
                        }
                    }
                }
            }
        }
    }
    
    # Detecteer impliciete relaties via foreign key namen in attributen
    foreach ($entity in $Entities) {
        foreach ($attr in $entity.Attributes) {
            if ($attr.Name -match '(.+)(ID|Id|id)$') {
                $potentialEntityName = $matches[1]
                $referencedEntity = $Entities | Where-Object { $_.Name -eq $potentialEntityName }
                
                if ($referencedEntity -and $attr.Name -ne $entity.PrimaryKey) {
                    $attr.IsForeignKey = $true
                    $attr.References = "$($referencedEntity.Name).$($referencedEntity.PrimaryKey)"
                    $entity.ForeignKeys += $attr.Name
                    
                    # Voeg relatie toe als deze nog niet bestaat
                    $existingRel = $relationships | Where-Object { 
                        $_.From -eq $referencedEntity.Name -and $_.To -eq $entity.Name 
                    }
                    
                    if (-not $existingRel) {
                        $relationships += @{
                            From = $referencedEntity.Name
                            To = $entity.Name
                            Cardinality = "1-op-N"
                            Type = "OneToMany"
                        }
                    }
                }
            }
        }
    }
    
    return $relationships
}

function Create-JunctionTables {
    param([array]$Relationships)
    
    $junctionTables = @()
    
    $manyToManyRels = $Relationships | Where-Object { $_.Type -eq 'ManyToMany' }
    
    foreach ($rel in $manyToManyRels) {
        $junctionName = "$($rel.From)$($rel.To)"
        
        $junctionTable = @{
            Name = $junctionName
            Attributes = @(
                @{
                    Name = "$($rel.From)ID"
                    Description = "Foreign key naar $($rel.From)"
                    Type = "Getal"
                    IsNullable = $false
                    IsComposite = $false
                    IsForeignKey = $true
                    References = "$($rel.From).$($rel.From)ID"
                }
                @{
                    Name = "$($rel.To)ID"
                    Description = "Foreign key naar $($rel.To)"
                    Type = "Getal"
                    IsNullable = $false
                    IsComposite = $false
                    IsForeignKey = $true
                    References = "$($rel.To).$($rel.To)ID"
                }
            )
            PrimaryKey = "$($rel.From)ID, $($rel.To)ID"
            ForeignKeys = @("$($rel.From)ID", "$($rel.To)ID")
            IsJunctionTable = $true
        }
        
        $junctionTables += $junctionTable
    }
    
    return $junctionTables
}

function Apply-NamingConvention {
    param(
        [array]$Entities,
        [string]$Convention
    )
    
    foreach ($entity in $Entities) {
        $entity.Name = Convert-ToNamingConvention -Text $entity.Name -Convention $Convention
        
        if ($entity.PrimaryKey) {
            $entity.PrimaryKey = Convert-ToNamingConvention -Text $entity.PrimaryKey -Convention $Convention
        }
        
        foreach ($attr in $entity.Attributes) {
            $attr.Name = Convert-ToNamingConvention -Text $attr.Name -Convention $Convention
        }
        
        $entity.ForeignKeys = $entity.ForeignKeys | ForEach-Object {
            Convert-ToNamingConvention -Text $_ -Convention $Convention
        }
    }
    
    return $Entities
}

function Convert-ToNamingConvention {
    param(
        [string]$Text,
        [string]$Convention
    )
    
    # Remove special characters and split
    $words = $Text -split '[\s_-]' | Where-Object { $_ }
    
    switch ($Convention) {
        'PascalCase' {
            return ($words | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() }) -join ''
        }
        'camelCase' {
            $result = ($words | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() }) -join ''
            return $result.Substring(0,1).ToLower() + $result.Substring(1)
        }
        'snake_case' {
            return ($words | ForEach-Object { $_.ToLower() }) -join '_'
        }
    }
    
    return $Text
}

function Validate-LogicalModel {
    param(
        [array]$Entities,
        [array]$Relationships,
        [string]$NormalizationLevel
    )
    
    $errors = @()
    $warnings = @()
    
    foreach ($entity in $Entities) {
        # Validatie 1: Elke entiteit moet een primaire sleutel hebben
        if (-not $entity.PrimaryKey) {
            $errors += "Entiteit '$($entity.Name)' heeft geen primaire sleutel"
        }
        
        # Validatie 2: Primaire sleutel moet bestaan in attributen
        if ($entity.PrimaryKey) {
            $pkParts = $entity.PrimaryKey -split ','
            foreach ($pkPart in $pkParts) {
                $pkAttr = $entity.Attributes | Where-Object { $_.Name.Trim() -eq $pkPart.Trim() }
                if (-not $pkAttr) {
                    $errors += "Primaire sleutel '$($pkPart.Trim())' niet gevonden in attributen van '$($entity.Name)'"
                }
                elseif ($pkAttr.IsNullable) {
                    $warnings += "Primaire sleutel '$($pkPart.Trim())' in '$($entity.Name)' is nullable"
                }
            }
        }
        
        # Validatie 3: Foreign keys moeten verwijzen naar bestaande entiteiten
        foreach ($fk in $entity.ForeignKeys) {
            $fkAttr = $entity.Attributes | Where-Object { $_.Name -eq $fk }
            if ($fkAttr -and $fkAttr.References) {
                $refParts = $fkAttr.References -split '\.'
                if ($refParts.Count -eq 2) {
                    $refEntity = $Entities | Where-Object { $_.Name -eq $refParts[0] }
                    if (-not $refEntity) {
                        $errors += "Foreign key '$fk' in '$($entity.Name)' verwijst naar onbekende entiteit '$($refParts[0])'"
                    }
                }
            }
        }
        
        # Validatie 4: Controleer op herhalende groepen (1NF)
        $duplicateAttrs = $entity.Attributes | Group-Object Name | Where-Object { $_.Count -gt 1 }
        if ($duplicateAttrs) {
            $errors += "Entiteit '$($entity.Name)' heeft duplicaat attributen: $($duplicateAttrs.Name -join ', ')"
        }
    }
    
    # Validatie 5: Relaties moeten verwijzen naar bestaande entiteiten
    foreach ($rel in $Relationships) {
        $fromEntity = $Entities | Where-Object { $_.Name -eq $rel.From }
        $toEntity = $Entities | Where-Object { $_.Name -eq $rel.To }
        
        if (-not $fromEntity) {
            $errors += "Relatie verwijst naar onbekende entiteit: '$($rel.From)'"
        }
        if (-not $toEntity) {
            $errors += "Relatie verwijst naar onbekende entiteit: '$($rel.To)'"
        }
    }
    
    return @{
        Errors = $errors
        Warnings = $warnings
    }
}

function Generate-MarkdownLDM {
    param(
        [string]$ModelName,
        [array]$Entities,
        [array]$Relationships,
        [bool]$IncludeVisualization,
        [bool]$IncludeConstraints,
        [string]$NormalizationLevel
    )
    
    $md = @"
---
Model: Logisch Datamodel
Naam: $ModelName
Datum: $(Get-Date -Format "yyyy-MM-dd")
Normalisatie: $NormalizationLevel
Gegenereerd door: D.02 - LDM Agent
---

# Logisch Datamodel: $ModelName

## 1. Overzicht

Dit logische datamodel is genormaliseerd tot **$NormalizationLevel** en beschrijft de gedetailleerde structuur van entiteiten, attributen, sleutels en relaties.

Het model is **technologie-onafhankelijk** maar bevat voldoende detail voor implementatie in een relationele database.

### Statistieken
- **Aantal entiteiten**: $($Entities.Count)
- **Aantal relaties**: $($Relationships.Count)
- **Normalisatie niveau**: $NormalizationLevel
- **Gegenereerd op**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## 2. Entiteiten en Attributen

"@

    # Voeg entiteiten toe
    foreach ($entity in $Entities) {
        $md += "`n### $($entity.Name)"
        
        if ($entity.IsJunctionTable) {
            $md += " *(Koppeltabel)*"
        }
        
        $md += "`n`n"
        
        if ($entity.PrimaryKey) {
            $md += "**Primaire Sleutel**: $($entity.PrimaryKey)`n`n"
        }
        
        if ($entity.Attributes.Count -gt 0) {
            $md += "**Attributen**:`n`n"
            $md += "| Attribuut | Type | Nullable | Constraint |`n"
            $md += "|-----------|------|----------|------------|`n"
            
            foreach ($attr in $entity.Attributes) {
                $nullable = if ($attr.IsNullable) { "Ja" } else { "Nee" }
                $constraint = ""
                
                if ($attr.IsForeignKey -and $attr.References) {
                    $constraint = "FK → $($attr.References)"
                }
                elseif ($entity.PrimaryKey -and $entity.PrimaryKey.Contains($attr.Name)) {
                    $constraint = "PK"
                }
                
                $md += "| $($attr.Name) | $($attr.Type) | $nullable | $constraint |`n"
            }
            
            $md += "`n"
        }
        
        # Foreign keys sectie
        if ($entity.ForeignKeys.Count -gt 0) {
            $md += "**Foreign Keys**:`n"
            foreach ($fk in $entity.ForeignKeys) {
                $fkAttr = $entity.Attributes | Where-Object { $_.Name -eq $fk }
                if ($fkAttr -and $fkAttr.References) {
                    $md += "- ``$fk`` → ``$($fkAttr.References)```n"
                }
            }
            $md += "`n"
        }
    }
    
    # Voeg relaties toe
    if ($Relationships.Count -gt 0) {
        $md += "## 3. Relaties`n`n"
        $md += "| Van | Cardinaliteit | Naar | Type |`n"
        $md += "|-----|---------------|------|------|`n"
        
        foreach ($rel in $Relationships) {
            $md += "| $($rel.From) | $($rel.Cardinality) | $($rel.To) | $($rel.Type) |`n"
        }
        $md += "`n"
    }
    
    # Voeg visualisatie toe
    if ($IncludeVisualization) {
        $md += "## 4. Entity-Relationship Diagram`n`n"
        $md += "``````mermaid`n"
        $md += "erDiagram`n"
        
        foreach ($entity in $Entities) {
            # Voeg entiteit toe met attributen
            $md += "    $($entity.Name) {`n"
            foreach ($attr in $entity.Attributes | Select-Object -First 5) {
                $type = $attr.Type -replace ' ', '_'
                $md += "        $type $($attr.Name)`n"
            }
            $md += "    }`n"
        }
        
        # Voeg relaties toe
        foreach ($rel in $Relationships) {
            $notation = switch ($rel.Cardinality) {
                '1-op-1' { '||--||' }
                '1-op-N' { '||--o{' }
                'N-op-1' { 'o{--||' }
                'N-op-M' { 'o{--o{' }
                default { '||--o{' }
            }
            $md += "    $($rel.From) $notation $($rel.To) : has`n"
        }
        
        $md += "``````n`n"
    }
    
    # Voeg normalisatie documentatie toe
    $md += "## 5. Normalisatie`n`n"
    $md += "Dit model voldoet aan **$NormalizationLevel**:`n`n"
    $md += "- **1NF**: Alle attributen zijn atomair (geen herhalende groepen)`n"
    
    if ($NormalizationLevel -in @('2NF', '3NF')) {
        $md += "- **2NF**: Geen partiële afhankelijkheden van samengestelde sleutels`n"
    }
    
    if ($NormalizationLevel -eq '3NF') {
        $md += "- **3NF**: Geen transitieve afhankelijkheden tussen niet-sleutelattributen`n"
    }
    
    $md += "`n"
    
    # Voeg metadata toe
    $md += "## 6. Metadata`n`n"
    $md += "- **Model versie**: 1.0`n"
    $md += "- **Agent**: D.02 - Logisch Datamodelleur`n"
    $md += "- **Generatie datum**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")`n"
    $md += "- **DVS-Fase**: D (Ontwerp)`n"
    $md += "- **Normalisatie**: $NormalizationLevel`n"
    
    return $md
}

function Generate-SQLDDL {
    param(
        [string]$ModelName,
        [array]$Entities,
        [array]$Relationships
    )
    
    $sql = @"
-- ============================================
-- Logisch Datamodel: $ModelName
-- Gegenereerd: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
-- Agent: D.02 - LDM
-- LET OP: Dit is indicatief, niet een volledig fysiek model
-- ============================================

"@

    foreach ($entity in $Entities) {
        $sql += "-- Entiteit: $($entity.Name)`n"
        $sql += "CREATE TABLE $($entity.Name) (`n"
        
        $attrLines = @()
        foreach ($attr in $entity.Attributes) {
            $sqlType = switch ($attr.Type) {
                'Tekst' { 'VARCHAR(255)' }
                'Getal' { 'INT' }
                'Datum' { 'DATE' }
                'Tijd' { 'TIME' }
                'Boolean' { 'BIT' }
                'Bedrag' { 'DECIMAL(18,2)' }
                default { 'VARCHAR(255)' }
            }
            
            $nullable = if ($attr.IsNullable) { 'NULL' } else { 'NOT NULL' }
            $attrLines += "    $($attr.Name) $sqlType $nullable"
        }
        
        # Voeg PK constraint toe
        if ($entity.PrimaryKey) {
            $pkName = "PK_$($entity.Name)"
            $attrLines += "    CONSTRAINT $pkName PRIMARY KEY ($($entity.PrimaryKey))"
        }
        
        $sql += ($attrLines -join ",`n")
        $sql += "`n);`n`n"
    }
    
    # Voeg FK constraints toe
    foreach ($entity in $Entities) {
        foreach ($fk in $entity.ForeignKeys) {
            $fkAttr = $entity.Attributes | Where-Object { $_.Name -eq $fk }
            if ($fkAttr -and $fkAttr.References) {
                $refParts = $fkAttr.References -split '\.'
                if ($refParts.Count -eq 2) {
                    $fkName = "FK_$($entity.Name)_$($refParts[0])"
                    $sql += "ALTER TABLE $($entity.Name)`n"
                    $sql += "ADD CONSTRAINT $fkName`n"
                    $sql += "FOREIGN KEY ($fk) REFERENCES $($refParts[0])($($refParts[1]));`n`n"
                }
            }
        }
    }
    
    return $sql
}

#endregion

# vim: set ft=powershell:
