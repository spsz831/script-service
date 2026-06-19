# clean-temp-files

清理 Windows 临时文件目录，默认清理当前用户临时目录，可选清理 `C:\Windows\Temp`。

Version: `1.0.0`

## Overview

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 清理临时文件 |
| 双击入口 | `open-clean-temp-files.cmd` |
| 命令行入口 | `clean-temp-files.ps1` |

## Quick Start

### 默认清理用户临时目录

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\clean-temp-files.ps1
```

### 额外清理 Windows Temp

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\clean-temp-files.ps1 -IncludeWindowsTemp
```

## Notes

- 会跳过被占用或无法删除的项目
- 建议先关闭明显占用大量临时文件的软件再运行
