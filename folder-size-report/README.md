# folder-size-report

扫描指定目录下的子文件夹大小，按占用空间从大到小输出，适合快速找出空间大户。

Version: `1.0.0`

## Overview

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 统计子目录大小并排序 |
| 双击入口 | `open-folder-size-report.cmd` |
| 命令行入口 | `folder-size-report.ps1` |

## Quick Start

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path E:\WorkCodex
```

## Project Files

| 文件 | 作用 |
|---|---|
| `folder-size-report.ps1` | 核心脚本 |
| `open-folder-size-report.cmd` | 双击入口 |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |
