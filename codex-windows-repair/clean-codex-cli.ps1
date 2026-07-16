[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [switch]$Verify,
    [switch]$AutoFix,
    [switch]$LaunchReinstall,
    [switch]$Reinstall,
    [switch]$SkipCacheClean,
    [switch]$SkipProcessStop,
    [int]$LogKeep = 10
)

$ErrorActionPreference = 'Stop'

$PackageName = '@openai/codex'
$CommandName = 'codex'
$ProcessName = 'codex'
$TempPattern = '.codex*'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $ScriptDir 'logs'
$VersionFile = Join-Path $ScriptDir 'VERSION'
$ScriptVersion = if (Test-Path -LiteralPath $VersionFile) {
    (Get-Content -Raw -LiteralPath $VersionFile).Trim()
} else {
    '0.0.0'
}
$RunTimestamp = Get-Date
$SummaryFile = Join-Path $LogDir ('summary_' + $RunTimestamp.ToString('yyyy-MM-dd_HHmmss_fff') + '.json')
$SnapshotFile = Join-Path $LogDir ('snapshot_' + $RunTimestamp.ToString('yyyy-MM-dd_HHmmss_fff') + '.json')
$summaryState = [ordered]@{
    scriptVersion         = $ScriptVersion
    timestamp             = $RunTimestamp.ToString('o')
    mode                  = 'cleanup'
    result                = 'unknown'
    statusCode            = ''
    statusMessage         = ''
    recommendedAction     = ''
    recommendedMessage    = ''
    executedAction        = ''
    codexCommandPath      = ''
    npmCommandPath        = ''
    npmGlobalRoot         = ''
    npmGlobalBin          = ''
    packageDirectory      = ''
    hasOptionalDependency = $false
    shimResidueCount      = 0
    networkStatus         = ''
    registry              = ''
    httpProxy             = ''
    httpsProxy            = ''
    latestRegistryVersion = ''
    localVersion          = ''
    versionStatus         = ''
    logFile               = ''
    snapshotFile          = ''
}

New-Item -ItemType Directory -Force -Path $LogDir -WhatIf:$false | Out-Null
$LogFile = Join-Path $LogDir ('cleanup_' + (Get-Date -Format 'yyyy-MM-dd_HHmmss_fff') + '.log')
$summaryState.logFile = $LogFile
$summaryState.snapshotFile = $SnapshotFile

function Write-Log {
    param(
        [string]$Message,
        [switch]$NoConsole
    )

    Add-Content -LiteralPath $LogFile -Value $Message -WhatIf:$false
    if (-not $NoConsole) {
        $Message | Out-Host
    }
}

function Trim-Logs {
    param([int]$Keep)

    Get-ChildItem -LiteralPath $LogDir -Filter 'cleanup_*.log' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip $Keep |
        Remove-Item -Force -ErrorAction SilentlyContinue -WhatIf:$false
    Get-ChildItem -LiteralPath $LogDir -Filter 'summary_*.json' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip $Keep |
        Remove-Item -Force -ErrorAction SilentlyContinue -WhatIf:$false
    Get-ChildItem -LiteralPath $LogDir -Filter 'snapshot_*.json' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip $Keep |
        Remove-Item -Force -ErrorAction SilentlyContinue -WhatIf:$false
}

function Write-Summary {
    param([hashtable]$State)

    ($State | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath $SummaryFile -Encoding UTF8 -WhatIf:$false
}

function Get-PowerShellExecutable {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($pwsh) {
        return $pwsh.Source
    }

    $powershell = Get-Command powershell -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($powershell) {
        return $powershell.Source
    }

    throw '未找到 pwsh 或 powershell。'
}

function Launch-ReinstallWindow {
    param([string]$ScriptPath)

    $shellPath = Get-PowerShellExecutable
    $launchArgs = @(
        '-NoExit',
        '-ExecutionPolicy', 'Bypass',
        '-File', $ScriptPath,
        '-Reinstall'
    )

    Write-Log ('[launch] 新窗口命令: ' + (Join-CommandLine -Executable $shellPath -Arguments $launchArgs))

    if ($WhatIfPreference) {
        Write-Log '[whatif] 已跳过启动新的 PowerShell 窗口。'
        return
    }

    Start-Process -FilePath $shellPath -ArgumentList $launchArgs
}

function Write-Snapshot {
    param(
        [string]$NpmCommandPath,
        [string]$NpmGlobalBin,
        [string]$NpmGlobalRoot,
        [string]$TargetCommandPath
    )

    $snapshot = [ordered]@{
        timestamp        = (Get-Date).ToString('o')
        codexVersion     = ''
        codexCommandPath = $TargetCommandPath
        whereCodex       = @()
        npmList          = @()
        shimEntries      = @()
        orphanEntries    = @()
    }

    if ($TargetCommandPath) {
        try {
            $versionOutput = & $TargetCommandPath --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                $lastVersionLine = $versionOutput | Select-Object -Last 1
                if ($null -ne $lastVersionLine) {
                    $snapshot.codexVersion = $lastVersionLine.ToString().Trim()
                }
            } else {
                $snapshot.codexVersion = '<failed>'
            }
        }
        catch {
            $snapshot.codexVersion = '<failed>'
        }
    }

    $snapshot.whereCodex = @(where.exe codex 2>$null)
    $snapshot.npmList = @(& $NpmCommandPath list -g @openai/codex --depth=0 2>&1)

    if ($NpmGlobalBin -and (Test-Path -LiteralPath $NpmGlobalBin)) {
        $snapshot.shimEntries = @(Get-ChildItem -LiteralPath $NpmGlobalBin -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like 'codex*' -or $_.Name -like '.codex*' } |
            ForEach-Object {
                [ordered]@{
                    name = $_.Name
                    fullName = $_.FullName
                    lastWriteTime = $_.LastWriteTime.ToString('o')
                }
            })
    }

    if ($NpmGlobalRoot) {
        $snapshot.orphanEntries = @(Get-CodexNpmOrphanResidueEntries -NpmGlobalRoot $NpmGlobalRoot |
            ForEach-Object {
                [ordered]@{
                    name = $_.Name
                    fullName = $_.FullName
                    lastWriteTime = $_.LastWriteTime.ToString('o')
                }
            })
    }

    ($snapshot | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath $SnapshotFile -Encoding UTF8 -WhatIf:$false
}

