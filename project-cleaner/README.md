# project-cleaner

扫描常见 Node / Python 项目缓存目录，并可按需执行清理。

Version: `1.0.0`

## Overview

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 扫描并清理常见项目缓存目录 |
| 双击入口 | `open-project-cleaner.cmd` |
| 命令行入口 | `project-cleaner.ps1` |

## Quick Start

### 只扫描

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\project-cleaner.ps1 -Path .\
```

### 实际清理

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\project-cleaner.ps1 -Path .\ -Clean
```

## Notes

- 默认只扫描，不清理
- 支持 `-WhatIf` 预览删除动作
- 当前重点覆盖 Node / Python 常见缓存目录
