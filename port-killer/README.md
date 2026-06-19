# port-killer

查询某个 TCP 端口当前被哪个进程占用，并可按需结束对应进程。

Version: `1.0.0`

## Overview

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 查端口占用、结束占用进程 |
| 双击入口 | `open-port-killer.cmd` |
| 命令行入口 | `port-killer.ps1` |

## Quick Start

### 查询端口

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\port-killer.ps1 -Port 3000
```

### 结束占用进程

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\port-killer.ps1 -Port 3000 -Kill
```

## Project Files

| 文件 | 作用 |
|---|---|
| `port-killer.ps1` | 核心脚本 |
| `open-port-killer.cmd` | 双击入口 |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |

## Notes

- 当前只处理 TCP 端口
- `-Kill` 会强制结束进程，执行前应确认目标
