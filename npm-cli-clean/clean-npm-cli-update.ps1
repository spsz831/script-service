[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [string]$PackageName,
    [string]$CommandName,
    [string]$ProcessName,
    [string]$TempDirPattern,
    [string[]]$VersionArgs,
    [switch]$Reinstall,
    [switch]$SkipCacheClean,
    [switch]$SkipProcessStop
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir = Join-Path $scriptDir 'logs'
New-Item -ItemType Directory -Force -Path $logDir -WhatIf:$false | Out-Null
$logFile = Join-Path $logDir ('cleanup_' + (Get-Date -Format 'yyyy-MM-dd_HHmmss_fff') + '.log')
$showConfigInConsole = $false
$scriptVersionFile = Join-Path $scriptDir 'VERSION'
$scriptVersion = if (Test-Path -LiteralPath $scriptVersionFile) { (Get-Content -Raw -LiteralPath $scriptVersionFile).Trim() } else { '0.0.0' }

function Write-Log {
    param(
        [string]$Message,
        [switch]$NoConsole
    )

    Add-Content -LiteralPath $logFile -Value $Message -WhatIf:$false
    if (-not $NoConsole) {
        $Message | Out-Host
    }
}

function Trim-Logs {
    param([int]$Keep = 3)
    Get-ChildItem -LiteralPath $logDir -Filter 'cleanup_*.log' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip $Keep |
        Remove-Item -Force -ErrorAction SilentlyContinue -WhatIf:$false
}

function New-KnownTool {
    param(
        [string]$Name,
        [string]$Id,
        [string]$InstallType,
        [string]$PackageName,
        [string]$CommandName,
        [string]$ProcessName,
        [string]$TempDirPattern,
        [string[]]$VersionArgs,
        [string[]]$DetectPaths,
        [bool]$CleanupSupported
    )

    [pscustomobject]@{
        Name             = $Name
        Id               = $Id
        InstallType      = if ($InstallType) { $InstallType } else { 'unknown' }
        PackageName      = $PackageName
        CommandName      = $CommandName
        ProcessName      = $ProcessName
        TempDirPattern   = $TempDirPattern
        VersionArgs      = if ($VersionArgs) { $VersionArgs } else { @('--version') }
        DetectPaths      = if ($DetectPaths) { $DetectPaths } else { @() }
        CleanupSupported = $CleanupSupported
    }
}

function Expand-EnvPath {
    param([string]$PathValue)

    if (-not $PathValue) {
        return $PathValue
    }

    [Environment]::ExpandEnvironmentVariables($PathValue)
}

function Get-KnownTools {
    $configPath = Join-Path $scriptDir 'tools.json'
    if (-not (Test-Path -LiteralPath $configPath)) {
        throw ('未找到工具配置文件: ' + $configPath)
    }

    $rawTools = Get-Content -Raw -LiteralPath $configPath | ConvertFrom-Json
    @($rawTools | ForEach-Object {
        New-KnownTool `
            -Name $_.Name `
            -Id $_.Id `
            -InstallType $_.InstallType `
            -PackageName $_.PackageName `
            -CommandName $_.CommandName `
            -ProcessName $_.ProcessName `
            -TempDirPattern $_.TempDirPattern `
            -VersionArgs @($_.VersionArgs) `
            -DetectPaths @($_.DetectPaths | ForEach-Object { Expand-EnvPath $_ }) `
            -CleanupSupported ([bool]$_.CleanupSupported)
    })
}

function Get-KnownToolDetections {
    param([object[]]$Tools)

    foreach ($tool in $Tools) {
        $cmdCandidates = @()
        if ($tool.CommandName) {
            $cmdCandidates = @("$($tool.CommandName).cmd", "$($tool.CommandName).ps1", "$($tool.CommandName).exe", $tool.CommandName)
        }

        $commandPath = if ($cmdCandidates.Count -gt 0) { Resolve-CommandPath $cmdCandidates } else { $null }
        $detectedPath = $null
        foreach ($path in $tool.DetectPaths) {
            if ($path -and (Test-Path -LiteralPath $path)) {
                $detectedPath = $path
                break
            }
        }

        [pscustomobject]@{
            Tool         = $tool
            Detected     = [bool]($commandPath -or $detectedPath)
            CommandPath  = $commandPath
            DetectedPath = $detectedPath
            Runnable     = [bool]$commandPath
        }
    }
}

function Resolve-CommandPath {
    param([string[]]$Names)

    foreach ($name in $Names) {
        $command = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) {
            return $command.Source
        }
    }

    return $null
}

