[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$IncludeWindowsTemp
)

$ErrorActionPreference = 'Stop'

$targets = @($env:TEMP)
if ($IncludeWindowsTemp) {
    $targets += 'C:\Windows\Temp'
}

foreach ($target in $targets | Select-Object -Unique) {
    if (-not (Test-Path -LiteralPath $target)) {
        Write-Host "Skip missing path: $target"
        continue
    }

    Write-Host "Cleaning: $target"
    Get-ChildItem -LiteralPath $target -Force -ErrorAction SilentlyContinue |
        ForEach-Object {
            try {
                if ($PSCmdlet.ShouldProcess($_.FullName, 'Remove temp item')) {
                    Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop
                }
            }
            catch {
                Write-Host "Skip locked item: $($_.FullName)"
            }
        }
}

Write-Host 'Temp cleanup finished.'
