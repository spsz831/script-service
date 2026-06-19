# batch-rename

对指定目录中的文件执行批量重命名，支持前缀、后缀和字符串替换。

Version: `1.0.0`

## 概览

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 批量重命名文件 |
| 双击入口 | `open-batch-rename.cmd` |
| 命令行入口 | `batch-rename.ps1` |

## 快速开始

| 场景 | 命令 / 入口 |
|---|---|
| 批量加前缀 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\batch-rename.ps1 -Path .\images -Prefix cover-` |
| 批量加后缀 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\batch-rename.ps1 -Path .\images -Suffix -backup` |
| 批量替换文件名中的字符串 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\batch-rename.ps1 -Path .\images -Find old -Replace new` |
| 预览改名动作 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\batch-rename.ps1 -Path .\images -Prefix cover- -WhatIf` |

## 参数说明

| 参数 | 说明 |
|---|---|
| `-Path` | 必填。目标目录 |
| `-Match` | 可选。文件筛选规则，默认 `*` |
| `-Prefix` | 可选。给文件名增加前缀 |
| `-Suffix` | 可选。给文件名增加后缀 |
| `-Find` | 可选。要查找的文件名片段 |
| `-Replace` | 可选。替换后的文件名片段 |
| `-WhatIf` | 可选。预览改名动作，不真正重命名 |

## 文件清单

| 文件 | 作用 |
|---|---|
| `batch-rename.ps1` | 核心脚本 |
| `open-batch-rename.cmd` | 双击入口 |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |

## 使用说明

| 项目 | 说明 |
|---|---|
| 处理范围 | 当前只处理文件，不处理目录 |
| 生效顺序 | 先替换字符串，再追加前缀，再追加后缀 |
| 扩展名处理 | 只修改文件主名，保留原扩展名 |
| 使用建议 | 建议先在测试目录验证命名规则，再用于正式文件 |
