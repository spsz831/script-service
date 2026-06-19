# project-cleaner

扫描常见 Node / Python 项目缓存目录，并可按需执行清理。

Version: `1.0.0`

## 概览

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 扫描并清理常见项目缓存目录 |
| 双击入口 | `open-project-cleaner.cmd` |
| 命令行入口 | `project-cleaner.ps1` |

## 快速开始

| 场景 | 命令 / 入口 |
|---|---|
| 只扫描 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\project-cleaner.ps1 -Path .\` |
| 实际清理 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\project-cleaner.ps1 -Path .\ -Clean` |
| 预览清理动作 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\project-cleaner.ps1 -Path .\ -Clean -WhatIf` |

## 参数说明

| 参数 | 说明 |
|---|---|
| `-Path` | 可选。要扫描的项目根目录，默认当前目录 |
| `-Clean` | 可选。实际删除扫描到的缓存目录 |
| `-WhatIf` | 可选。预览删除动作，不真正清理 |

## 文件清单

| 文件 | 作用 |
|---|---|
| `project-cleaner.ps1` | 核心脚本 |
| `open-project-cleaner.cmd` | 双击入口 |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |

## 使用说明

| 项目 | 说明 |
|---|---|
| 默认行为 | 默认只扫描，不清理 |
| 预览支持 | 支持 `-WhatIf` 预览删除动作 |
| 重点覆盖 | Node / Python 常见缓存目录 |
| 常见目标 | `dist`、`build`、`coverage`、`__pycache__`、`.pytest_cache`、`.next`、`.nuxt`、`.turbo` 等 |
