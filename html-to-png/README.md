# html-to-png

将本地 HTML 文件渲染为长图 PNG 的小工具，适合快速把单个静态 HTML 页面导出成长截图。

Version: `1.0.0`

## Overview

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 将本地 HTML 文件导出为长图 PNG |
| 图形界面入口 | `open-html-to-png.cmd` |
| 命令行入口 | `html-to-png.ps1` |
| 浏览器依赖 | Edge 或 Chrome |
| 默认输出 | 同目录下 `-fullpage.png` |

## Quick Start

### 图形界面方式

直接双击：

```bat
open-html-to-png.cmd
```

脚本会：

1. 弹出文件选择框选择本地 HTML 文件
2. 弹出保存框选择 PNG 输出位置
3. 调用本机 Edge 或 Chrome 无头模式截图

### 命令行方式

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\html-to-png.ps1 -InputHtml .\demo.html
```

也可以指定输出文件：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\html-to-png.ps1 -InputHtml .\demo.html -OutputImage .\demo-fullpage.png
```

## Preview

建议后续补一张 GUI 选择流程截图或导出结果截图，放在：

- `docs/gui-select.png`
- `docs/output-example.png`

Markdown 引用示例：

```md
![GUI Select](docs/gui-select.png)
```

## Parameters

- `-InputHtml`
  必填。本地 HTML 文件路径，支持 `.html` 和 `.htm`

- `-OutputImage`
  可选。输出 PNG 路径；不填时默认输出到 HTML 同目录，文件名后缀为 `-fullpage.png`

- `-Width`
  可选。浏览器窗口宽度，默认 `1440`

- `-Height`
  可选。浏览器窗口高度，默认 `12000`

- `-BrowserPath`
  可选。手动指定浏览器路径

## Browser Requirements

默认会按顺序检测以下浏览器：

- Microsoft Edge
- Google Chrome

如果系统里都没有，脚本会报错，并提示你通过 `-BrowserPath` 指定浏览器路径。

## Project Files

| 文件 | 作用 |
|---|---|
| `html-to-png.ps1` | 命令行核心脚本 |
| `html-to-png-gui.ps1` | GUI 选择器脚本 |
| `open-html-to-png.cmd` | 双击入口 |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |

## Notes

- 当前脚本主要面向本地单个 HTML 文件
- 依赖浏览器的无头截图能力，不内置浏览器
- 更适合静态页面导出，不保证复杂动态页面完全一致

## Roadmap

- 增加批量处理模式
- 增加更多截图尺寸预设
- 评估是否增加自动裁剪或透明背景支持
