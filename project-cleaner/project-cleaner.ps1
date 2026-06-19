[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$Path = '.',
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'
$resolvedPath = (Resolve-Path -LiteralPath $Path).Path

$targetNames = @(
    '.cache',
    'dist',
    'build',
    'coverage',
    '__pycache__',
    '.pytest_cache',
    '.mypy_cache',
    '.ruff_cache',
    '.next',
    '.nuxt',
    '.turbo',
    '.parcel-cache'
)

$targets = Get-ChildItem -LiteralPath $resolvedPath -Directory -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $targetNames -contains $_.Name -or $_.FullName -like '*node_modules\.cache' }

if (-not $targets) {
    Write-Host 'No common cache directories were found.'
    exit 0
}

$report = foreach ($target in $targets) {
    $sizeBytes = (Get-ChildItem -LiteralPath $target.FullName -Recurse -Force -File -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum
    if (-not $sizeBytes) { $sizeBytes = 0 }
    [pscustomobject]@{
        Name      = $target.Name
        FullName  = $target.FullName
        SizeMB    = [math]::Round($sizeBytes / 1MB, 2)
        SizeBytes = [int64]$sizeBytes
    }
}

$report | Sort-Object SizeBytes -Descending | Format-Table Name, SizeMB, FullName -AutoSize

if ($Clean) {
    foreach ($item in $report) {
        if ($PSCmdlet.ShouldProcess($item.FullName, 'Remove project cache directory')) {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed: $($item.FullName)"
        }
    }
}