function Resolve-CommandPath {
    param([string[]]$Candidates)

    foreach ($candidate in $Candidates) {
        $command = Get-Command $candidate -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) {
            return $command.Source
        }
    }

    return $null
}

function Join-CommandLine {
    param(
        [string]$Executable,
        [string[]]$Arguments
    )

    $renderedArgs = foreach ($arg in $Arguments) {
        if ($arg -match '\s') {
            '"' + $arg.Replace('"', '\"') + '"'
        } else {
            $arg
        }
    }

    (@($Executable) + @($renderedArgs)) -join ' '
}

function Invoke-NativeCommand {
    param(
        [string]$Label,
        [string]$Executable,
        [string[]]$Arguments,
        [switch]$Quiet
    )

    Write-Log $Label

    if ($WhatIfPreference) {
        Write-Log ('[whatif] 已跳过命令: ' + (Join-CommandLine -Executable $Executable -Arguments $Arguments))
        return [pscustomobject]@{
            ExitCode = 0
            StdOut   = @()
            StdErr   = @()
        }
    }

    $stdoutFile = Join-Path $LogDir ('stdout_' + [guid]::NewGuid().ToString() + '.log')
    $stderrFile = Join-Path $LogDir ('stderr_' + [guid]::NewGuid().ToString() + '.log')

    try {
        $process = Start-Process -FilePath $Executable -ArgumentList $Arguments -Wait -PassThru -NoNewWindow -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
        $stdout = if (Test-Path -LiteralPath $stdoutFile) { @(Get-Content -LiteralPath $stdoutFile -ErrorAction SilentlyContinue) } else { @() }
        $stderr = if (Test-Path -LiteralPath $stderrFile) { @(Get-Content -LiteralPath $stderrFile -ErrorAction SilentlyContinue) } else { @() }

        foreach ($line in $stdout) {
            Write-Log $line -NoConsole
        }
        foreach ($line in $stderr) {
            Write-Log $line -NoConsole
        }

        if (-not $Quiet) {
            foreach ($line in $stdout) {
                Write-Log $line
            }
            foreach ($line in $stderr) {
                Write-Log $line
            }
        }

        if ($process.ExitCode -ne 0) {
            throw ('命令执行失败，退出码 ' + $process.ExitCode + ': ' + (Join-CommandLine -Executable $Executable -Arguments $Arguments))
        }

        [pscustomobject]@{
            ExitCode = $process.ExitCode
            StdOut   = $stdout
            StdErr   = $stderr
        }
    }
    finally {
        Remove-Item -LiteralPath $stdoutFile, $stderrFile -Force -ErrorAction SilentlyContinue -WhatIf:$false
    }
}

function Get-NpmGlobalRoot {
    param([string]$NpmCommandPath)

    $output = & $NpmCommandPath root -g 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw '无法解析 npm 全局根目录。'
    }

    $globalRoot = ($output | Select-Object -Last 1).ToString().Trim()
    if (-not $globalRoot) {
        throw 'npm root -g 返回了空路径。'
    }

    $globalRoot
}

function Test-PathWithinRoot {
    param(
        [string]$RootPath,
        [string]$TargetPath
    )

    if (-not $RootPath -or -not $TargetPath) {
        return $false
    }

    $resolvedRoot = [System.IO.Path]::GetFullPath($RootPath)
    $resolvedTarget = [System.IO.Path]::GetFullPath($TargetPath)
    $resolvedTarget.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)
}

function Remove-Paths {
    param(
        [System.IO.FileSystemInfo[]]$Entries,
        [string]$RootPath,
        [string]$Label
    )

    if (-not $Entries -or $Entries.Count -eq 0) {
        Write-Log ('[info] 未发现需要清理的' + $Label + '。')
        return
    }

    Write-Log ('[info] 发现 ' + $Entries.Count + ' 个' + $Label + ':')
    foreach ($entry in $Entries) {
        Write-Log ('  - ' + $entry.FullName)
    }

    foreach ($entry in $Entries) {
        if (-not (Test-PathWithinRoot -RootPath $RootPath -TargetPath $entry.FullName)) {
            Write-Log ('[warn] 跳过超出安全范围的路径: ' + $entry.FullName)
            continue
        }

        if ($PSCmdlet.ShouldProcess($entry.FullName, '删除 Codex 残留文件')) {
            Remove-Item -LiteralPath $entry.FullName -Recurse -Force -ErrorAction SilentlyContinue
            if (Test-Path -LiteralPath $entry.FullName) {
                Write-Log ('[warn] 删除失败: ' + $entry.FullName)
            } else {
                Write-Log ('[info] 已删除: ' + $entry.FullName)
            }
        } else {
            Write-Log ('[whatif] 将删除: ' + $entry.FullName)
        }
    }
}

function Get-CodexUserTempDirectory {
    Join-Path (Join-Path $env:USERPROFILE '.codex') '.tmp'
}

