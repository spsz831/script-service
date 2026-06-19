# html-to-pdf

将本地 HTML 文件导出为 PDF，适合快速导出静态页面文档。

Version: `1.0.0`

## Overview

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 将本地 HTML 导出为 PDF |
| 双击入口 | `open-html-to-pdf.cmd` |
| 命令行入口 | `html-to-pdf.ps1` |
| 浏览器依赖 | Edge 或 Chrome |

## Quick Start

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\html-to-pdf.ps1 -InputHtml .\demo.html
```

## Notes

- 依赖浏览器无头打印能力
- 更适合本地静态 HTML 文件