function Invoke-CmdCommand {
    param(
        [string]$Label,
        [string]$CommandLine,
        [switch]$Quiet
    )

    Write-Log $Label

    if ($WhatIfPreference) {
        Write-Log ('[whatif] 已跳过命令: ' + $CommandLine)
        return [pscustomobject]@{
            ExitCode = 0
            StdOut   = @()
            StdErr   = @()
        }
    }

    $stdoutFile = Join-Path $logDir ('stdout_' + [guid]::NewGuid().ToString() + '.log')
    $stderrFile = Join-Path $logDir ('stderr_' + [guid]::NewGuid().ToString() + '.log')

    try {
        $process = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', $CommandLine -Wait -PassThru -NoNewWindow -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
        $stdout = @()
        $stderr = @()

        if (Test-Path $stdoutFile) {
            $stdout = @(Get-Content -LiteralPath $stdoutFile -ErrorAction SilentlyContinue)
        }
        if (Test-Path $stderrFile) {
            $stderr = @(Get-Content -LiteralPath $stderrFile -ErrorAction SilentlyContinue)
        }

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
            throw "命令执行失败，退出码 $($process.ExitCode): $CommandLine"
        }

        return [pscustomobject]@{
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

    if ($WhatIfPreference) {
        return $null
    }

    $output = & $NpmCommandPath root -g 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "无法解析 npm 全局根目录。输出: $($output | Out-String)"
    }

    $globalRoot = ($output | Select-Object -Last 1).ToString().Trim()
    if (-not $globalRoot) {
        throw 'npm root -g 返回了空路径。'
    }

    return $globalRoot
}

function Get-NpmPackageDirectory {
    param(
        [string]$NpmGlobalRoot,
        [string]$PackageName
    )

    $parts = $PackageName -split '/'
    if ($PackageName.StartsWith('@') -and $parts.Count -ge 2) {
        return Join-Path (Join-Path $NpmGlobalRoot $parts[0]) $parts[1]
    }

    return Join-Path $NpmGlobalRoot $PackageName
}

function Get-TempSearchDirectory {
    param(
        [string]$NpmGlobalRoot,
        [string]$PackageName,
        [string]$PackageDirectory
    )

    if ($PackageName.StartsWith('@')) {
        $parts = $PackageName -split '/'
        if ($parts.Count -ge 1) {
            return Join-Path $NpmGlobalRoot $parts[0]
        }
    }

    return $PackageDirectory
}

function Get-TempDirectories {
    param(
        [string]$SearchRoot,
        [string]$Pattern
    )

    if (-not $SearchRoot -or -not (Test-Path -LiteralPath $SearchRoot)) {
        return @()
    }

    @(Get-ChildItem -LiteralPath $SearchRoot -Directory -Filter $Pattern -ErrorAction SilentlyContinue)
}

