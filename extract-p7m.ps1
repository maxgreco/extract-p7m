<#
.SYNOPSIS
    Strumento robusto per l'estrazione di file .p7m su Windows

.DESCRIPTION
    Questo script estrae il contenuto originale da file firmati digitalmente
    in formato PKCS#7 (.p7m), comunemente usati per la firma digitale in Italia.

    Utilizza OpenSSL per l'estrazione e supporta elaborazione batch, verifica
    firma, visualizzazione certificati e molto altro.

.PARAMETER InputPath
    File .p7m o directory da processare

.PARAMETER OutputDir
    Directory di output (default: stessa del file di input)

.PARAMETER Recursive
    Elabora ricorsivamente tutte le directory

.PARAMETER Verbose
    Output verboso con informazioni dettagliate

.PARAMETER Force
    Sovrascrive i file esistenti senza chiedere

.PARAMETER DryRun
    Simula l'operazione senza estrarre i file

.PARAMETER VerifySignature
    Verifica la firma digitale

.PARAMETER ShowCertInfo
    Mostra informazioni sul certificato

.PARAMETER LogFile
    Salva il log in un file

.PARAMETER NoTimestamps
    Non preserva i timestamp originali dei file

.PARAMETER Help
    Mostra questo messaggio di aiuto

.EXAMPLE
    .\extract-p7m.ps1 documento.pdf.p7m
    Estrae un singolo file

.EXAMPLE
    .\extract-p7m.ps1 -Recursive C:\Documenti
    Estrae tutti i file .p7m in una directory ricorsivamente

.EXAMPLE
    .\extract-p7m.ps1 -VerifySignature -ShowCertInfo documento.pdf.p7m
    Estrae con verifica della firma e mostra info certificato

.NOTES
    Versione: 1.0.0
    Licenza: GPL-3.0
    Requisiti: OpenSSL
#>

[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$InputPath,

    [Parameter()]
    [Alias("o")]
    [string]$OutputDir,

    [Parameter()]
    [Alias("r")]
    [switch]$Recursive,

    [Parameter()]
    [Alias("v")]
    [switch]$VerboseOutput,

    [Parameter()]
    [Alias("f")]
    [switch]$Force,

    [Parameter()]
    [Alias("n")]
    [switch]$DryRun,

    [Parameter()]
    [Alias("s")]
    [switch]$VerifySignature,

    [Parameter()]
    [Alias("c")]
    [switch]$ShowCertInfo,

    [Parameter()]
    [Alias("l")]
    [string]$LogFile,

    [Parameter()]
    [switch]$NoTimestamps,

    [Parameter()]
    [Alias("h")]
    [switch]$Help,

    [Parameter()]
    [Alias("V")]
    [switch]$Version
)

# Versione
$script:VERSION = "1.0.0"

# Statistiche
$script:TotalFiles = 0
$script:SuccessfulExtractions = 0
$script:FailedExtractions = 0
$script:SkippedFiles = 0

################################################################################
# Funzioni di utilità per output colorato
################################################################################

function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$true)]
        [ValidateSet('Success', 'Error', 'Warning', 'Info', 'Debug', 'Banner')]
        [string]$Type
    )

    $color = switch ($Type) {
        'Success' { 'Green' }
        'Error'   { 'Red' }
        'Warning' { 'Yellow' }
        'Info'    { 'Cyan' }
        'Debug'   { 'DarkCyan' }
        'Banner'  { 'Magenta' }
    }

    $prefix = switch ($Type) {
        'Success' { '[✓] ' }
        'Error'   { '[✗] ' }
        'Warning' { '[⚠] ' }
        'Info'    { '[ℹ] ' }
        'Debug'   { '[→] ' }
        'Banner'  { '' }
    }

    Write-Host "$prefix$Message" -ForegroundColor $color
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput -Message $Message -Type 'Success'
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-ColorOutput -Message "ERRORE: $Message" -Type 'Error'
}

function Write-WarningMsg {
    param([string]$Message)
    Write-ColorOutput -Message "AVVISO: $Message" -Type 'Warning'
}

function Write-InfoMsg {
    param([string]$Message)
    Write-ColorOutput -Message $Message -Type 'Info'
}

function Write-DebugMsg {
    param([string]$Message)
    if ($VerboseOutput) {
        Write-ColorOutput -Message "DEBUG: $Message" -Type 'Debug'
    }
}

