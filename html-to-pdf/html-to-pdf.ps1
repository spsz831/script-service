param(
    [Parameter(Mandatory = $true)]
    [string]$InputHtml,

    [string]$OutputPdf,

    [string]$BrowserPath
)

$ErrorActionPreference = 'Stop'

function Resolve-BrowserPath {
    param([string]$PreferredPath)

    if ($PreferredPath) {
        if (Test-Path -LiteralPath $PreferredPath) {
            return (Resolve-Path -LiteralPath $PreferredPath).Path
        }
        throw "The specified browser path does not exist: $PreferredPath"
    }

    $candidates = @(
        'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
        'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
        'C:\Program Files\Google\Chrome\Application\chrome.exe'
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    throw 'No supported browser was found. Install Edge or Chrome, or use -BrowserPath.'
}

function Convert-PathToFileUri {
    param([string]$Path)

    $resolved = (Resolve-Path -LiteralPath $Path).Path
    return ([System.Uri]$resolved).AbsoluteUri
}

$resolvedInput = (Resolve-Path -LiteralPath $InputHtml).Path
if ([System.IO.Path]::GetExtension($resolvedInput).ToLowerInvariant() -notin @('.html', '.htm')) {
    throw "Input file is not .html/.htm: $resolvedInput"
}

if (-not $OutputPdf) {
    $directory = Split-Path -Path $resolvedInput -Parent
    $name = [System.IO.Path]::GetFileNameWithoutExtension($resolvedInput)
    $OutputPdf = Join-Path $directory ($name + '.pdf')
}

$outputDirectory = Split-Path -Path $OutputPdf -Parent
if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

$browser = Resolve-BrowserPath -PreferredPath $BrowserPath
$inputUri = Convert-PathToFileUri -Path $resolvedInput
$tempPdf = Join-Path $env:TEMP ('html-to-pdf-' + [guid]::NewGuid().ToString() + '.pdf')

& $browser `
    --headless `
    --disable-gpu `
    --print-to-pdf="$tempPdf" `
    $inputUri

$created = $false
for ($i = 0; $i -lt 20; $i++) {
    if (Test-Path -LiteralPath $tempPdf) {
        $created = $true
        break
    }
    Start-Sleep -Milliseconds 250
}

if (-not $created) {
    throw "PDF export failed. Temporary output file was not created: $tempPdf"
}

Move-Item -LiteralPath $tempPdf -Destination $OutputPdf -Force

Write-Host "PDF saved: $OutputPdf"
Write-Host "Browser: $browser"