function Test-PathWithinRoot {
    param(
        [string]$RootPath,
        [string]$TargetPath
    )

    if (-not $RootPath -or -not $TargetPath) {
        return $false
    }

    $normalizedRoot = [System.IO.Path]::GetFullPath($RootPath).TrimEnd('\') + '\'
    $normalizedTarget = [System.IO.Path]::GetFullPath($TargetPath).TrimEnd('\') + '\'
    return $normalizedTarget.StartsWith($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)
}

function Join-CommandLine {
    param(
        [string]$Executable,
        [string[]]$Arguments
    )

    $tokens = @($Executable) + $Arguments
    ($tokens | ForEach-Object {
        if ($_ -match '[\s"]') {
            '"' + ($_ -replace '"', '\"') + '"'
        } else {
            $_
        }
    }) -join ' '
}

function Read-MenuChoice {
    param([string]$Prompt)

    (Read-Host -Prompt $Prompt).Trim()
}

function Show-KnownToolStatus {
    param([object[]]$Detections)

    Write-Host ''
    Write-Host '已知工具状态:' -ForegroundColor Cyan
    foreach ($item in $Detections) {
        $status = if ($item.Detected) { '已检测到' } else { '未检测到' }
        $support = if ($item.Tool.CleanupSupported) { '支持清理' } else { '仅检测' }
        $runnable = if ($item.Runnable) { '可执行' } else { '不可执行' }
        $installType = if ($item.Tool.InstallType) { $item.Tool.InstallType } else { 'unknown' }
        $detail = if ($item.CommandPath) { $item.CommandPath } elseif ($item.DetectedPath) { $item.DetectedPath } else { '-' }
        Write-Host ("- {0} [{1} / {2} / {3} / {4}] {5}" -f $item.Tool.Name, $status, $support, $runnable, $installType, $detail)
    }
    Write-Host ''
}

function Get-DetectionSummary {
    param([object]$Detection)

    if ($Detection.CommandPath) {
        return '命令: ' + $Detection.CommandPath
    }

    if ($Detection.DetectedPath) {
        return '目录: ' + $Detection.DetectedPath
    }

    return '未检测到来源'
}

function Resolve-InteractiveTarget {
    $knownTools = Get-KnownTools
    $detections = Get-KnownToolDetections -Tools $knownTools
    $supportedDetected = @($detections | Where-Object { $_.Detected -and $_.Tool.CleanupSupported -and $_.Runnable -and $_.Tool.InstallType -eq 'npm' })

    while ($true) {
        Write-Host ''
        Write-Host '以下工具已检测到，且当前可直接清理:' -ForegroundColor Cyan
        if ($supportedDetected.Count -eq 0) {
            Write-Host '  (当前未检测到内置且支持清理的工具)'
        } else {
            for ($i = 0; $i -lt $supportedDetected.Count; $i++) {
                $item = $supportedDetected[$i]
                $tool = $item.Tool
                Write-Host ("{0}. {1} ({2}) [支持清理]" -f ($i + 1), $tool.Name, $tool.Id)
                Write-Host ("   {0}" -f (Get-DetectionSummary -Detection $item)) -ForegroundColor DarkGray
            }
        }
        Write-Host ''
        Write-Host '说明: 主菜单仅显示 npm 安装、支持清理且当前可执行的工具。其他已知工具会在状态页中显示。' -ForegroundColor DarkGray
        Write-Host ''
        Write-Host 'M. 手动输入其他 npm CLI'
        Write-Host 'L. 查看所有已知工具状态'
        Write-Host 'Q. 退出'
        Write-Host ''

        $choice = Read-MenuChoice '请输入编号或选项'
        if (-not $choice) {
            continue
        }

        switch -Regex ($choice.ToUpperInvariant()) {
            '^Q$' { return $null }
            '^L$' {
                Show-KnownToolStatus -Detections $detections
                [void](Read-Host '按回车返回主菜单')
                continue
            }
            '^M$' {
                $manualPackage = Read-Host '请输入 npm 包名（如 @openai/codex 或 vercel）'
                if (-not $manualPackage) {
                    Write-Host '包名不能为空。' -ForegroundColor Yellow
                    continue
                }

                $manualCommand = Read-Host '请输入命令名（如 codex 或 vercel）'
                if (-not $manualCommand) {
                    Write-Host '命令名不能为空。' -ForegroundColor Yellow
                    continue
                }

                $manualProcess = Read-Host '请输入进程名（直接回车则默认与命令名相同）'
                if (-not $manualProcess) {
                    $manualProcess = $manualCommand
                }

                $manualPattern = Read-Host '请输入临时目录匹配规则（直接回车则默认使用 *）'
                if (-not $manualPattern) {
                    $manualPattern = '*'
                }
                if ($manualPattern -eq '*') {
                    Write-Host '警告: 你输入的是通配范围较大的匹配规则 `*`。脚本后续只会在 npm 全局目录下做受限删除。' -ForegroundColor Yellow
                }

                $manualVersionArgs = Read-Host '请输入版本检查参数（直接回车则默认 --version）'
                $versionArgArray = if ($manualVersionArgs) {
                    @($manualVersionArgs -split '\s+')
                } else {
                    @('--version')
                }

                return [pscustomobject]@{
                    Name           = $manualCommand
                    PackageName    = $manualPackage
                    CommandName    = $manualCommand
                    ProcessName    = $manualProcess
                    TempDirPattern = $manualPattern
                    VersionArgs    = $versionArgArray
                }
            }
            '^\d+$' {
                $selectedIndex = [int]$choice
                if ($selectedIndex -ge 1 -and $selectedIndex -le $supportedDetected.Count) {
                    $tool = $supportedDetected[$selectedIndex - 1].Tool
                    return [pscustomobject]@{
                        Name           = $tool.Name
                        PackageName    = $tool.PackageName
                        CommandName    = $tool.CommandName
                        ProcessName    = $tool.ProcessName
                        TempDirPattern = $tool.TempDirPattern
                        VersionArgs    = $tool.VersionArgs
                    }
                }
            }
        }

        Write-Host '无效选择，请重新输入。' -ForegroundColor Yellow
    }
}

try {
    if (-not $PSBoundParameters.ContainsKey('PackageName') -and
        -not $PSBoundParameters.ContainsKey('CommandName') -and
        -not $PSBoundParameters.ContainsKey('ProcessName') -and
        -not $PSBoundParameters.ContainsKey('TempDirPattern')) {
        $selectedTarget = Resolve-InteractiveTarget
        if (-not $selectedTarget) {
            Write-Host '已取消。'
            exit 0
        }

        $PackageName = $selectedTarget.PackageName
        $CommandName = $selectedTarget.CommandName
        $ProcessName = $selectedTarget.ProcessName
        $TempDirPattern = $selectedTarget.TempDirPattern
        $VersionArgs = $selectedTarget.VersionArgs
    }

    if (-not $PackageName) { $PackageName = '@openai/codex' }
    if (-not $CommandName) { $CommandName = 'codex' }
    if (-not $ProcessName) { $ProcessName = $CommandName }
    if (-not $TempDirPattern) { $TempDirPattern = '.codex-*' }
    if (-not $VersionArgs -or $VersionArgs.Count -eq 0) { $VersionArgs = @('--version') }

    Trim-Logs -Keep 3

    Write-Log '[config] clean-npm-cli-update.ps1' -NoConsole:(!$showConfigInConsole)
    Write-Log ('[config] PackageName=' + $PackageName) -NoConsole:(!$showConfigInConsole)
    Write-Log ('[config] CommandName=' + $CommandName) -NoConsole:(!$showConfigInConsole)
    Write-Log ('[config] ProcessName=' + $ProcessName) -NoConsole:(!$showConfigInConsole)
    Write-Log ('[config] TempDirPattern=' + $TempDirPattern) -NoConsole:(!$showConfigInConsole)
    Write-Log ('[config] Reinstall=' + $Reinstall.IsPresent) -NoConsole:(!$showConfigInConsole)
    Write-Log ('[config] SkipCacheClean=' + $SkipCacheClean.IsPresent) -NoConsole:(!$showConfigInConsole)
    Write-Log ('[config] SkipProcessStop=' + $SkipProcessStop.IsPresent) -NoConsole:(!$showConfigInConsole)
    Write-Log ('[config] WhatIf=' + [bool]$WhatIfPreference) -NoConsole:(!$showConfigInConsole)

    $npmCommandPath = Resolve-CommandPath @('npm.cmd', 'npm')
    if (-not $npmCommandPath) {
        throw '未在 PATH 中找到 npm。'
    }

    $commandCandidates = @("$CommandName.cmd", "$CommandName.ps1", "$CommandName.exe", $CommandName)
    $targetCommandPath = Resolve-CommandPath $commandCandidates

    Write-Log '[检查] 环境自检...'
    Write-Log ('[检查] 脚本版本: ' + $scriptVersion)
    Write-Log ('[检查] 目标 npm 包: ' + $PackageName)
    Write-Log ('[检查] 目标命令: ' + $CommandName)
    Write-Log ('[检查] 目标进程名: ' + $ProcessName)
    Write-Log '[检查] 已检测到 npm。'
    if ($targetCommandPath) {
        Write-Log ('[检查] 已检测到目标命令: ' + $CommandName)
    } else {
        Write-Log ('[warn] 未在 PATH 中找到目标命令: ' + $CommandName + '。后续将跳过版本检查。')
    }
    Write-Log '[检查] 如遇删除失败或重装失败，请尝试以管理员身份运行。'

    Write-Log ('[info] npm 命令: ' + $npmCommandPath) -NoConsole
    if ($targetCommandPath) {
        Write-Log ('[info] 目标命令路径: ' + $targetCommandPath) -NoConsole
    }

    $npmGlobalRootPreview = Get-NpmGlobalRoot -NpmCommandPath $npmCommandPath
    if ($npmGlobalRootPreview) {
        $packageDirPreview = Get-NpmPackageDirectory -NpmGlobalRoot $npmGlobalRootPreview -PackageName $PackageName
        $tempSearchRootPreview = Get-TempSearchDirectory -NpmGlobalRoot $npmGlobalRootPreview -PackageName $PackageName -PackageDirectory $packageDirPreview
        Write-Log ('[检查] 当前 npm 全局目录: ' + $npmGlobalRootPreview)
        Write-Log ('[检查] 目标包目录: ' + $packageDirPreview)
        Write-Log ('[检查] 临时目录搜索位置: ' + $tempSearchRootPreview)
    } else {
        Write-Log '[检查] 将在执行时动态解析 npm 全局目录。'
    }

    Write-Log ('[1/6] 停止目标进程 (' + $ProcessName + ')...')
    if ($WhatIfPreference) {
        Write-Log ('[whatif] 将停止进程: ' + $ProcessName)
    } elseif ($SkipProcessStop) {
        Write-Log '[info] 根据参数跳过停止目标进程 (-SkipProcessStop)。'
    } else {
        Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Log ('[info] 已尝试停止进程: ' + $ProcessName)
    }

    $verifyResult = Invoke-CmdCommand '[2/6] 校验 npm 缓存...' 'npm cache verify' -Quiet
    $verifiedLine = $verifyResult.StdOut | Select-String -Pattern '^Content verified:' | Select-Object -First 1
    $indexLine = $verifyResult.StdOut | Select-String -Pattern '^Index entries:' | Select-Object -First 1
    $finishedLine = $verifyResult.StdOut | Select-String -Pattern '^Finished in ' | Select-Object -First 1

    if ($verifiedLine) {
        Write-Log ('[info] 已校验缓存内容: ' + ($verifiedLine.Line -replace '^Content verified:\s*', ''))
    }
    if ($indexLine) {
        Write-Log ('[info] 缓存索引条目: ' + ($indexLine.Line -replace '^Index entries:\s*', ''))
    }
    if ($finishedLine) {
        Write-Log ('[info] 校验耗时: ' + ($finishedLine.Line -replace '^Finished in\s*', ''))
    }
    if (-not $verifiedLine -and -not $indexLine -and -not $finishedLine) {
        Write-Log '[info] npm 缓存校验完成。'
    }

    if ($SkipCacheClean) {
        Write-Log '[3/6] 根据参数跳过清理 npm 缓存 (-SkipCacheClean)。'
    } else {
        $cleanResult = Invoke-CmdCommand '[3/6] 清理 npm 缓存...' 'npm cache clean --force' -Quiet
        $npmWarnings = @($cleanResult.StdOut + $cleanResult.StdErr | Where-Object { $_ -match '^npm warn ' })
        if ($npmWarnings.Count -gt 0) {
            foreach ($warning in $npmWarnings) {
                Write-Log ('[warn] ' + $warning)
            }
        } else {
            Write-Log '[info] npm 缓存清理完成。'
        }
    }

    Write-Log ('[4/6] 删除临时目录 (' + $TempDirPattern + ')...')
    $npmGlobalRoot = $npmGlobalRootPreview
    if ($npmGlobalRoot) {
        $packageDir = Get-NpmPackageDirectory -NpmGlobalRoot $npmGlobalRoot -PackageName $PackageName
        $tempSearchRoot = Get-TempSearchDirectory -NpmGlobalRoot $npmGlobalRoot -PackageName $PackageName -PackageDirectory $packageDir
        Write-Log ('[info] 目标包目录: ' + $packageDir) -NoConsole
        Write-Log ('[info] 临时目录搜索位置: ' + $tempSearchRoot) -NoConsole
        if (-not (Test-PathWithinRoot -RootPath $npmGlobalRoot -TargetPath $tempSearchRoot)) {
            throw ('临时目录搜索位置超出 npm 全局目录范围，已拒绝执行: ' + $tempSearchRoot)
        }
        $tempDirs = Get-TempDirectories -SearchRoot $tempSearchRoot -Pattern $TempDirPattern
    } else {
        Write-Log '[whatif] 将通过 `npm root -g` 解析 npm 全局目录。'
        Write-Log ('[whatif] 将检查 <npm-global-root> 下匹配 ' + $TempDirPattern + ' 的临时目录。')
        $tempDirs = @()
    }

    if ($tempDirs.Count -eq 0) {
        Write-Log ('[info] 未发现匹配的临时目录: ' + $TempDirPattern)
    } else {
        Write-Log ('[info] 发现 ' + $tempDirs.Count + ' 个临时目录:')
        foreach ($dir in $tempDirs) {
            Write-Log ('  - ' + $dir.FullName)
        }

        foreach ($dir in $tempDirs) {
            if (-not (Test-PathWithinRoot -RootPath $npmGlobalRoot -TargetPath $dir.FullName)) {
                Write-Log ('[warn] 跳过超出 npm 全局目录范围的路径: ' + $dir.FullName)
                continue
            }
            if ($PSCmdlet.ShouldProcess($dir.FullName, '删除 CLI 更新临时目录')) {
                Remove-Item -LiteralPath $dir.FullName -Recurse -Force -ErrorAction SilentlyContinue
                if (Test-Path -LiteralPath $dir.FullName) {
                    Write-Log ('[warn] 删除临时目录失败: ' + $dir.FullName)
                } else {
                    Write-Log ('[info] 已删除临时目录: ' + $dir.FullName)
                }
            } else {
                Write-Log ('[whatif] 将删除临时目录: ' + $dir.FullName)
            }
        }
    }

    if ($Reinstall) {
        $reinstallCommand = 'npm install -g ' + $PackageName
        Invoke-CmdCommand ('[5/6] 重新安装 ' + $PackageName + '...') $reinstallCommand | Out-Null
    } else {
        Write-Log '[5/6] 跳过重新安装。如需重装请使用 -Reinstall。'
    }

    if ($targetCommandPath) {
        $versionCommand = Join-CommandLine -Executable $CommandName -Arguments $VersionArgs
        $versionResult = Invoke-CmdCommand ('[6/6] 检查 ' + $CommandName + ' 版本...') $versionCommand -Quiet
        $lastVersionLine = $versionResult.StdOut | Select-Object -Last 1
        $versionText = if ($null -ne $lastVersionLine) { $lastVersionLine.ToString().Trim() } else { '' }
        if ($versionText) {
            Write-Log ('[info] 当前 ' + $CommandName + ' 版本: ' + $versionText)
        } else {
            Write-Log ('[info] ' + $CommandName + ' 版本检查完成。')
        }
    } else {
        Write-Log ('[6/6] 跳过版本检查，因为未找到命令: ' + $CommandName)
    }

    Write-Log '[success] 清理已成功完成。'
    Write-Log ('[log] 日志文件: ' + $logFile)
    Trim-Logs -Keep 3
    exit 0
}
catch {
    ($_ | Out-String) | Tee-Object -FilePath $logFile -Append | Out-Host
    Write-Log '[failed] 清理未成功完成。'
    Write-Log ('[log] 日志文件: ' + $logFile)
    Trim-Logs -Keep 3
    exit 1
}