################################################################################
# Funzioni di logging
################################################################################

function Write-Log {
    param([string]$Message)

    if ($LogFile) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "[$timestamp] $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    }
}

################################################################################
# Funzioni principali
################################################################################

function Show-Banner {
    Write-ColorOutput -Message "╔════════════════════════════════════════════════════════════╗" -Type 'Banner'
    Write-ColorOutput -Message "║          Extract P7M - Estrattore File Firmati            ║" -Type 'Banner'
    Write-ColorOutput -Message "║                    Versione $VERSION (Windows)              ║" -Type 'Banner'
    Write-ColorOutput -Message "╚════════════════════════════════════════════════════════════╝" -Type 'Banner'
    Write-Host ""
}

function Show-Help {
    $helpText = @"

Uso: .\extract-p7m.ps1 [OPZIONI] <input>

Estrae il contenuto originale da file firmati digitalmente in formato .p7m

ARGOMENTI:
    <input>                 File .p7m o directory da processare

OPZIONI:
    -Help, -h              Mostra questo messaggio di aiuto
    -VerboseOutput, -v     Output verboso con informazioni dettagliate
    -Version, -V           Mostra la versione dello script
    -Recursive, -r         Elabora ricorsivamente tutte le directory
    -OutputDir, -o DIR     Directory di output (default: stessa del file di input)
    -Force, -f             Sovrascrive i file esistenti senza chiedere
    -DryRun, -n            Simula l'operazione senza estrarre i file
    -VerifySignature, -s   Verifica la firma digitale
    -ShowCertInfo, -c      Mostra informazioni sul certificato
    -LogFile, -l FILE      Salva il log in un file
    -NoTimestamps          Non preserva i timestamp originali dei file

ESEMPI:
    # Estrae un singolo file
    .\extract-p7m.ps1 documento.pdf.p7m

    # Estrae tutti i file .p7m in una directory ricorsivamente
    .\extract-p7m.ps1 -Recursive C:\Documenti

    # Estrae con verifica della firma e mostra info certificato
    .\extract-p7m.ps1 -VerifySignature -ShowCertInfo documento.pdf.p7m

    # Estrae in una directory specifica con output verboso
    .\extract-p7m.ps1 -VerboseOutput -OutputDir C:\Temp\Output documento.pdf.p7m

    # Dry-run per vedere cosa verrebbe fatto
    .\extract-p7m.ps1 -DryRun -Recursive C:\Documenti

REQUISITI:
    - OpenSSL (deve essere installato e disponibile nel PATH)
      Download: https://slproweb.com/products/Win32OpenSSL.html

CODICI DI USCITA:
    0 - Successo
    1 - Errore generico
    2 - Dipendenze mancanti
    3 - File di input non valido
    4 - Errore durante l'estrazione

"@
    Write-Host $helpText
}

function Test-Dependencies {
    Write-DebugMsg "Controllo dipendenze..."

    $openssl = Get-Command openssl -ErrorAction SilentlyContinue

    if (-not $openssl) {
        Write-ErrorMsg "OpenSSL non trovato!"
        Write-InfoMsg "Scarica e installa OpenSSL da: https://slproweb.com/products/Win32OpenSSL.html"
        Write-InfoMsg "Assicurati di aggiungerlo al PATH di sistema"
        Write-Log "ERRORE: OpenSSL non trovato"
        exit 2
    }

    Write-DebugMsg "OpenSSL trovato: $($openssl.Source)"
    Write-Log "Dipendenze verificate con successo"
}

function Test-ValidP7M {
    param([string]$FilePath)

    # Controlla estensione
    if (-not $FilePath.EndsWith('.p7m', [StringComparison]::OrdinalIgnoreCase)) {
        Write-DebugMsg "$FilePath non ha estensione .p7m"
        return $false
    }

    # Controlla se è leggibile
    if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
        Write-DebugMsg "$FilePath non è un file valido"
        return $false
    }

    # Verifica che sia un file PKCS#7 valido
    $derTest = & openssl pkcs7 -in $FilePath -inform DER -print_certs -noout 2>$null
    $pemTest = & openssl pkcs7 -in $FilePath -inform PEM -print_certs -noout 2>$null

    if ($LASTEXITCODE -ne 0 -and $pemTest -and $LASTEXITCODE -ne 0) {
        Write-DebugMsg "$FilePath non è un file PKCS#7 valido"
        return $false
    }

    return $true
}