function Test-CodexOptionalDependency {
    param([string]$PackageDirectory)

    if (-not $PackageDirectory) {
        return $false
    }

    $optionalDependencyPath = Join-Path (Join-Path (Join-Path $PackageDirectory 'node_modules') '@openai') 'codex-win32-x64'
    Test-Path -LiteralPath $optionalDependencyPath
}

function Clear-CodexUserTemp {
    $tempDir = Get-CodexUserTempDirectory
    $allowedNames = @('plugins', 'plugins.sha', 'plugins.sync.lock')

    Write-Log '[5/6] 清理 Codex 用户临时目录白名单项...'
    if (-not (Test-Path -LiteralPath $tempDir)) {
        Write-Log ('[info] 未发现 Codex 用户临时目录: ' + $tempDir)
        return
    }

    $entries = Get-ChildItem -LiteralPath $tempDir -Force -ErrorAction SilentlyContinue |
        Where-Object { $allowedNames -contains $_.Name }

    if (-not $entries) {
        Write-Log '[info] 未发现需要清理的 Codex 用户临时白名单项。'
        return
    }

    Remove-Paths -Entries $entries -RootPath $tempDir -Label 'Codex 用户临时白名单项'
}

function Get-CodexNpmOrphanResidueEntries {
    param([string]$NpmGlobalRoot)

    if (-not $NpmGlobalRoot) {
        return @()
    }

    $openAiRoot = Join-Path $NpmGlobalRoot '@openai'
    if (-not (Test-Path -LiteralPath $openAiRoot)) {
        return @()
    }

    @(Get-ChildItem -LiteralPath $openAiRoot -Force -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like '.codex*' })
}

function Clear-CodexNpmOrphanResidue {
    param([string]$NpmGlobalRoot)

    Write-Log '[4b/6] 清理 npm 全局目录下的 @openai\.codex* 旧残留...'

    if (-not $NpmGlobalRoot) {
        Write-Log '[info] 未提供 npm 全局目录，跳过 @openai\.codex* 旧残留清理。'
        return @()
    }

    $entries = Get-CodexNpmOrphanResidueEntries -NpmGlobalRoot $NpmGlobalRoot
    if (-not $entries -or $entries.Count -eq 0) {
        Write-Log '[info] 未发现需要清理的 @openai\.codex* 旧残留。'
        return @()
    }

    Remove-Paths -Entries $entries -RootPath (Join-Path $NpmGlobalRoot '@openai') -Label '@openai\.codex* 旧残留'
    return $entries
}

function Get-CodexHealthStatus {
    param(
        [string]$TargetCommandPath,
        [System.IO.FileSystemInfo[]]$ShimRemainders,
        [bool]$HasOptionalDependency
    )

    if (-not $TargetCommandPath) {
        return [pscustomobject]@{
            Code = 'shim-missing'
            Message = '未检测到可执行的 codex 命令，属于 shim 缺失或未建好。'
        }
    }

    if ($ShimRemainders -and $ShimRemainders.Count -gt 0) {
        return [pscustomobject]@{
            Code = 'shim-residue'
            Message = '检测到 .codex* 临时残留，属于升级中断后的 shim 异常。'
        }
    }

    if (-not $HasOptionalDependency) {
        return [pscustomobject]@{
            Code = 'win32-missing'
            Message = 'Codex 主包存在，但缺少 Windows 平台依赖 @openai/codex-win32-x64。'
        }
    }

    return [pscustomobject]@{
        Code = 'healthy'
        Message = '未发现 shim 异常或 win32 子包缺失，当前属于健康状态。'
    }
}

function Get-HealthStatusLabel {
    param([string]$Code)

    switch ($Code) {
        'healthy' { return '健康' }
        'shim-missing' { return 'shim 缺失' }
        'shim-residue' { return 'shim 残留' }
        'win32-missing' { return 'win32 子包缺失' }
        default { return '未知状态' }
    }
}

function Get-RepairActionLabel {
    param([string]$Action)

    switch ($Action) {
        'none' { return '无需修复' }
        'reinstall-force' { return '强制重装' }
        'reinstall-normal' { return '普通重装' }
        'manual' { return '人工判断' }
        default { return '未知动作' }
    }
}

function Get-NetworkStatusLabel {
    param([string]$Code)

    switch ($Code) {
        'proxy-active' { return '代理可用' }
        'direct-ok' { return '直连可用' }
        'registry-unreachable' { return 'registry 不可达' }
        'registry-missing' { return 'registry 缺失' }
        default { return '未知网络状态' }
    }
}

function Get-VersionStatusLabel {
    param([string]$Code)

    switch ($Code) {
        'up-to-date' { return '已是最新' }
        'upgrade-available' { return '可升级' }
        'upgrade-available-with-issues' { return '可升级但有问题' }
        'local-unknown' { return '本地版本未知' }
        'latest-unknown' { return '最新版本未知' }
        default { return '未知版本状态' }
    }
}

function Get-PresenceLabel {
    param([bool]$Present)

    if ($Present) {
        return '已存在'
    }

    return '缺失'
}

function Get-RepairPlan {
    param(
        [pscustomobject]$HealthStatus,
        [bool]$HasOptionalDependency
    )

    switch ($HealthStatus.Code) {
        'healthy' {
            return [pscustomobject]@{
                Action = 'none'
                InstallArgs = @()
                Message = '当前状态健康，无需修复。'
            }
        }
        'shim-missing' {
            return [pscustomobject]@{
                Action = 'reinstall-force'
                InstallArgs = @('install', '-g', '@openai/codex@latest', '--force')
                Message = '缺少可执行 shim，建议强制重装以重建入口。'
            }
        }
        'shim-residue' {
            return [pscustomobject]@{
                Action = 'reinstall-force'
                InstallArgs = @('install', '-g', '@openai/codex@latest', '--force')
                Message = '检测到 shim 残留，建议清理后强制重装。'
            }
        }
        'win32-missing' {
            return [pscustomobject]@{
                Action = 'reinstall-normal'
                InstallArgs = @('install', '-g', '@openai/codex@latest')
                Message = '缺少 win32 平台依赖，建议普通重装补齐可选依赖。'
            }
        }
        default {
            return [pscustomobject]@{
                Action = 'manual'
                InstallArgs = @()
                Message = '未识别状态，建议先运行 -Verify 再人工判断。'
            }
        }
    }
}

