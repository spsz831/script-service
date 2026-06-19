# html-to-png

将本地 HTML 文件渲染为长图 PNG 的小工具，适合快速把单个静态 HTML 页面导出成长截图。

Version: `1.0.0`

## 概览

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 将本地 HTML 文件导出为长图 PNG |
| 图形界面入口 | `open-html-to-png.cmd` |
| 命令行入口 | `html-to-png.ps1` |
| 浏览器依赖 | Edge 或 Chrome |
| 默认输出 | 同目录下 `-fullpage.png` |

## 快速开始

| 场景 | 命令 / 入口 |
|---|---|
| 图形界面方式 | `open-html-to-png.cmd` |
| 命令行方式 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\html-to-png.ps1 -InputHtml .\demo.html` |
| 指定输出文件 | `powershell -NoProfile -ExecutionPolicy Bypass -File .\html-to-png.ps1 -InputHtml .\demo.html -OutputImage .\demo-fullpage.png` |

| 图形界面流程 | 说明 |
|---|---|
| 1 | 弹出文件选择框选择本地 HTML 文件 |
| 2 | 弹出保存框选择 PNG 输出位置 |
| 3 | 调用本机 Edge 或 Chrome 无头模式截图 |

## 预览与截图

| 项目 | 说明 |
|---|---|
| 建议截图 1 | `docs/gui-select.png` |
| 建议截图 2 | `docs/output-example.png` |
| Markdown 示例 | `![GUI Select](docs/gui-select.png)` |

## 参数说明

| 参数 | 说明 |
|---|---|
| `-InputHtml` | 必填。本地 HTML 文件路径，支持 `.html` 和 `.htm` |
| `-OutputImage` | 可选。输出 PNG 路径；不填时默认输出到 HTML 同目录，文件名后缀为 `-fullpage.png` |
| `-Width` | 可选。浏览器窗口宽度，默认 `1440` |
| `-Height` | 可选。浏览器窗口高度，默认 `12000` |
| `-BrowserPath` | 可选。手动指定浏览器路径 |

## 浏览器要求

| 检测顺序 | 浏览器 |
|---|---|
| 1 | Microsoft Edge |
| 2 | Google Chrome |

如果系统里都没有，脚本会报错，并提示你通过 `-BrowserPath` 指定浏览器路径。

## 文件清单

| 文件 | 作用 |
|---|---|
| `html-to-png.ps1` | 命令行核心脚本 |
| `html-to-png-gui.ps1` | GUI 选择器脚本 |
| `open-html-to-png.cmd` | 双击入口 |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |

## 使用说明

| 项目 | 说明 |
|---|---|
| 输入范围 | 当前主要面向本地单个 HTML 文件 |
| 依赖 | 依赖浏览器无头截图能力，不内置浏览器 |
| 适用性 | 更适合静态页面导出，不保证复杂动态页面完全一致 |

## 后续计划

| 方向 | 说明 |
|---|---|
| 批量处理 | 增加一次处理多个 HTML 文件的能力 |
| 尺寸预设 | 增加常见截图宽度和高度预设 |
| 输出增强 | 评估自动裁剪和透明背景支持 |
