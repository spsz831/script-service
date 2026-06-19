# folder-size-report

扫描指定目录下的子文件夹大小，按占用空间从大到小输出，适合快速找出空间大户。

Version: `1.0.0`

## 概览

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 统计子目录大小并排序 |
| 双击入口 | `open-folder-size-report.cmd` |
| 命令行入口 | `folder-size-report.ps1` |

## 快速开始

| 场景 | 命令 / 入口 |
|---|---|
| 扫描指定目录 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path E:\WorkCodex` |
| 只看前 10 个目录 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path E:\WorkCodex -Top 10` |

## 参数说明

| 参数 | 说明 |
|---|---|
| `-Path` | 可选。要扫描的根目录，默认当前目录 |
| `-Top` | 可选。输出前多少个子目录，默认 `20` |

## 文件清单

| 文件 | 作用 |
|---|---|
| `folder-size-report.ps1` | 核心脚本 |
| `open-folder-size-report.cmd` | 双击入口 |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |

## 使用说明

| 项目 | 说明 |
|---|---|
| 统计范围 | 扫描目标目录的直接子目录，再递归统计各自体积 |
| 排序规则 | 按 `SizeBytes` 从大到小排序 |
| 输出字段 | `Name`、`SizeMB`、`FullName` |
| 适用场景 | 快速找出磁盘空间占用较大的项目目录 |