function Get-P7MFormat {
    param([string]$FilePath)

    $null = & openssl pkcs7 -in $FilePath -inform DER -print_certs -noout 2>$null
    if ($LASTEXITCODE -eq 0) {
        return "DER"
    }

    $null = & openssl pkcs7 -in $FilePath -inform PEM -print_certs -noout 2>$null
    if ($LASTEXITCODE -eq 0) {
        return "PEM"
    }

    return "UNKNOWN"
}

function Show-CertificateInfo {
    param(
        [string]$FilePath,
        [string]$Format
    )

    Write-InfoMsg "Informazioni certificato per: $(Split-Path -Leaf $FilePath)"
    Write-Host ""

    $certInfo = & openssl pkcs7 -in $FilePath -inform $Format -print_certs -text 2>$null | Select-String -Pattern "Certificate:" -Context 0,20

    if ($certInfo) {
        $certInfo | ForEach-Object { Write-Host $_.Line }
        Write-Host ""
    } else {
        Write-WarningMsg "Impossibile estrarre le informazioni del certificato"
    }
}

function Test-Signature {
    param(
        [string]$FilePath,
        [string]$Format,
        [string]$OutputFile
    )

    Write-DebugMsg "Verifica firma per: $FilePath"

    $null = & openssl smime -verify -in $FilePath -inform $Format -noverify -out $OutputFile 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Firma valida per: $(Split-Path -Leaf $FilePath)"
        Write-Log "Firma valida: $FilePath"
        return $true
    } else {
        Write-WarningMsg "Impossibile verificare la firma per: $(Split-Path -Leaf $FilePath)"
        Write-Log "Verifica firma fallita: $FilePath"
        return $false
    }
}

function Extract-P7M {
    param(
        [string]$InputFile,
        [string]$OutputFile
    )

    Write-DebugMsg "Estrazione da: $InputFile -> $OutputFile"

    # Determina il formato
    $format = Get-P7MFormat -FilePath $InputFile

    if ($format -eq "UNKNOWN") {
        Write-ErrorMsg "Formato non riconosciuto per: $(Split-Path -Leaf $InputFile)"
        Write-Log "ERRORE: Formato non riconosciuto: $InputFile"
        return $false
    }

    Write-DebugMsg "Formato rilevato: $format"

    # Mostra info certificato se richiesto
    if ($ShowCertInfo) {
        Show-CertificateInfo -FilePath $InputFile -Format $format
    }

    # Verifica firma se richiesto
    if ($VerifySignature) {
        $null = Test-Signature -FilePath $InputFile -Format $format -OutputFile $OutputFile
    }

    # Estrae il contenuto
    $null = & openssl smime -verify -in $InputFile -inform $format -noverify -out $OutputFile 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Estratto: $(Split-Path -Leaf $OutputFile)"
        Write-Log "Successo: $InputFile -> $OutputFile"

        # Preserva i timestamp se richiesto
        if (-not $NoTimestamps) {
            $sourceFile = Get-Item $InputFile
            $destFile = Get-Item $OutputFile
            $destFile.CreationTime = $sourceFile.CreationTime
            $destFile.LastWriteTime = $sourceFile.LastWriteTime
            $destFile.LastAccessTime = $sourceFile.LastAccessTime
            Write-DebugMsg "Timestamp preservati"
        }

        return $true
    } else {
        Write-ErrorMsg "Estrazione fallita per: $(Split-Path -Leaf $InputFile)"
        Write-Log "ERRORE: Estrazione fallita: $InputFile"
        return $false
    }
}

