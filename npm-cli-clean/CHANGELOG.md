# Changelog

## 1.0.6

- 轻量加固 `clean-npm-cli-update.cmd`：区分“无参数交互模式”和“带参数透传模式”，启动时给出更清晰的控制台提示。
- README 补充通用入口的推荐定位，强调它更适合交互菜单，而不是替代固定 Codex 入口。

## 1.0.5

- 将 Codex 固定入口从 3 个收敛为 2 个：`clean-codex.cmd` 和 `clean-codex-reinstall.cmd`。
- 删除旧入口 `clean-codex-update.cmd`，并将安全清理/重装入口重命名为更短的日常名称。
- 同步更新 README，简化使用说明和推荐路径。

## 1.0.4

- 新增 `clean-codex-reinstall-safe.cmd` 固定重装入口，执行安全清理后自动附带 `-Reinstall`。
- 同步更新 README，补充固定重装入口的使用说明和推荐场景。

## 1.0.3

- 新增 `clean-codex-update-safe.cmd` 固定安全入口，适合日常双击使用，避免额外参数透传带来的转义歧义。
- 将 npm 缓存校验、缓存清理、重装和版本检查改为原生命令参数调用，不再统一经由 `cmd.exe /c` 拼接执行。
- 将 Codex 用户临时目录清理改为白名单模式，当前仅清理 `plugins`、`plugins.sha`、`plugins.sync.lock`。
- 增加 `-LogKeep` 参数，默认日志保留数量从 3 提升到 10。
- 同步更新 README 中的版本号、入口说明和安全边界描述。

## 1.0.2

- 调整 `clean-codex-update.cmd` 默认参数，不再默认附带 `-SkipProcessStop`。
- Codex 专用入口现在会默认尝试停止 `codex` 进程，以减少 Windows 下因 `codex.exe` 被占用导致的 `EPERM` / `unlink` 升级失败。
- 同步更新 README，对默认行为和 `-SkipProcessStop` 的适用场景做出说明。

## 1.0.1

- 新增对 `%USERPROFILE%\.codex\.tmp` 的顺手清理，仅在目标为 Codex 时生效。
- 修正版本检查逻辑：当 `PATH` 中未直接解析到命令时，会回退到 npm 全局命令目录继续检测。
- 调整日志文案，避免把“PATH 未命中但实际可执行”的情况误记为命令缺失。

## 1.0.0

- 首个公开整理版。
- 提供 `clean-codex-update.cmd` 作为 Codex 专用入口。
- 提供 `clean-npm-cli-update.cmd` 作为通用交互入口。
- 提供 `tools.json` 维护已知工具清单。
- 主菜单仅显示 npm 安装、支持清理且当前可执行的工具。
- 状态页区分已检测、支持清理、可执行和安装来源。
- 增加手动模式的删除范围保护，仅允许在 npm 全局目录内执行目标清理。
