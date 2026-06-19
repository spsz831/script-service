[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [ValidateSet('png', 'jpg', 'webp')]
    [string]$OutputFormat,

    [string]$OutputDirectory,

    [string]$Filter = '*.*',

    [int]$MaxWidth,

    [int]$MaxHeight,

    [int]$Quality = 92,

    [string]$MagickPath
)

$ErrorActionPreference = 'Stop'

function Resolve-MagickPath {
    param([string]$PreferredPath)

    if ($PreferredPath) {
        if (Test-Path -LiteralPath $PreferredPath) {
            return (Resolve-Path -LiteralPath $PreferredPath).Path
        }
        throw "The specified ImageMagick path does not exist: $PreferredPath"
    }

    $command = Get-Command magick.exe, magick -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) {
        return $command.Source
    }

    $candidates = @(
        'C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe',
        'C:\Program Files\ImageMagick-7.1.1-Q16\magick.exe',
        'C:\Program Files\ImageMagick-7.0.11-Q16-HDRI\magick.exe',
        'C:\Program Files\ImageMagick-7.0.11-Q16\magick.exe'
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    throw 'ImageMagick was not found. Install ImageMagick or use -MagickPath.'
}

function Get-ResizeArgument {
    param(
        [int]$Width,
        [int]$Height
    )

    if ($Width -gt 0 -and $Height -gt 0) {
        return "$Width" + 'x' + "$Height>"
    }
    if ($Width -gt 0) {
        return "$Width" + 'x>'
    }
    if ($Height -gt 0) {
        return 'x' + "$Height>"
    }
    return $null
}

$resolvedInputPath = (Resolve-Path -LiteralPath $InputPath).Path
if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $resolvedInputPath ($OutputFormat + '-output')
}
if (-not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
}

$magick = Resolve-MagickPath -PreferredPath $MagickPath
$resizeArg = Get-ResizeArgument -Width $MaxWidth -Height $MaxHeight

$supportedInputExtensions = @('.png', '.jpg', '.jpeg', '.webp')
$files = Get-ChildItem -LiteralPath $resolvedInputPath -File -Filter $Filter -ErrorAction Stop |
    Where-Object { $supportedInputExtensions -contains $_.Extension.ToLowerInvariant() }

if (-not $files) {
    Write-Host 'No supported image files were found.'
    exit 0
}

foreach ($file in $files) {
    $outputFile = Join-Path $OutputDirectory ([System.IO.Path]::GetFileNameWithoutExtension($file.Name) + '.' + $OutputFormat)
    $arguments = @($file.FullName)
    if ($resizeArg) {
        $arguments += @('-resize', $resizeArg)
    }
    $arguments += @('-quality', $Quality, $outputFile)

    if ($PSCmdlet.ShouldProcess($file.FullName, "Convert to $outputFile")) {
        & $magick @arguments
        Write-Host "$($file.Name) -> $outputFile"
    }
}
