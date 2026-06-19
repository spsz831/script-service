# script-service

个人脚本仓库，用于集中维护各类可复用的 Windows 工具脚本、自动化脚本和开发辅助脚本。

## 仓库概览

| 项目 | 说明 |
|---|---|
| 主要收录 | Windows 下可直接运行的 PowerShell / CMD 脚本 |
| 工具类型 | CLI 维护、文件处理、系统维护、开发辅助、自动化脚本 |
| 当前目标 | 结构清晰、可独立使用、带最小文档、尽量减少本机强耦合 |

## 脚本分类总表

| 分类 | 包含项目 | 适用场景 |
|---|---|---|
| CLI | `npm-cli-clean` | 清理 npm 全局 CLI 升级残留、处理 `EPERM` / `unlink` 类报错 |
| 文件处理 | `html-to-png`、`html-to-pdf`、`batch-rename`、`image-batch-convert` | HTML 导出、批量改名、图片格式转换与缩放 |
| 系统维护 | `clean-temp-files`、`folder-size-report`、`port-killer` | 清理临时文件、排查磁盘占用、处理端口占用 |
| 开发辅助 | `project-cleaner`、`port-killer`、`folder-size-report` | 清理项目缓存、定位开发端口冲突、快速查看项目目录体积 |

## 项目清单

| 项目 | 说明 | 文档入口 | 主要入口 |
|---|---|---|---|
| `npm-cli-clean/` | 清理 Windows 上 npm 全局 CLI 升级残留 | [README](npm-cli-clean/README.md) | `clean-codex-update.cmd` / `clean-npm-cli-update.cmd` |
| `html-to-png/` | 将本地 HTML 文件导出为长图 PNG | [README](html-to-png/README.md) | `open-html-to-png.cmd` / `html-to-png.ps1` |
| `html-to-pdf/` | 将本地 HTML 文件导出为 PDF | [README](html-to-pdf/README.md) | `open-html-to-pdf.cmd` / `html-to-pdf.ps1` |
| `port-killer/` | 查询端口占用并按需结束对应进程 | [README](port-killer/README.md) | `open-port-killer.cmd` / `port-killer.ps1` |
| `folder-size-report/` | 统计子目录大小并排序输出 | [README](folder-size-report/README.md) | `open-folder-size-report.cmd` / `folder-size-report.ps1` |
| `clean-temp-files/` | 清理 Windows 临时目录 | [README](clean-temp-files/README.md) | `open-clean-temp-files.cmd` / `clean-temp-files.ps1` |
| `batch-rename/` | 对文件执行批量重命名 | [README](batch-rename/README.md) | `open-batch-rename.cmd` / `batch-rename.ps1` |
| `image-batch-convert/` | 批量转换 png/jpg/webp 并缩放 | [README](image-batch-convert/README.md) | `open-image-batch-convert.cmd` / `image-batch-convert.ps1` |
| `project-cleaner/` | 扫描并清理常见项目缓存目录 | [README](project-cleaner/README.md) | `open-project-cleaner.cmd` / `project-cleaner.ps1` |

## 推荐脚本

| 项目 | 推荐原因 |
|---|---|
| `npm-cli-clean/` | 结构最完整，包含交互菜单、配置文件、风险边界和日志机制 |
| `html-to-png/` | 适合快速导出本地 HTML 长图，使用门槛低 |
| `port-killer/` | 开发场景高频实用，定位明确 |
| `project-cleaner/` | 对 Node / Python 项目维护很有帮助 |

| 项目 | 代表能力 |
|---|---|
| `npm-cli-clean/` | Codex 一键清理、通用 npm CLI 交互式清理、状态检测、配置化工具清单 |
| `html-to-png/` | GUI 选择本地 HTML 文件、命令行导出 PNG、自动检测 Edge / Chrome |
| `html-to-pdf/` | 本地 HTML 快速导出 PDF，兼容中文路径输出 |
| `project-cleaner/` | 常见 Node / Python 缓存目录扫描与安全预览删除 |

## 仓库规范

| 约定项 | 说明 |
|---|---|
| `README.md` | 说明脚本用途、适用范围、风险边界和使用方法 |
| `LICENSE` | 许可证 |
| `VERSION` | 当前版本号 |
| `CHANGELOG.md` | 版本变更记录 |
| 主脚本文件 | 例如 `.ps1`、`.cmd`、`.bat`、`.py` |
| 可选配置文件 | 例如 `tools.json`、`config.json` |
| 目录原则 | 一个子目录解决一类相对独立的问题 |
| 维护原则 | 优先保持可单独复制使用，尽量减少固定路径依赖 |
| 安全原则 | 高风险逻辑优先支持预览模式或最小验证 |

## 使用方式

| 场景 | 建议 |
|---|---|
| 只关心 CLI 清理 | 进入 `npm-cli-clean/` |
| 只关心 HTML 导出 | 进入 `html-to-png/` 或 `html-to-pdf/` |
| 只关心系统维护 | 优先看 `clean-temp-files/`、`port-killer/`、`folder-size-report/` |
| 只关心批量处理 | 优先看 `batch-rename/`、`image-batch-convert/` |
| 继续扩展仓库 | 建议按主题增加独立子目录，例如 `pdf-tools/`、`system-tools/`、`dev-helpers/`、`network-tools/` |

## 依赖与说明

| 项目 | 说明 |
|---|---|
| 平台优先级 | 当前仓库优先面向 Windows |
| 常见依赖 | `PowerShell`、`git`、`npm`、浏览器、ImageMagick 等 |
| 详细边界 | 各子目录的依赖、边界和风险说明应在各自 `README.md` 中维护 |

## 计划方向

| 方向 | 说明 |
|---|---|
| 新增脚本 | 持续补充新的脚本子目录 |
| 文档统一 | 继续统一各子项目 README 结构 |
| 发布完善 | 为可公开复用的脚本补充版本号、许可证和变更记录 |
