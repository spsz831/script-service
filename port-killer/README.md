# port-killer

查询某个 TCP 端口当前被哪个进程占用，并可按需结束对应进程。

Version: `1.0.0`

## 概览

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 查端口占用、结束占用进程 |
| 双击入口 | `open-port-killer.cmd` |
| 命令行入口 | `port-killer.ps1` |

## 快速开始

| 场景 | 命令 / 入口 |
|---|---|
| 查询端口占用 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\port-killer.ps1 -Port 3000` |
| 结束占用进程 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\port-killer.ps1 -Port 3000 -Kill` |
| 预览结束动作 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\port-killer.ps1 -Port 3000 -Kill -WhatIf` |

## 参数说明

| 参数 | 说明 |
|---|---|
| `-Port` | 必填。要检查的本地 TCP 端口，范围 `1-65535` |
| `-Kill` | 可选。结束占用该端口的进程 |
| `-WhatIf` | 可选。预览结束动作，不真正停止进程 |

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
| 输出内容 | 会列出进程 `Id`、`ProcessName` 和 `Path` |
| 风险提示 | `-Kill` 会强制结束进程，执行前应确认目标 |
| 使用建议 | 第一次处理陌生端口时，建议先不带 `-Kill` 查看结果 |
