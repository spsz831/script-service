# clean-temp-files

清理 Windows 临时文件目录，默认清理当前用户临时目录，可选清理 `C:\Windows\Temp`。

Version: `1.0.0`

## 概览

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 清理临时文件 |
| 双击入口 | `open-clean-temp-files.cmd` |
| 命令行入口 | `clean-temp-files.ps1` |

## 快速开始

| 场景 | 命令 / 入口 |
|---|---|
| 默认清理用户临时目录 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\clean-temp-files.ps1` |
| 额外清理 `C:\Windows\Temp` | `powershell -NoProfile -ExecutionPolicy Bypass -File .\clean-temp-files.ps1 -IncludeWindowsTemp` |
| 预览清理动作 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\clean-temp-files.ps1 -WhatIf` |

## 参数说明

| 参数 | 说明 |
|---|---|
| `-IncludeWindowsTemp` | 可选。把 `C:\Windows\Temp` 一并加入清理范围 |
| `-WhatIf` | 可选。预览删除动作，不真正删除 |

## 文件清单

| 文件 | 作用 |
|---|---|
| `clean-temp-files.ps1` | 核心脚本 |
| `open-clean-temp-files.cmd` | 双击入口 |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |

## 使用说明

| 项目 | 说明 |
|---|---|
| 默认范围 | 当前用户临时目录 `%TEMP%` |
| 扩展范围 | 可选加入 `C:\Windows\Temp` |
| 删除策略 | 会跳过被占用或无法删除的项目 |
| 使用建议 | 建议先关闭明显占用大量临时文件的软件再运行 |
