# npm-cli-clean

Windows 下专门用于清理和修复 `@openai/codex` 全局安装残留的脚本。

Version: `2.9.1`

## 当前定位

这个目录现在只服务一个场景：Codex CLI 升级或重装过程中，`npm` 在 Windows 全局命令目录里留下 `.codex*` 临时残骸，导致 `codex` 命令失效、升级反复卡住、或 shim 未重建完成。

同时覆盖另一类常见异常：`@openai/codex` 主包存在，但 Windows 平台依赖 `@openai/codex-win32-x64` 缺失，导致启动时报：

```text
Missing optional dependency @openai/codex-win32-x64
```

不再维护“通用 npm CLI 清理器”能力，也不再尝试覆盖其他 CLI 的安装形态。

## 保留文件

| 文件 | 作用 |
|---|---|
| `clean-codex.cmd` | 唯一入口，适合双击或终端直接运行 |
| `clean-codex-cli.ps1` | 主脚本，执行 Codex 清理与可选重装 |
| `VERSION` | 版本号 |
| `README.md` | 当前使用说明 |

## 解决的问题

| 场景 | 说明 |
|---|---|
| `codex` 命令突然不存在 | `%APPDATA%\npm` 中正式 shim 丢失，只剩 `.codex*` 残留 |
| `npm install -g @openai/codex` 后卡住 | Windows 下更新被中断或全局入口替换不完整 |
| 升级后反复报错 | 旧残留未清理，重装没有真正重建入口 |
| `Missing optional dependency @openai/codex-win32-x64` | 主包在，但 Windows 平台子包缺失 |
| 想安全地一键修复 | 用固定 Codex 规则执行清理与可选重装 |

## 当前诊断输出

脚本开头会先输出状态分类，便于快速判断故障类型。控制台现在采用中文主导输出，同时保留英文状态码，方便人工判断和脚本解析：

| 分类 | 含义 |
|---|---|
| `healthy` | 健康：未发现 shim 异常或 win32 子包缺失 |
| `shim-missing` | shim 缺失：当前未检测到可执行的 `codex` 命令 |
| `shim-residue` | shim 残留：检测到 `.codex*` 临时残留 |
| `win32-missing` | win32 子包缺失：`@openai/codex-win32-x64` 缺失 |

控制台输出会显示类似下面的格式：

```text
[诊断] 状态分类: 健康 (healthy)
[诊断] 推荐动作: 无需修复 (none)
[verify] 版本状态: 已是最新 (up-to-date)
```

运行时会自动创建 `logs/` 目录并写入日志；目录本身不再作为固定仓库文件保留。

除文本日志外，每次运行还会额外生成一个 `summary_*.json` 摘要文件，记录：

1. 运行模式
2. 状态分类
3. 推荐动作
4. 实际动作
5. 执行结果
6. 关键路径状态
7. win32 平台依赖状态

每次运行结束时，脚本还会在控制台和文本日志里输出一段 `takeaway`，用于沉淀本次结论：

1. 故障分类
2. 推荐动作
3. 实际动作
4. 网络状态
5. 版本状态
6. 下次建议

在真正执行清理或重装前，还会生成一个 `snapshot_*.json` 修复前快照，记录：

1. 修复前 `codex --version`
2. 修复前 `where codex`
3. 修复前 `npm list -g @openai/codex --depth=0`
4. `%APPDATA%\npm` 下 `codex*` / `.codex*` 文件清单

## 用法

### 命令层入口

`clean-codex.cmd` 现在不仅是参数透传壳，也提供清晰的入口模式：

1. 无参数：默认轻清理
2. `-Verify`：只验证
3. `-AutoFix`：自动修复
4. `-Reinstall`：当前窗口重装
5. `-LaunchReinstall`：新窗口重装
6. `-Help` / `--help` / `/?`：显示帮助

### 日常清理

```powershell
.\clean-codex.cmd
```

默认行为：

1. 停止 `codex` 相关进程
2. 校验 npm 缓存
3. 跳过 `npm cache clean`（入口默认带 `-SkipCacheClean`）
4. 清理 `%APPDATA%\npm` 下 `.codex*` 残留
5. 清理 `%USERPROFILE%\.codex\.tmp` 白名单项
6. 检查当前 `codex --version`

