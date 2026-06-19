# Changelog

## 1.0.0

- 首个公开整理版。
- 提供 `clean-codex-update.cmd` 作为 Codex 专用入口。
- 提供 `clean-npm-cli-update.cmd` 作为通用交互入口。
- 提供 `tools.json` 维护已知工具清单。
- 主菜单仅显示 npm 安装、支持清理且当前可执行的工具。
- 状态页区分已检测、支持清理、可执行和安装来源。
- 增加手动模式的删除范围保护，仅允许在 npm 全局目录内执行目标清理。