function Get-NetworkStatus {
    param(
        [string]$Registry,
        [string]$LatestVersion,
        [string]$HttpProxy,
        [string]$HttpsProxy
    )

    if (-not $Registry) {
        return [pscustomobject]@{
            Code = 'registry-missing'
            Message = '未能读取 npm registry 配置。'
        }
    }

    if (-not $LatestVersion) {
        return [pscustomobject]@{
            Code = 'registry-unreachable'
            Message = '未能从 registry 读取 Codex 最新版本信息，优先检查网络或代理。'
        }
    }

    if ($HttpProxy -or $HttpsProxy) {
        return [pscustomobject]@{
            Code = 'proxy-active'
            Message = 'registry 可访问，当前通过代理环境变量联网。'
        }
    }

    return [pscustomobject]@{
        Code = 'direct-ok'
        Message = 'registry 可访问，当前未检测到代理环境变量。'
    }
}

function Get-VersionStatus {
    param(
        [string]$LocalVersion,
        [string]$LatestVersion,
        [pscustomobject]$HealthStatus
    )

    if (-not $LocalVersion) {
        return [pscustomobject]@{
            Code = 'local-unknown'
            Message = '未能读取本地 Codex 版本。'
        }
    }

    if (-not $LatestVersion) {
        return [pscustomobject]@{
            Code = 'latest-unknown'
            Message = '未能读取 registry 最新版本，暂时无法比较版本差异。'
        }
    }

    if ($LocalVersion -eq $LatestVersion) {
        return [pscustomobject]@{
            Code = 'up-to-date'
            Message = '本地版本与 registry 最新版本一致。'
        }
    }

    if ($HealthStatus.Code -eq 'healthy') {
        return [pscustomobject]@{
            Code = 'upgrade-available'
            Message = '本地版本低于 registry 最新版本，但当前安装状态健康。'
        }
    }

    return [pscustomobject]@{
        Code = 'upgrade-available-with-issues'
        Message = '本地版本低于 registry 最新版本，且当前安装状态存在问题。'
    }
}

function Write-RunTakeaway {
    param(
        [pscustomobject]$HealthStatus,
        [pscustomobject]$RepairPlan,
        [string]$ExecutedAction,
        [pscustomobject]$NetworkStatus,
        [pscustomobject]$VersionStatus
    )

    $nextAdvice = switch ($HealthStatus.Code) {
        'healthy' { '当前环境健康；只有在需要升级时再执行修复或重装。' }
        'shim-missing' { '如果下次升级卡住，不要直接 Ctrl+C；优先等安装结束或改用新窗口重装。' }
        'shim-residue' { '升级过程中不要中断 npm；一旦中断，优先清理 .codex* 残留再重装。' }
        'win32-missing' { '主包已在，但平台子包缺失；下次优先普通重装，不必先上 --force。' }
        default { '先用 -Verify 看清状态，再决定是否修复。' }
    }

    if ($NetworkStatus.Code -eq 'registry-unreachable') {
        $nextAdvice = '先解决 registry/代理可达性，再做任何重装，否则容易反复进入半安装状态。'
    }

    Write-Log '[takeaway] 本次结论'
    Write-Log ('[takeaway] 故障分类: ' + (Get-HealthStatusLabel $HealthStatus.Code) + ' (' + $HealthStatus.Code + ')')
    Write-Log ('[takeaway] 推荐动作: ' + (Get-RepairActionLabel $RepairPlan.Action) + ' (' + $RepairPlan.Action + ')')
    Write-Log ('[takeaway] 实际动作: ' + $ExecutedAction)
    Write-Log ('[takeaway] 网络状态: ' + (Get-NetworkStatusLabel $NetworkStatus.Code) + ' (' + $NetworkStatus.Code + ')')
    Write-Log ('[takeaway] 版本状态: ' + (Get-VersionStatusLabel $VersionStatus.Code) + ' (' + $VersionStatus.Code + ')')
    Write-Log ('[takeaway] 下次建议: ' + $nextAdvice)
}

