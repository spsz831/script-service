[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [int]$Port,

    [switch]$Kill,

    [switch]$IncludeZombie
)

$ErrorActionPreference = 'Stop'

if ($Port -lt 1 -or $Port -gt 65535) {
    throw "Invalid port: $Port"
}

function Get-ProcessRecommendation {
    param(
        [string]$ProcessName,
        [string]$Path
    )

    if (-not $ProcessName) {
        return ''
    }

    switch -Regex ($ProcessName.ToLowerInvariant()) {
        '^(node|bun|python|python3|deno)$' { return 'Likely a dev server/runtime. Confirm before killing.' }
        '^(code|cursor|windsurf)$' { return 'Likely an editor-side helper process. Killing it may disrupt tooling.' }
        '^(ollama)$' { return 'Local model service. Killing it may interrupt local AI workloads.' }
        '^(chrome|msedge)$' { return 'Browser process. Killing it may close tabs or devtools sessions.' }
        '^(system|svchost|lsass|services|wininit|spoolsv)$' { return 'System process. Do not kill unless you are certain.' }
    }

    if ($Path -and $Path -match '\\AppData\\Local\\Programs\\Microsoft VS Code\\') {
        return 'Likely VS Code related. Confirm before killing.'
    }

    return ''
}

function Get-LivePortEntries {
    param([int]$TargetPort)

    $entries = @()
    $previousWhatIf = $WhatIfPreference
    $WhatIfPreference = $false
    try {
        $connections = Get-NetTCPConnection -LocalPort $TargetPort -ErrorAction SilentlyContinue
        if (-not $connections) {
            return @()
        }

        $processIds = @($connections | Select-Object -ExpandProperty OwningProcess -Unique)
        foreach ($processId in $processIds) {
            if ($processId -le 0) {
                continue
            }

            $proc = Get-Process -Id $processId -ErrorAction SilentlyContinue
            if (-not $proc) {
                continue
            }

            $pathValue = ''
            try {
                $pathValue = $proc.Path
            } catch {
                $pathValue = ''
            }

            $entries += [PSCustomObject]@{
                Port           = $TargetPort
                State          = 'LIVE'
                Id             = $proc.Id
                ProcessName    = $proc.ProcessName
                Path           = $pathValue
                Recommendation = Get-ProcessRecommendation -ProcessName $proc.ProcessName -Path $pathValue
            }
        }
    }
    finally {
        $WhatIfPreference = $previousWhatIf
    }

    return @($entries | Sort-Object Id -Unique)
}

function Get-ZombiePortEntries {
    param([int]$TargetPort)

    $entries = @()
    $previousWhatIf = $WhatIfPreference
    $WhatIfPreference = $false
    try {
        $netstatLines = netstat -ano 2>$null | Select-String "^\s*TCP\s+\S+:$TargetPort\s+\S+\s+LISTENING\s+(\d+)"
        foreach ($line in $netstatLines) {
            $match = [regex]::Match($line.ToString(), 'LISTENING\s+(\d+)')
            if (-not $match.Success) {
                continue
            }

            $ownerPid = [int]$match.Groups[1].Value
            if ($ownerPid -eq 4) {
                continue
            }

            $liveProc = Get-Process -Id $ownerPid -ErrorAction SilentlyContinue
            if ($liveProc) {
                continue
            }

            $entries += [PSCustomObject]@{
                Port           = $TargetPort
                State          = 'ZOMBIE'
                Id             = $ownerPid
                ProcessName    = ''
                Path           = ''
                Recommendation = 'Kernel-held socket. Restart Windows or use a different port.'
            }
        }
    }
    finally {
        $WhatIfPreference = $previousWhatIf
    }

    return @($entries | Sort-Object Id -Unique)
}

$liveEntries = @(Get-LivePortEntries -TargetPort $Port)
$zombieEntries = @()
if ($IncludeZombie) {
    $zombieEntries = @(Get-ZombiePortEntries -TargetPort $Port)
}

if ($liveEntries.Count -eq 0 -and $zombieEntries.Count -eq 0) {
    Write-Host "No TCP process is listening on port $Port."
    exit 0
}

if ($liveEntries.Count -gt 0) {
    Write-Host ""
    Write-Host "Live listeners on port ${Port}:" -ForegroundColor Cyan
    $liveEntries |
        Select-Object Port, State, Id, ProcessName, Path, Recommendation |
        Format-Table -AutoSize
}

if ($zombieEntries.Count -gt 0) {
    Write-Host ""
    Write-Host "ZOMBIE sockets detected on port ${Port}:" -ForegroundColor Yellow
    $zombieEntries |
        Select-Object Port, State, Id, Recommendation |
        Format-Table -AutoSize
    Write-Host "These cannot be freed with Stop-Process. Restart Windows or use another port." -ForegroundColor DarkYellow
}

if ($Kill) {
    if ($liveEntries.Count -eq 0) {
        Write-Host ""
        Write-Host "No live process can be stopped for port $Port." -ForegroundColor Yellow
    }

    foreach ($entry in $liveEntries) {
        $targetLabel = "PID $($entry.Id) ($($entry.ProcessName)) on port $Port"
        if ($PSCmdlet.ShouldProcess($targetLabel, 'Stop process')) {
            Stop-Process -Id $entry.Id -Force
            Write-Host "Stopped PID $($entry.Id) ($($entry.ProcessName))."
        }
    }

    if ($zombieEntries.Count -gt 0) {
        Write-Host "ZOMBIE socket entries were not touched." -ForegroundColor DarkYellow
    }
}