function Process-File {
    param([string]$FilePath)

    $script:TotalFiles++

    Write-InfoMsg "Elaborazione: $(Split-Path -Leaf $FilePath)"

    # Valida il file
    if (-not (Test-ValidP7M -FilePath $FilePath)) {
        Write-WarningMsg "File non valido o non .p7m: $(Split-Path -Leaf $FilePath)"
        Write-Log "AVVISO: File non valido: $FilePath"
        $script:SkippedFiles++
        return
    }

    # Determina il file di output
    $outputFile = if ($OutputDir) {
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
        Join-Path $OutputDir $fileName
    } else {
        $FilePath -replace '\.p7m$', ''
    }

    # Controlla se il file di output esiste già
    if ((Test-Path $outputFile) -and -not $Force) {
        Write-WarningMsg "Il file esiste già: $(Split-Path -Leaf $outputFile)"
        $response = Read-Host "Sovrascrivere? (s/N)"
        if ($response -notmatch '^[SsYy]$') {
            Write-InfoMsg "Saltato: $(Split-Path -Leaf $FilePath)"
            $script:SkippedFiles++
            return
        }
    }

    # Dry-run
    if ($DryRun) {
        Write-InfoMsg "[DRY-RUN] Verrebbe estratto: $FilePath -> $outputFile"
        Write-Log "DRY-RUN: $FilePath -> $outputFile"
        $script:SuccessfulExtractions++
        return
    }

    # Estrae il file
    if (Extract-P7M -InputFile $FilePath -OutputFile $outputFile) {
        $script:SuccessfulExtractions++

        # Mostra dimensioni file
        if ($VerboseOutput) {
            $inputSize = (Get-Item $FilePath).Length
            $outputSize = (Get-Item $outputFile).Length
            Write-DebugMsg "Dimensione input: $([math]::Round($inputSize/1KB, 2)) KB, output: $([math]::Round($outputSize/1KB, 2)) KB"
        }
    } else {
        $script:FailedExtractions++
    }
}

function Process-Directory {
    param([string]$DirPath)

    Write-InfoMsg "Scansione directory: $DirPath"
    Write-Log "Scansione directory: $DirPath"

    $searchOption = if ($Recursive) {
        [System.IO.SearchOption]::AllDirectories
    } else {
        [System.IO.SearchOption]::TopDirectoryOnly
    }

    $files = Get-ChildItem -Path $DirPath -Filter "*.p7m" -File -Recurse:$Recursive | Sort-Object FullName

    if ($files.Count -eq 0) {
        Write-WarningMsg "Nessun file .p7m trovato in: $DirPath"
        Write-Log "AVVISO: Nessun file trovato in: $DirPath"
        return
    }

    Write-InfoMsg "Trovati $($files.Count) file .p7m"
    Write-Host ""

    foreach ($file in $files) {
        Process-File -FilePath $file.FullName
        Write-Host ""
    }
}

function Show-Statistics {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor White
    Write-Host "STATISTICHE" -ForegroundColor White
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor White
    Write-InfoMsg "File totali processati: $script:TotalFiles"
    Write-Success "Estrazioni riuscite: $script:SuccessfulExtractions"
    if ($script:FailedExtractions -gt 0) {
        Write-ErrorMsg "Estrazioni fallite: $script:FailedExtractions"
    }
    if ($script:SkippedFiles -gt 0) {
        Write-WarningMsg "File saltati: $script:SkippedFiles"
    }
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor White
}

################################################################################
# Main
################################################################################

# Mostra versione
if ($Version) {
    Write-Host "extract-p7m versione $VERSION (Windows PowerShell)"
    exit 0
}

# Mostra help
if ($Help -or -not $InputPath) {
    Show-Banner
    Show-Help
    exit 0
}

# Banner
Show-Banner

# Controlla dipendenze
Test-Dependencies

# Crea directory di output se specificata
if ($OutputDir) {
    if (-not (Test-Path $OutputDir)) {
        New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
        Write-Success "Directory di output creata: $OutputDir"
    }
}

# Inizializza log file
if ($LogFile) {
    "" | Out-File -FilePath $LogFile -Encoding UTF8
    Write-Log "=== Inizio elaborazione ==="
    Write-Log "Input: $InputPath"
    Write-DebugMsg "Log salvato in: $LogFile"
}

# Elabora input
Write-Host ""
if (Test-Path -Path $InputPath -PathType Leaf) {
    Process-File -FilePath $InputPath
} elseif (Test-Path -Path $InputPath -PathType Container) {
    Process-Directory -DirPath $InputPath
} else {
    Write-ErrorMsg "Input non valido: $InputPath"
    Write-Log "ERRORE: Input non valido: $InputPath"
    exit 3
}

# Mostra statistiche
Show-Statistics

# Log statistiche
if ($LogFile) {
    Write-Log "=== Statistiche ==="
    Write-Log "Totali: $script:TotalFiles, Successi: $script:SuccessfulExtractions, Falliti: $script:FailedExtractions, Saltati: $script:SkippedFiles"
    Write-Log "=== Fine elaborazione ==="
}

# Determina codice di uscita
if ($script:FailedExtractions -gt 0) {
    exit 4
} else {
    exit 0
}