function Write-VerifySummary {
    param(
        [string]$NpmCommandPath,
        [string]$NpmGlobalRoot,
        [string]$NpmGlobalBin,
        [string]$PackageDirectory,
        [string]$TargetCommandPath,
        [System.IO.FileSystemInfo[]]$ShimRemainders,
        [bool]$HasOptionalDependency,
        [pscustomobject]$HealthStatus,
        [pscustomobject]$RepairPlan,
        [string]$Registry,
        [string]$HttpProxy,
        [string]$HttpsProxy,
        [string]$LatestVersion,
        [pscustomobject]$NetworkStatus,
        [string]$LocalVersion,
        [pscustomobject]$VersionStatus
    )

    Write-Log '[verify] 进入只验证模式，不执行清理或重装。'
    Write-Log ('[verify] npm 命令: ' + $NpmCommandPath)
    Write-Log ('[verify] npm 全局目录: ' + ($(if ($NpmGlobalRoot) { $NpmGlobalRoot } else { '<unavailable>' })))
    Write-Log ('[verify] npm 全局命令目录: ' + ($(if ($NpmGlobalBin) { $NpmGlobalBin } else { '<unavailable>' })))
    Write-Log ('[verify] Codex 包目录: ' + ($(if ($PackageDirectory) { $PackageDirectory } else { '<unavailable>' })))
    Write-Log ('[verify] Codex 命令路径: ' + ($(if ($TargetCommandPath) { $TargetCommandPath } else { '<missing>' })))
    Write-Log ('[verify] 状态分类: ' + (Get-HealthStatusLabel $HealthStatus.Code) + ' (' + $HealthStatus.Code + ')')
    Write-Log ('[verify] 诊断说明: ' + $HealthStatus.Message)
    Write-Log ('[verify] 推荐动作: ' + (Get-RepairActionLabel $RepairPlan.Action) + ' (' + $RepairPlan.Action + ')')
    Write-Log ('[verify] 修复建议: ' + $RepairPlan.Message)
    Write-Log ('[verify] 网络状态: ' + (Get-NetworkStatusLabel $NetworkStatus.Code) + ' (' + $NetworkStatus.Code + ')')
    Write-Log ('[verify] 网络说明: ' + $NetworkStatus.Message)
    Write-Log ('[verify] npm registry: ' + $(if ($Registry) { $Registry } else { '<unavailable>' }))
    Write-Log ('[verify] HTTP_PROXY: ' + $(if ($HttpProxy) { $HttpProxy } else { '<empty>' }))
    Write-Log ('[verify] HTTPS_PROXY: ' + $(if ($HttpsProxy) { $HttpsProxy } else { '<empty>' }))
    Write-Log ('[verify] 本地版本: ' + $(if ($LocalVersion) { $LocalVersion } else { '<unavailable>' }))
    Write-Log ('[verify] registry 最新版本: ' + $(if ($LatestVersion) { $LatestVersion } else { '<unavailable>' }))
    Write-Log ('[verify] 版本状态: ' + (Get-VersionStatusLabel $VersionStatus.Code) + ' (' + $VersionStatus.Code + ')')
    Write-Log ('[verify] 版本说明: ' + $VersionStatus.Message)
    Write-Log ('[verify] win32 平台依赖: ' + (Get-PresenceLabel $HasOptionalDependency) + ' (' + $(if ($HasOptionalDependency) { 'present' } else { 'missing' }) + ')')
    Write-Log ('[verify] shim / 旧残留数量: ' + $ShimRemainders.Count)

    $shimUnix = if ($NpmGlobalBin) { Join-Path $NpmGlobalBin 'codex' } else { $null }
    $shimCmd = if ($NpmGlobalBin) { Join-Path $NpmGlobalBin 'codex.cmd' } else { $null }
    $shimPs1 = if ($NpmGlobalBin) { Join-Path $NpmGlobalBin 'codex.ps1' } else { $null }
    $whereCodex = @()

    if (-not $WhatIfPreference) {
        $whereCodex = @(where.exe codex 2>$null)
    }

    Write-Log ('[verify] shim 文件 codex: ' + (Get-PresenceLabel ($shimUnix -and (Test-Path -LiteralPath $shimUnix))) + ' (' + $(if ($shimUnix -and (Test-Path -LiteralPath $shimUnix)) { 'present' } else { 'missing' }) + ')')
    Write-Log ('[verify] shim 文件 codex.cmd: ' + (Get-PresenceLabel ($shimCmd -and (Test-Path -LiteralPath $shimCmd))) + ' (' + $(if ($shimCmd -and (Test-Path -LiteralPath $shimCmd)) { 'present' } else { 'missing' }) + ')')
    Write-Log ('[verify] shim 文件 codex.ps1: ' + (Get-PresenceLabel ($shimPs1 -and (Test-Path -LiteralPath $shimPs1))) + ' (' + $(if ($shimPs1 -and (Test-Path -LiteralPath $shimPs1)) { 'present' } else { 'missing' }) + ')')

    if ($whereCodex.Count -gt 0) {
        foreach ($line in $whereCodex) {
            Write-Log ('[verify] where codex: ' + $line)
        }
    } else {
        Write-Log '[verify] where codex: <no result>'
    }

    if (-not $WhatIfPreference) {
        $npmListOutput = & $NpmCommandPath list -g @openai/codex --depth=0 2>&1
        foreach ($line in @($npmListOutput)) {
            Write-Log ('[verify] npm list: ' + $line)
        }
    }

    if ($TargetCommandPath) {
        $versionResult = Invoke-NativeCommand '[verify] 读取 Codex 版本...' $TargetCommandPath @('--version') -Quiet
        $lastVersionLine = $versionResult.StdOut | Select-Object -Last 1
        $versionText = if ($null -ne $lastVersionLine) { $lastVersionLine.ToString().Trim() } else { '' }
        if ($versionText) {
            Write-Log ('[verify] Codex 版本: ' + $versionText)
        } else {
            Write-Log '[verify] Codex 版本读取完成，但没有返回文本。'
        }
    } else {
        Write-Log '[verify] 已跳过版本读取，因为当前未检测到 codex 命令。'
    }

    if ($ShimRemainders.Count -gt 0) {
        foreach ($entry in $ShimRemainders) {
            Write-Log ('[verify] 残留项: ' + $entry.FullName)
        }
    }
}

