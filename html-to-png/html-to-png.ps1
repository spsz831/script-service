param(
    [Parameter(Mandatory = $true)]
    [string]$InputHtml,

    [string]$OutputImage,

    [int]$Width = 1440,

    [int]$Height = 12000,

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

if (-not $OutputImage) {
    $directory = Split-Path -Path $resolvedInput -Parent
    $name = [System.IO.Path]::GetFileNameWithoutExtension($resolvedInput)
    $OutputImage = Join-Path $directory ($name + '-fullpage.png')
}

$browser = Resolve-BrowserPath -PreferredPath $BrowserPath
$inputUri = Convert-PathToFileUri -Path $resolvedInput

$outputDirectory = Split-Path -Path $OutputImage -Parent
if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

& $browser `
    --headless `
    --disable-gpu `
    --hide-scrollbars `
    --window-size="$Width,$Height" `
    --screenshot="$OutputImage" `
    $inputUri

$created = $false
for ($i = 0; $i -lt 20; $i++) {
    if (Test-Path -LiteralPath $OutputImage) {
        $created = $true
        break
    }
    Start-Sleep -Milliseconds 250
}

if (-not $created) {
    throw "Screenshot failed. Output file was not created: $OutputImage"
}

Write-Host "Screenshot saved: $OutputImage"
Write-Host "Browser: $browser"
Write-Host "Size: ${Width}x${Height}"
