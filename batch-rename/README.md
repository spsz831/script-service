# batch-rename

对指定目录中的文件执行批量重命名，支持前缀、后缀和字符串替换。

Version: `1.0.0`

## Overview

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 批量重命名文件 |
| 双击入口 | `open-batch-rename.cmd` |
| 命令行入口 | `batch-rename.ps1` |

## Quick Start

### 批量加前缀

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\batch-rename.ps1 -Path .\images -Prefix cover-
```

### 批量替换文件名中的字符串

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\batch-rename.ps1 -Path .\images -Find old -Replace new
```

## Notes

- 当前只处理文件，不处理目录
- 建议先在测试目录验证命名规则再用于正式文件
