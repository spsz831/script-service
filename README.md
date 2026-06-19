# script-service

个人脚本仓库，用于集中维护各类可复用的 Windows 工具脚本、自动化脚本和开发辅助脚本。

## Repository Scope

这个仓库主要收录：

- Windows 下可直接运行的 PowerShell / CMD 脚本
- 面向命令行工具维护、清理、诊断的小工具
- 日常开发和系统维护中可复用的自动化脚本

当前内容会优先保持：

- 结构清晰
- 可独立使用
- 有最小文档说明
- 尽量避免和个人机器强耦合

## Projects

| 项目 | 说明 | 文档入口 | 主要入口 |
|---|---|---|---|
| `npm-cli-clean/` | 清理 Windows 上 npm 全局 CLI 升级残留 | [README](</E:/WorkCodex/脚本文件/script-service/npm-cli-clean/README.md:1>) | `clean-codex-update.cmd` / `clean-npm-cli-update.cmd` |
| `html-to-png/` | 将本地 HTML 文件导出为长图 PNG | [README](</E:/WorkCodex/脚本文件/script-service/html-to-png/README.md:1>) | `open-html-to-png.cmd` / `html-to-png.ps1` |
| `port-killer/` | 查询端口占用并按需结束对应进程 | `port-killer/README.md` | `open-port-killer.cmd` / `port-killer.ps1` |
| `folder-size-report/` | 统计子目录大小并排序输出 | `folder-size-report/README.md` | `open-folder-size-report.cmd` / `folder-size-report.ps1` |
| `clean-temp-files/` | 清理 Windows 临时目录 | `clean-temp-files/README.md` | `open-clean-temp-files.cmd` / `clean-temp-files.ps1` |
| `batch-rename/` | 对文件执行批量重命名 | `batch-rename/README.md` | `open-batch-rename.cmd` / `batch-rename.ps1` |

### `npm-cli-clean/`

主要能力：

- Codex 一键清理入口
- 通用 npm CLI 交互式清理入口
- 已知工具状态检测
- 基于配置文件维护工具清单
- 删除范围限制在 npm 全局目录内

### `html-to-png/`

主要能力：

- 图形界面选择本地 HTML 文件并导出 PNG
- 命令行方式指定输入和输出路径
- 自动检测 Edge / Chrome 作为截图浏览器

## Repository Conventions

为了方便后续持续扩展，这个总仓库中的每个脚本子目录，尽量遵循下面的最小结构：

- `README.md`
  说明脚本用途、适用范围、风险边界和使用方法

- `LICENSE`
  许可证

- `VERSION`
  当前版本号

- `CHANGELOG.md`
  版本变更记录

- 脚本主文件
  例如 `.ps1`、`.cmd`、`.bat`、`.py`

- 可选配置文件
  例如 `tools.json`、`config.json`

推荐原则：

- 一个子目录解决一类相对独立的问题
- 优先保持可单独复制和使用
- 尽量减少对本机固定路径的依赖
- 修改高风险逻辑前，优先支持预览模式或最小验证

## Usage

如果你只关心当前已经整理好的 npm CLI 清理工具，请进入：

- `npm-cli-clean/`

如果你后续要继续往这个总仓库里加脚本，建议按主题新增子目录，例如：

- `pdf-tools/`
- `system-tools/`
- `dev-helpers/`
- `network-tools/`

## Notes

- 当前仓库优先面向 Windows 环境
- 某些脚本会依赖 `PowerShell`、`git`、`npm` 或其他本地工具
- 每个子目录的具体依赖、边界和风险说明，应该在各自的 `README.md` 中单独维护

## Roadmap

- 持续补充新的脚本子目录
- 统一各子项目的 README 结构
- 为可公开复用的脚本补充版本号、许可证和变更记录
