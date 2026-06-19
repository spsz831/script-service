# image-batch-convert

批量转换本地图片格式，并可按最大宽高做缩放，适合批量处理 `png / jpg / webp` 文件。

Version: `1.0.0`

## 概览

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 批量图片格式转换与缩放 |
| 双击入口 | `open-image-batch-convert.cmd` |
| 命令行入口 | `image-batch-convert.ps1` |
| 依赖 | ImageMagick |

## 快速开始

| 场景 | 命令 / 入口 |
|---|---|
| 批量转为 `webp` | `powershell -NoProfile -ExecutionPolicy Bypass -File .\image-batch-convert.ps1 -InputPath .\images -OutputFormat webp` |
| 限制最大宽度 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\image-batch-convert.ps1 -InputPath .\images -OutputFormat jpg -MaxWidth 1600` |
| 限制最大宽高 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\image-batch-convert.ps1 -InputPath .\images -OutputFormat png -MaxWidth 1600 -MaxHeight 1600` |
| 预览转换动作 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\image-batch-convert.ps1 -InputPath .\images -OutputFormat webp -WhatIf` |

## 参数说明

| 参数 | 说明 |
|---|---|
| `-InputPath` | 必填。输入图片目录 |
| `-OutputFormat` | 必填。输出格式，支持 `png`、`jpg`、`webp` |
| `-OutputDirectory` | 可选。输出目录；不填时默认创建 `<格式>-output` |
| `-Filter` | 可选。输入文件筛选规则，默认 `*.*` |
| `-MaxWidth` | 可选。最大宽度，超出时按比例缩小 |
| `-MaxHeight` | 可选。最大高度，超出时按比例缩小 |
| `-Quality` | 可选。输出质量，默认 `92` |
| `-MagickPath` | 可选。手动指定 `magick.exe` 路径 |
| `-WhatIf` | 可选。预览转换动作，不真正输出文件 |

## 文件清单

| 文件 | 作用 |
|---|---|
| `image-batch-convert.ps1` | 核心脚本 |
| `open-image-batch-convert.cmd` | 双击入口 |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |

## 使用说明

| 项目 | 说明 |
|---|---|
| 依赖要求 | 依赖 ImageMagick；如未安装，可通过 `-MagickPath` 指定路径 |
| 支持输入 | `png`、`jpg`、`jpeg`、`webp` |
| 默认输出目录 | 自动创建为 `<格式>-output` |
| 缩放规则 | 只在超出最大宽高时按比例缩小，不强行拉伸 |
