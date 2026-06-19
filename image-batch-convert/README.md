# image-batch-convert

批量转换本地图片格式，并可按最大宽高做缩放，适合批量处理 `png / jpg / webp` 文件。

Version: `1.0.0`

## Overview

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 批量图片格式转换与缩放 |
| 双击入口 | `open-image-batch-convert.cmd` |
| 命令行入口 | `image-batch-convert.ps1` |
| 依赖 | ImageMagick |

## Quick Start

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\image-batch-convert.ps1 -InputPath .\images -OutputFormat webp
```

限制最大宽度：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\image-batch-convert.ps1 -InputPath .\images -OutputFormat jpg -MaxWidth 1600
```

## Notes

- 依赖 ImageMagick；如果未安装，需要先安装或通过 `-MagickPath` 指定路径
- 当前支持输入扩展名：`png`、`jpg`、`jpeg`、`webp`
- 输出目录默认会创建为 `<格式>-output`
