# npm-cli-clean

用于清理 Windows 上通过 `npm -g` 安装的 CLI 工具在升级后留下的常见残留，默认兼容 Codex，也可以处理其他 npm 全局 CLI。

Version: `1.0.0`

## 概览

| 项目 | 说明 |
|---|---|
| 适用平台 | Windows |
| 主要用途 | 清理 npm 全局 CLI 升级残留 |
| 默认目标 | `@openai/codex` / `codex` |
| 通用入口 | `clean-npm-cli-update.cmd` |
| Codex 专用入口 | `clean-codex-update.cmd` |
| 核心脚本 | `clean-npm-cli-update.ps1` |
| 配置文件 | `tools.json` |

## 快速开始

| 场景 | 命令 / 入口 |
|---|---|
| 直接清理 Codex | `clean-codex-update.cmd` |
| 更稳妥的 Codex 常用方式 | `clean-codex-update.cmd -SkipCacheClean` |
| 预览 Codex 清理 | `clean-codex-update.cmd -WhatIf -SkipCacheClean` |
| 打开通用交互菜单 | `clean-npm-cli-update.cmd` |
| 明确指定通用目标 | `clean-npm-cli-update.cmd -PackageName vercel -CommandName vercel -ProcessName vercel -SkipCacheClean` |

## 适用场景

| 场景 | 说明 |
|---|---|
| `npm install -g` 升级失败 | 清理升级后的临时残留目录 |
| Windows `EPERM` / `unlink` 报错 | 处理被占用或未清理干净的 CLI 文件 |
| 全局 npm 目录有 `.xxx-*` 残留 | 删除匹配规则下的临时目录 |
| 想顺手检查版本或重装 | 支持版本检查和可选重装 |

## 预览与截图

| 项目 | 说明 |
|---|---|
| 预览命令 | `clean-codex-update.cmd -WhatIf -SkipCacheClean` |
| 建议截图 1 | `docs/main-menu.png` |
| 建议截图 2 | `docs/status-page.png` |
| 建议截图 3 | `docs/codex-clean-result.png` |
| Markdown 示例 | `![Main Menu](docs/main-menu.png)` |

## 文件清单

| 文件 | 作用 |
|---|---|
| `clean-npm-cli-update.ps1` | 通用主脚本，负责检测、清理、版本检查和可选重装 |
| `clean-npm-cli-update.cmd` | 通用双击入口，支持交互菜单和手动传参 |
| `clean-codex-update.cmd` | Codex 专用入口，内置 Codex 默认参数 |
| `tools.json` | 已知工具清单和规则配置 |
| `logs/` | 日志目录，默认仅保留最近 3 份 `cleanup_*.log` |
| `VERSION` | 版本号 |
| `CHANGELOG.md` | 变更记录 |
| `LICENSE` | 许可证 |

## 默认目标

| 参数 | 默认值 |
|---|---|
| 包名 | `@openai/codex` |
| 命令名 | `codex` |
| 进程名 | `codex` |
| 临时目录匹配 | `.codex-*` |

直接双击 `clean-codex-update.cmd` 即可使用这套默认值。

## 菜单规则

| 条件 | 说明 |
|---|---|
| 已检测到 | 本机能检测到命令或配置痕迹 |
| 安装来源为 `npm` | 非 `npm` 安装来源只放状态页 |
| 具备清理规则 | 在 `tools.json` 中已定义处理规则 |
| 当前命令可执行 | 命令在 `PATH` 中可运行 |

| 状态页字段 | 作用 |
|---|---|
| 是否已检测到 | 判断本机是否存在该工具 |
| 是否支持清理 | 判断是否有自动清理规则 |
| 是否当前可执行 | 判断命令是否能直接运行 |
| 安装来源 | 判断是 `npm`、`non-npm` 还是 `unknown` |

## 通用 CLI 用法

| 示例场景 | 命令 |
|---|---|
| Vercel CLI | `clean-npm-cli-update.cmd -PackageName vercel -CommandName vercel -ProcessName vercel` |
| ESLint CLI | `clean-npm-cli-update.cmd -PackageName eslint -CommandName eslint -ProcessName eslint -SkipProcessStop` |
| 手动指定 Codex 规则 | `clean-npm-cli-update.cmd -PackageName @openai/codex -CommandName codex -ProcessName codex -TempDirPattern .codex-*` |

