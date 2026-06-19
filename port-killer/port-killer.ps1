[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [int]$Port,

    [switch]$Kill
)

$ErrorActionPreference = 'Stop'

if ($Port -lt 1 -or $Port -gt 65535) {
    throw "Invalid port: $Port"
}

$connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if (-not $connections) {
    Write-Host "No TCP process is listening on port $Port."
    exit 0
}

$processIds = $connections | Select-Object -ExpandProperty OwningProcess -Unique
$processes = foreach ($processId in $processIds) {
    Get-Process -Id $processId -ErrorAction SilentlyContinue
}

$processes | Select-Object Id, ProcessName, Path | Format-Table -AutoSize

if ($Kill) {
    foreach ($process in $processes) {
        if ($PSCmdlet.ShouldProcess("PID $($process.Id) ($($process.ProcessName))", "Stop process")) {
            Stop-Process -Id $process.Id -Force
            Write-Host "Stopped PID $($process.Id) ($($process.ProcessName))."
        }
    }
}
