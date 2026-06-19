# html-to-pdf

将本地 HTML 文件导出为 PDF，适合快速导出静态页面文档。

Version: `1.0.0`

## 概览

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 将本地 HTML 导出为 PDF |
| 双击入口 | `open-html-to-pdf.cmd` |
| 命令行入口 | `html-to-pdf.ps1` |
| 浏览器依赖 | Edge 或 Chrome |

## 快速开始

| 场景 | 命令 / 入口 |
|---|---|
| 命令行导出 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\html-to-pdf.ps1 -InputHtml .\demo.html` |
| 图形界面导出 | `open-html-to-pdf.cmd` |

## 预览与截图

| 项目 | 说明 |
|---|---|
| 建议截图 1 | `docs/pdf-export.png` |
| 建议截图 2 | `docs/pdf-preview.png` |
| Markdown 示例 | `![PDF Export](docs/pdf-export.png)` |

## 参数与说明

| 参数 | 说明 |
|---|---|
| `-InputHtml` | 必填。本地 HTML 文件路径 |
| `-OutputPdf` | 可选。输出 PDF 路径；不填时默认与 HTML 同名 |
| `-BrowserPath` | 可选。手动指定 Edge 或 Chrome 路径 |

## 使用说明

| 项目 | 说明 |
|---|---|
| 依赖 | 浏览器无头打印能力 |
| 适用性 | 更适合本地静态 HTML 文件 |
| 输出策略 | 先写入系统临时目录，再移动到目标 PDF 路径 |

## 文件清单

| 文件 | 作用 |
|---|---|
| `html-to-pdf.ps1` | 命令行核心脚本 |
| `open-html-to-pdf.cmd` | 双击入口 |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |
