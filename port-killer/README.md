# port-killer

查询某个 TCP 端口当前被哪个进程占用，并可按需结束对应进程。

Version: `1.2.0`

## 概览

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 查端口占用、结束占用进程、检测 zombie socket，并给出更明确的风险提示 |
| 双击入口 | `open-port-killer.cmd` |
| 命令行入口 | `port-killer.ps1` |

## 快速开始

| 场景 | 命令 / 入口 |
|---|---|
| 查询端口占用 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\port-killer.ps1 -Port 3000` |
| 结束占用进程 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\port-killer.ps1 -Port 3000 -Kill` |
| 预览结束动作 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\port-killer.ps1 -Port 3000 -Kill -WhatIf` |
| 检测 zombie socket | `powershell -NoProfile -ExecutionPolicy Bypass -File .\port-killer.ps1 -Port 3000 -IncludeZombie` |

## 参数说明

| 参数 | 说明 |
|---|---|
| `-Port` | 必填。要检查的本地 TCP 端口，范围 `1-65535` |
| `-Kill` | 可选。结束占用该端口的进程 |
| `-WhatIf` | 可选。预览结束动作，不真正停止进程 |
| `-IncludeZombie` | 可选。同时检测 zombie socket（进程已死但 socket 被内核持有的情况） |

## Zombie Socket 说明

什么是 zombie socket？
- 进程崩溃或被 kill 时，**有时** Windows 内核不释放它的 LISTENING socket
- `netstat` 还会显示该端口 `LISTENING`
- `Get-NetTCPConnection` 报"无进程"（因为 owning PID 已死）
- **无法通过 Stop-Process 释放**，必须重启 Windows

`IncludeZombie` 会通过 `netstat -ano` 检测这种情况并标记 `ZOMBIE` 状态。

## 文件清单

| 文件 | 作用 |
|---|---|
| `port-killer.ps1` | 核心脚本 |
| `open-port-killer.cmd` | 双击入口 |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |

## 使用说明

| 项目 | 说明 |
|---|---|
| 协议范围 | 当前只处理 TCP 端口 |
| 输出内容 | 会列出 `Port`、`State`、`Id`、`ProcessName`、`Path` 和 `Recommendation` |
| 风险提示 | `-Kill` 会强制结束进程，执行前应确认目标 |
| 使用建议 | 第一次处理陌生端口时，建议先不带 `-Kill` 查看结果 |
| 已知限制 | `-Kill` 对 zombie socket 无效（进程已死）|

## 输出说明

| 字段 | 说明 |
|---|---|
| `State=LIVE` | 当前有真实活进程监听该端口 |
| `State=ZOMBIE` | netstat 还能看到 LISTENING，但真实进程已不存在 |
| `Recommendation` | 按进程类型给出的风险提示或下一步建议 |