try {
    Trim-Logs -Keep $LogKeep

    if ($Verify -and $Reinstall) {
        throw '-Verify 与 -Reinstall 不能同时使用。'
    }
    if ($Verify -and $AutoFix) {
        throw '-Verify 与 -AutoFix 不能同时使用。'
    }
    if ($Verify -and $LaunchReinstall) {
        throw '-Verify 与 -LaunchReinstall 不能同时使用。'
    }
    if ($AutoFix -and $Reinstall) {
        throw '-AutoFix 与 -Reinstall 不能同时使用。'
    }
    if ($AutoFix -and $LaunchReinstall) {
        throw '-AutoFix 与 -LaunchReinstall 不能同时使用。'
    }
    if ($Reinstall -and $LaunchReinstall) {
        throw '-Reinstall 与 -LaunchReinstall 不能同时使用。'
    }

    if (($Reinstall -or $AutoFix) -and $env:CODEX_THREAD_ID) {
        $summaryState.mode = if ($AutoFix) { 'autofix' } else { 'reinstall' }
        $summaryState.result = 'blocked'
        $summaryState.executedAction = 'blocked-in-codex-session'
        Write-Log '[blocked] 检测到当前正在 Codex 会话内运行。'
        Write-Log '[blocked] 为避免重装正在运行的 Codex 导致当前会话退出，已拒绝执行修复动作。'
        if ($AutoFix) {
            Write-Log ('[action] 请在新的 PowerShell 窗口中运行: ' + (Join-Path $ScriptDir 'clean-codex.cmd') + ' -AutoFix')
        } else {
            Write-Log ('[action] 请在新的 PowerShell 窗口中运行: ' + (Join-Path $ScriptDir 'clean-codex.cmd') + ' -Reinstall')
        }
        Write-Summary -State $summaryState
        exit 2
    }

    if ($LaunchReinstall) {
        $summaryState.mode = 'launch-reinstall'
        $summaryState.executedAction = 'launch-reinstall'
        Launch-ReinstallWindow -ScriptPath $MyInvocation.MyCommand.Path
        $summaryState.result = 'success'
        Write-Summary -State $summaryState
        Write-Log '[success] 已请求在新 PowerShell 窗口中执行重装。'
        Write-Log ('[log] 日志文件: ' + $LogFile)
        Write-Log ('[summary] 摘要文件: ' + $SummaryFile)
        Trim-Logs -Keep $LogKeep
        exit 0
    }

    $npmCommandPath = Resolve-CommandPath @('npm.cmd', 'npm')
    if (-not $npmCommandPath) {
        throw '未在 PATH 中找到 npm。'
    }

    $targetCommandPath = Resolve-CommandPath @('codex.cmd', 'codex.ps1', 'codex.exe', 'codex')
    $registry = ((& $npmCommandPath config get registry 2>$null) | Select-Object -Last 1).ToString().Trim()
    $httpProxy = $env:HTTP_PROXY
    $httpsProxy = $env:HTTPS_PROXY
    $latestVersionOutput = @(& $npmCommandPath view @openai/codex version 2>$null)
    $latestVersion = if ($LASTEXITCODE -eq 0 -and $latestVersionOutput.Count -gt 0) { ($latestVersionOutput | Select-Object -Last 1).ToString().Trim() } else { '' }
    $networkStatus = Get-NetworkStatus -Registry $registry -LatestVersion $latestVersion -HttpProxy $httpProxy -HttpsProxy $httpsProxy
    $localVersion = ''
    if ($targetCommandPath) {
        $localVersionOutput = @(& $targetCommandPath --version 2>$null)
        if ($LASTEXITCODE -eq 0 -and $localVersionOutput.Count -gt 0) {
            $localVersionText = ($localVersionOutput | Select-Object -Last 1).ToString().Trim()
            if ($localVersionText -match '(\d+\.\d+\.\d+)') {
                $localVersion = $matches[1]
            } else {
                $localVersion = $localVersionText
            }
        }
    }

    Write-Log '[检查] Codex Windows Repair'
    Write-Log ('[检查] 脚本版本: ' + $ScriptVersion)
    Write-Log ('[检查] 目标 npm 包: ' + $PackageName)
    Write-Log ('[检查] 只验证模式: ' + $Verify.IsPresent)
    Write-Log ('[检查] 新窗口重装: ' + $LaunchReinstall.IsPresent)
    Write-Log ('[检查] 重新安装: ' + $Reinstall.IsPresent)
    Write-Log ('[检查] 跳过缓存清理: ' + $SkipCacheClean.IsPresent)
    Write-Log ('[检查] 跳过停止进程: ' + $SkipProcessStop.IsPresent)
    Write-Log ('[检查] WhatIf: ' + [bool]$WhatIfPreference)
    Write-Log ('[info] npm 命令: ' + $npmCommandPath) -NoConsole
    $summaryState.npmCommandPath = $npmCommandPath
    $summaryState.registry = $registry
    $summaryState.httpProxy = $httpProxy
    $summaryState.httpsProxy = $httpsProxy
    $summaryState.latestRegistryVersion = $latestVersion
    $summaryState.localVersion = $localVersion
    $summaryState.networkStatus = $networkStatus.Code
    if ($Verify) {
        $summaryState.mode = 'verify'
    } elseif ($AutoFix) {
        $summaryState.mode = 'autofix'
    } elseif ($Reinstall) {
        $summaryState.mode = 'reinstall'
    }

    $npmGlobalRoot = Get-NpmGlobalRoot -NpmCommandPath $npmCommandPath
    $npmGlobalBin = if ($npmGlobalRoot) { Split-Path -Parent $npmGlobalRoot } else { $null }
    $packageDir = if ($npmGlobalRoot) { Join-Path (Join-Path $npmGlobalRoot '@openai') 'codex' } else { $null }
    $summaryState.npmGlobalRoot = $npmGlobalRoot
    $summaryState.npmGlobalBin = $npmGlobalBin
    $summaryState.packageDirectory = $packageDir

    $shimRemainders = @()
    if ($npmGlobalBin) {
        $shimRemainders = @(Get-ChildItem -LiteralPath $npmGlobalBin -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like $TempPattern })
    }
    $orphanResidues = Get-CodexNpmOrphanResidueEntries -NpmGlobalRoot $npmGlobalRoot
    $allRemainders = @($shimRemainders + $orphanResidues)
    $hasOptionalDependency = Test-CodexOptionalDependency -PackageDirectory $packageDir
    $healthStatus = Get-CodexHealthStatus -TargetCommandPath $targetCommandPath -ShimRemainders $allRemainders -HasOptionalDependency $hasOptionalDependency
    $repairPlan = Get-RepairPlan -HealthStatus $healthStatus -HasOptionalDependency $hasOptionalDependency
    $versionStatus = Get-VersionStatus -LocalVersion $localVersion -LatestVersion $latestVersion -HealthStatus $healthStatus
    $summaryState.codexCommandPath = $targetCommandPath
    $summaryState.hasOptionalDependency = $hasOptionalDependency
    $summaryState.shimResidueCount = $allRemainders.Count
    $summaryState.statusCode = $healthStatus.Code
    $summaryState.statusMessage = $healthStatus.Message
    $summaryState.recommendedAction = $repairPlan.Action
    $summaryState.recommendedMessage = $repairPlan.Message
    $summaryState.versionStatus = $versionStatus.Code

    if ($npmGlobalRoot) {
        Write-Log ('[检查] npm 全局目录: ' + $npmGlobalRoot)
        Write-Log ('[检查] npm 全局命令目录: ' + $npmGlobalBin)
        Write-Log ('[检查] Codex 包目录: ' + $packageDir)
    }
    if ($targetCommandPath) {
        Write-Log ('[检查] 当前 Codex 命令路径: ' + $targetCommandPath)
    } else {
        Write-Log '[warn] 当前未检测到可执行的 codex 命令。'
    }
    Write-Log ('[诊断] 状态分类: ' + (Get-HealthStatusLabel $healthStatus.Code) + ' (' + $healthStatus.Code + ')')
    Write-Log ('[诊断] ' + $healthStatus.Message)
    Write-Log ('[诊断] 推荐动作: ' + (Get-RepairActionLabel $repairPlan.Action) + ' (' + $repairPlan.Action + ')')
    Write-Log ('[诊断] 修复建议: ' + $repairPlan.Message)
    Write-Log ('[诊断] 网络状态: ' + (Get-NetworkStatusLabel $networkStatus.Code) + ' (' + $networkStatus.Code + ')')
    Write-Log ('[诊断] 网络说明: ' + $networkStatus.Message)
    Write-Log ('[诊断] 版本状态: ' + (Get-VersionStatusLabel $versionStatus.Code) + ' (' + $versionStatus.Code + ')')
    Write-Log ('[诊断] 版本说明: ' + $versionStatus.Message)

    if ($Verify) {
        Write-VerifySummary `
            -NpmCommandPath $npmCommandPath `
            -NpmGlobalRoot $npmGlobalRoot `
            -NpmGlobalBin $npmGlobalBin `
            -PackageDirectory $packageDir `
            -TargetCommandPath $targetCommandPath `
            -ShimRemainders $shimRemainders `
            -HasOptionalDependency $hasOptionalDependency `
            -HealthStatus $healthStatus `
            -RepairPlan $repairPlan `
            -Registry $registry `
            -HttpProxy $httpProxy `
            -HttpsProxy $httpsProxy `
            -LatestVersion $latestVersion `
            -NetworkStatus $networkStatus `
            -LocalVersion $localVersion `
            -VersionStatus $versionStatus

        $summaryState.result = 'success'
        $summaryState.executedAction = 'verify-only'
        Write-Summary -State $summaryState
        Write-RunTakeaway `
            -HealthStatus $healthStatus `
            -RepairPlan $repairPlan `
            -ExecutedAction $summaryState.executedAction `
            -NetworkStatus $networkStatus `
            -VersionStatus $versionStatus
        Write-Log '[success] 验证完成。'
        Write-Log ('[log] 日志文件: ' + $LogFile)
        Write-Log ('[summary] 摘要文件: ' + $SummaryFile)
        Trim-Logs -Keep $LogKeep
        exit 0
    }

    Write-Snapshot -NpmCommandPath $npmCommandPath -NpmGlobalBin $npmGlobalBin -NpmGlobalRoot $npmGlobalRoot -TargetCommandPath $targetCommandPath
    Write-Log ('[snapshot] 修复前快照: ' + $SnapshotFile)

    Write-Log '[1/6] 停止 Codex 进程...'
    if ($WhatIfPreference) {
        Write-Log '[whatif] 将停止进程: codex'
    } elseif ($SkipProcessStop) {
        Write-Log '[info] 根据参数跳过停止进程。'
    } else {
        Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Log '[info] 已尝试停止 Codex 进程。'
    }

    $verifyResult = Invoke-NativeCommand '[2/6] 校验 npm 缓存...' $npmCommandPath @('cache', 'verify') -Quiet
    $finishedLine = $verifyResult.StdOut | Select-String -Pattern '^Finished in ' | Select-Object -First 1
    if ($finishedLine) {
        Write-Log ('[info] npm 缓存校验耗时: ' + ($finishedLine.Line -replace '^Finished in\s*', ''))
    } else {
        Write-Log '[info] npm 缓存校验完成。'
    }

    if ($SkipCacheClean) {
        Write-Log '[3/6] 根据参数跳过 npm 缓存清理。'
    } else {
        Invoke-NativeCommand '[3/6] 清理 npm 缓存...' $npmCommandPath @('cache', 'clean', '--force') -Quiet | Out-Null
        Write-Log '[info] npm 缓存清理完成。'
    }

    Write-Log '[4/6] 清理 npm 全局目录中的 Codex 残留与旧临时目录...'
    if (-not $npmGlobalBin) {
        Write-Log '[whatif] 将通过 npm 全局命令目录搜索 .codex* 残留。'
    } else {
        Remove-Paths -Entries $shimRemainders -RootPath $npmGlobalBin -Label 'shim 临时残留'
    }

    $orphanResidues = Clear-CodexNpmOrphanResidue -NpmGlobalRoot $npmGlobalRoot
    $allRemainders = @($shimRemainders + $orphanResidues)

    Clear-CodexUserTemp

    if ($hasOptionalDependency) {
        Write-Log '[检查] 已检测到 Windows 平台依赖 @openai/codex-win32-x64。'
    } else {
        Write-Log '[warn] 缺少 Windows 平台依赖 @openai/codex-win32-x64。'
    }

    if ($AutoFix) {
        if ($repairPlan.Action -eq 'none') {
            $summaryState.executedAction = 'autofix-none'
            Write-Log '[6/6] 当前状态健康，AutoFix 不执行任何修复。'
        } elseif ($repairPlan.Action -eq 'manual') {
            $summaryState.executedAction = 'autofix-manual-required'
            Write-Log '[6/6] AutoFix 无法安全决定动作，请先运行 -Verify 并人工判断。'
        } else {
            $summaryState.executedAction = $repairPlan.Action
            Write-Log ('[6/6] AutoFix 将执行推荐动作: ' + (Get-RepairActionLabel $repairPlan.Action) + ' (' + $repairPlan.Action + ')')
            Invoke-NativeCommand '[6/6] AutoFix 重装 Codex CLI...' $npmCommandPath $repairPlan.InstallArgs | Out-Null
            $targetCommandPath = Resolve-CommandPath @('codex.cmd', 'codex.ps1', 'codex.exe', 'codex')
            $hasOptionalDependency = Test-CodexOptionalDependency -PackageDirectory $packageDir
        }
    } elseif ($Reinstall) {
        $installArgs = $repairPlan.InstallArgs
        if (-not $installArgs -or $installArgs.Count -eq 0) {
            $installArgs = @('install', '-g', '@openai/codex@latest')
        }
        $summaryState.executedAction = if ($repairPlan.Action) { $repairPlan.Action } else { 'reinstall-manual' }
        if ($repairPlan.Action -eq 'reinstall-force') {
            Write-Log '[info] 根据诊断结果，将使用 --force 重建入口。'
        } elseif ($repairPlan.Action -eq 'reinstall-normal') {
            Write-Log '[info] 根据诊断结果，将使用普通重装补齐依赖。'
        }

        Invoke-NativeCommand '[6/6] 重装 Codex CLI...' $npmCommandPath $installArgs | Out-Null
        $targetCommandPath = Resolve-CommandPath @('codex.cmd', 'codex.ps1', 'codex.exe', 'codex')
        $hasOptionalDependency = Test-CodexOptionalDependency -PackageDirectory $packageDir
    } else {
        $summaryState.executedAction = 'cleanup-only'
        Write-Log '[6/6] 跳过重装。如需按推荐策略自动修复，请使用 -AutoFix；如需手动重装，请使用 -Reinstall。'
    }

    $summaryState.codexCommandPath = $targetCommandPath
    $summaryState.hasOptionalDependency = $hasOptionalDependency

    if ($targetCommandPath) {
        $versionResult = Invoke-NativeCommand '[检查] 读取 Codex 版本...' $targetCommandPath @('--version') -Quiet
        $lastVersionLine = $versionResult.StdOut | Select-Object -Last 1
        $versionText = if ($null -ne $lastVersionLine) { $lastVersionLine.ToString().Trim() } else { '' }
        if ($versionText) {
            Write-Log ('[info] 当前 Codex 版本: ' + $versionText)
        }
    } else {
        Write-Log '[warn] 清理后仍未检测到 codex 命令。'
    }

    if (-not $hasOptionalDependency) {
        Write-Log '[warn] 清理完成后仍缺少 @openai/codex-win32-x64，建议执行 clean-codex.cmd -Reinstall。'
    }

    $summaryState.result = 'success'
    Write-Summary -State $summaryState
    Write-RunTakeaway `
        -HealthStatus $healthStatus `
        -RepairPlan $repairPlan `
        -ExecutedAction $summaryState.executedAction `
        -NetworkStatus $networkStatus `
        -VersionStatus $versionStatus
    Write-Log '[success] Codex CLI 清理完成。'
    Write-Log ('[log] 日志文件: ' + $LogFile)
    Write-Log ('[snapshot] 快照文件: ' + $SnapshotFile)
    Write-Log ('[summary] 摘要文件: ' + $SummaryFile)
    Trim-Logs -Keep $LogKeep
    exit 0
}
catch {
    $summaryState.result = 'failed'
    if (-not $summaryState.executedAction) {
        $summaryState.executedAction = 'failed-before-action'
    }
    ($_ | Out-String) | Tee-Object -FilePath $LogFile -Append | Out-Host
    Write-Summary -State $summaryState
    if ($healthStatus -and $repairPlan -and $networkStatus -and $versionStatus) {
        Write-RunTakeaway `
            -HealthStatus $healthStatus `
            -RepairPlan $repairPlan `
            -ExecutedAction $summaryState.executedAction `
            -NetworkStatus $networkStatus `
            -VersionStatus $versionStatus
    }
    Write-Log '[failed] Codex CLI 清理失败。'
    Write-Log ('[log] 日志文件: ' + $LogFile)
    Write-Log ('[snapshot] 快照文件: ' + $SnapshotFile)
    Write-Log ('[summary] 摘要文件: ' + $SummaryFile)
    Trim-Logs -Keep $LogKeep
    exit 1
}
