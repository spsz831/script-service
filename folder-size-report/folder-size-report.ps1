param(
    [string]$Path = '.',
    [int]$Top = 20
)

$ErrorActionPreference = 'Stop'
$resolvedPath = (Resolve-Path -LiteralPath $Path).Path

function Get-DirectorySize {
    param([string]$DirectoryPath)

    $sum = (Get-ChildItem -LiteralPath $DirectoryPath -Recurse -File -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum
    if (-not $sum) { $sum = 0 }
    return [int64]$sum
}

$directories = Get-ChildItem -LiteralPath $resolvedPath -Directory -ErrorAction Stop
$report = foreach ($directory in $directories) {
    $sizeBytes = Get-DirectorySize -DirectoryPath $directory.FullName
    [pscustomobject]@{
        Name      = $directory.Name
        FullName  = $directory.FullName
        SizeMB    = [math]::Round($sizeBytes / 1MB, 2)
        SizeBytes = $sizeBytes
    }
}

$report |
    Sort-Object SizeBytes -Descending |
    Select-Object -First $Top Name, SizeMB, FullName |
    Format-Table -AutoSize