| 字段 | 说明 |
|---|---|
| `PackageName` | npm 全局包名，例如 `vercel`、`eslint`、`@openai/codex` |
| `CommandName` | 终端里实际执行的命令名 |
| `ProcessName` | 需要停止的进程名，通常与命令名一致 |
| `TempDirPattern` | 需要清理的临时目录匹配规则 |

## 推荐用法

| 场景 | 推荐命令 |
|---|---|
| Codex 常用方式 | `clean-codex-update.cmd -SkipCacheClean` |
| Codex 预览 | `clean-codex-update.cmd -WhatIf -SkipCacheClean` |
| 通用交互菜单 | `clean-npm-cli-update.cmd` |
| 指定通用目标 | `clean-npm-cli-update.cmd -PackageName vercel -CommandName vercel -ProcessName vercel -SkipCacheClean` |
| 清理后顺手重装 | `clean-npm-cli-update.cmd -PackageName @openai/codex -CommandName codex -ProcessName codex -TempDirPattern .codex-* -Reinstall` |

## 参数说明

| 参数 | 说明 |
|---|---|
| `-PackageName` | 目标 npm 全局包名，默认 `@openai/codex` |
| `-CommandName` | 目标命令名，默认 `codex` |
| `-ProcessName` | 目标进程名，默认 `codex` |
| `-TempDirPattern` | 临时目录匹配规则，默认 `.codex-*` |
| `-VersionArgs` | 版本检查参数，默认 `--version` |
| `-WhatIf` | 预览模式，不真正执行删除、停止进程或 npm 命令 |
| `-SkipCacheClean` | 跳过 `npm cache clean --force` |
| `-Reinstall` | 清理后重新安装目标 npm 包 |
| `-SkipProcessStop` | 跳过停止目标进程 |

## 输出说明

| 标记 | 说明 |
|---|---|
| `[检查]` | 环境自检和当前目标信息 |
| `[1/6]` 到 `[6/6]` | 实际执行步骤 |
| `[info]` | 关键结果说明 |
| `[warn]` | 警告信息 |
| `[success]` | 清理成功完成 |
| `[failed]` | 清理失败 |

| 触发方式 | 行为 |
|---|---|
| 未传核心参数 | 通用入口先显示交互菜单 |
| 双击 Codex 入口 | 直接按 Codex 默认规则执行 |

## 兼容性

| 条件 | 说明 |
|---|---|
| 已安装 Node.js / npm | 必需 |
| `npm` 在 `PATH` 中 | 必需 |
| 系统可用 `powershell` 或 `pwsh` | 必需 |
| 目标命令在 `PATH` 中 | 建议，影响版本检查与主菜单可执行判定 |

如果删除失败、重装失败、或 npm 全局目录没有写权限，优先尝试以管理员身份运行。

## 安全边界

| 项目 | 说明 |
|---|---|
| 主菜单范围 | 仅对 `npm` 安装来源的工具提供自动清理入口 |
| 手动输入模式 | 删除操作仍限制在 `npm root -g` 范围内 |
| 路径保护 | 搜索路径超出 npm 全局目录时拒绝执行删除 |
| 使用建议 | 第一次使用建议先跑 `-WhatIf` 预览 |

## 不处理范围

| 不会清理的内容 | 说明 |
|---|---|
| 你的项目代码 | 不在清理范围内 |
| 用户目录下与 CLI 无关的配置 | 不处理 |
| 其他不相关的 npm 包 | 不处理 |
| 非 npm 包管理器安装的工具 | 仅检测，不自动清理 |

## 当前建议

| 目标 | 建议 |
|---|---|
| 主要清理 Codex | 优先用 `clean-codex-update.cmd -SkipCacheClean` |
| 先确认风险 | 先用 `-WhatIf` 预览 |
| 清理其他 npm CLI | 用 `clean-npm-cli-update.cmd -PackageName <包名> -CommandName <命令名> -ProcessName <进程名>` |