### 只验证，不修复

```powershell
.\clean-codex.cmd -Verify
```

这个模式只做检查，不执行：

1. 不停止 `codex` 进程
2. 不清理 npm 缓存
3. 不删除 `.codex*` 残留
4. 不重装 Codex

它会输出当前状态分类，以及一组固定检查项：

1. `npm` 命令路径
2. `npm root -g` 和 npm 全局命令目录
3. `codex` 包目录
4. `Get-Command codex` / `where codex`
5. `codex`、`codex.cmd`、`codex.ps1` 是否存在
6. `npm list -g @openai/codex --depth=0`
7. `@openai/codex-win32-x64` 是否存在
8. `.codex*` 残留数量和明细
9. 当前 `codex --version`
10. `npm registry`、`HTTP_PROXY` / `HTTPS_PROXY`
11. `npm view @openai/codex version` 是否可达
12. 本地版本与 registry 最新版本是否一致

这样可以区分：

1. 本地安装损坏
2. 只是 shim 残留
3. 只是 win32 子包缺失
4. registry / 代理链路有问题
5. 当前健康但可升级

### 清理后强制重装

```powershell
.\clean-codex.cmd -Reinstall
```

重装会执行：

```powershell
npm install -g @openai/codex@latest --force
```

这个模式适合修复 `codex.cmd` / `codex.ps1` 丢失，或者 `shim` 重建失败的场景。

如果只是缺 `@openai/codex-win32-x64`，脚本会优先选择普通重装；只有检测到 shim 异常时，才会改用 `--force`。

如果当前脚本运行在正在使用的 Codex 会话里，`-Reinstall` 会被拒绝执行，并提示你去新开的 PowerShell 窗口里重装，避免“重装自己导致当前会话退出”。

### 自动按推荐策略修复

```powershell
.\clean-codex.cmd -AutoFix
```

`-AutoFix` 会根据当前状态自动选择动作：

1. `healthy`：不修复
2. `shim-missing`：强制重装
3. `shim-residue`：强制重装
4. `win32-missing`：普通重装

如果当前在 Codex 会话内执行，`-AutoFix` 也会被拒绝，并提示去新开的 PowerShell 窗口里运行。

### 自动开新窗口重装

```powershell
.\clean-codex.cmd -LaunchReinstall
```

这个模式不会在当前窗口里直接重装，而是启动一个新的 PowerShell 窗口，并在新窗口中执行：

```powershell
.\clean-codex.cmd -Reinstall
```

适合当前正处于 Codex 会话中、又需要安全重装 Codex 本体的场景。

### 预览模式

```powershell
powershell -ExecutionPolicy Bypass -File .\clean-codex-cli.ps1 -WhatIf
```

### 可选参数

| 参数 | 说明 |
|---|---|
| `-Reinstall` | 清理后强制重装 Codex |
| `-LaunchReinstall` | 在新 PowerShell 窗口中启动重装 |
| `-AutoFix` | 按当前诊断结果自动选择修复动作 |
| `-Verify` | 只验证当前状态，不执行清理或重装 |
| `-SkipCacheClean` | 跳过 `npm cache clean --force` |
| `-SkipProcessStop` | 跳过停止 `codex` 进程 |
| `-LogKeep 10` | 日志保留数量 |
| `-WhatIf` | 只预览，不真正删除或执行重装 |

## 设计边界

| 项目 | 说明 |
|---|---|
| 删除范围 | 限制在 npm 全局命令目录里的 `.codex*` 残留 |
| 用户目录清理 | 仅处理 `%USERPROFILE%\.codex\.tmp` 白名单项 |
| 不清理内容 | 你的项目代码、其他 npm 包、非 Codex CLI |
| 适用平台 | Windows |

## 建议

如果只是日常修复，直接用 `clean-codex.cmd`。

如果已经出现 `codex` 命令丢失、更新被打断、或正式 shim 没生成，用：

```powershell
.\clean-codex.cmd -Reinstall
```

如果脚本提示当前正在 Codex 会话中，请按提示新开一个 PowerShell 窗口再执行上述命令。
