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

### `npm-cli-clean/`

用于清理 Windows 上通过 `npm -g` 安装的 CLI 工具在升级后留下的常见残留，当前默认兼容 Codex，也支持交互式选择其他 npm CLI。

文档入口：

- [npm-cli-clean/README.md](</E:/WorkCodex/脚本文件/script-service/npm-cli-clean/README.md:1>)

主要文件：

- `clean-codex-update.cmd`
- `clean-npm-cli-update.cmd`
- `clean-npm-cli-update.ps1`
- `tools.json`

主要能力：

- Codex 一键清理入口
- 通用 npm CLI 交互式清理入口
- 已知工具状态检测
- 基于配置文件维护工具清单
- 删除范围限制在 npm 全局目录内

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
