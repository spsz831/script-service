# npm-cli-clean

用于清理 Windows 上通过 `npm -g` 安装的 CLI 工具在升级后留下的常见残留，默认兼容 Codex，也可以处理其他 npm 全局 CLI。

Version: `1.0.0`

## 文件说明

- `clean-npm-cli-update.ps1`
  通用主脚本。支持指定 npm 包名、命令名、进程名和临时目录匹配规则。

- `clean-npm-cli-update.cmd`
  通用双击启动器。双击时会自动检测当前电脑上已安装的候选 CLI，并提供交互式选择；也支持手动传参运行。

- `clean-codex-update.cmd`
  Codex 专用入口。内部会自动带上 Codex 的默认参数，适合直接双击使用。

- `tools.json`
  已知工具清单配置。后续新增、删除或调整工具规则，优先改这个文件，不需要直接改主脚本。

- `VERSION`
  当前版本号。

- `CHANGELOG.md`
  版本变更记录。

- `LICENSE`
  开源许可证。

- `logs/`
  日志目录。默认仅保留最近 3 份 `cleanup_*.log`。

## 解决什么问题

适合处理这类情况：

- `npm install -g` 升级 CLI 后提示 `cleanup failed`
- Windows 报 `EPERM`、`unlink xxx.exe`
- 全局安装目录下残留临时目录
- 想在清理后顺手检查版本或重装目标 CLI

## 默认支持的目标

当前默认参数面向 Codex：

- 包名：`@openai/codex`
- 命令名：`codex`
- 进程名：`codex`
- 临时目录匹配：`.codex-*`

直接双击 `clean-codex-update.cmd` 即可使用这套默认值。

## 也可以处理其他 npm 全局 CLI

例如：

```bat
clean-npm-cli-update.cmd -PackageName vercel -CommandName vercel -ProcessName vercel
```

```bat
clean-npm-cli-update.cmd -PackageName eslint -CommandName eslint -ProcessName eslint -SkipProcessStop
```

```bat
clean-npm-cli-update.cmd -PackageName @openai/codex -CommandName codex -ProcessName codex -TempDirPattern .codex-*
```

说明：

- `PackageName`
  npm 全局包名，例如 `vercel`、`eslint`、`@openai/codex`

- `CommandName`
  终端里实际执行的命令名

- `ProcessName`
  需要停止的进程名。通常与命令名一致

- `TempDirPattern`
  需要清理的临时目录匹配规则

## 推荐用法

### Codex 常用方式

```bat
clean-codex-update.cmd -SkipCacheClean
```

如果只是先预览：

```bat
clean-codex-update.cmd -WhatIf -SkipCacheClean
```

### 通用 CLI 方式

直接双击：

```bat
clean-npm-cli-update.cmd
```

脚本会：

1. 自动检测当前电脑中已安装的候选 CLI
2. 只把“已检测到且支持清理”的工具列入主菜单
3. 提供“查看所有已知工具状态”和“手动输入其他 CLI”
4. 主菜单仅显示 npm 安装、支持清理且当前可执行的工具

如果你已经明确知道目标，也可以直接带参数运行：

```bat
clean-npm-cli-update.cmd -PackageName vercel -CommandName vercel -ProcessName vercel -SkipCacheClean
```

### 清理后顺手重装

```bat
clean-npm-cli-update.cmd -PackageName @openai/codex -CommandName codex -ProcessName codex -TempDirPattern .codex-* -Reinstall
```

## 参数说明

- `-PackageName`
  目标 npm 全局包名。默认值是 `@openai/codex`。

- `-CommandName`
  目标命令名。默认值是 `codex`。

- `-ProcessName`
  目标进程名。默认值是 `codex`。

- `-TempDirPattern`
  要删除的临时目录匹配规则。默认值是 `.codex-*`。

- `-VersionArgs`
  版本检查参数。默认是 `--version`。

- `-WhatIf`
  预览模式。不真正执行删除、停止进程或 npm 命令。

- `-SkipCacheClean`
  跳过 `npm cache clean --force`。

- `-Reinstall`
  清理后重新安装目标 npm 包。

- `-SkipProcessStop`
  跳过停止目标进程。

## 输出说明

脚本运行时会显示：

- `[检查]`
  环境自检和当前目标信息

- `[1/6]` 到 `[6/6]`
  实际执行步骤

- `[info]`
  关键结果说明

- `[warn]`
  警告信息

- `[success]`
  清理成功完成

- `[failed]`
  清理失败

通用入口在未传核心参数时，还会先显示交互菜单，供你选择目标工具。

## 兼容性说明

这套脚本适用于大多数正常配置的 Windows 电脑，但前提是目标机器满足：

- 已安装 Node.js / npm
- `npm` 在 `PATH` 中
- 系统可用 `powershell` 或 `pwsh`
- 如果要检查版本或重装，目标命令最好也在 `PATH` 中

如果删除失败、重装失败、或 npm 全局目录没有写权限，优先尝试以管理员身份运行。

## 安全边界

- 主菜单只对 `npm` 安装来源的工具提供自动清理入口。
- 手动输入模式下，删除操作仍会被限制在 `npm root -g` 范围内。
- 如果计算出的搜索路径超出 npm 全局目录，脚本会拒绝执行删除。
- 第一次使用建议先跑 `-WhatIf` 预览。

## 不会清理的内容

这个工具不是卸载器，也不是全盘清理工具。它不会删除：

- 你的项目代码
- 用户目录下与 CLI 无关的配置
- 其他不相关的 npm 包
- 非 npm 包管理器安装的工具

## 当前建议

如果你的目标还是 Codex，优先使用：

```bat
clean-codex-update.cmd -SkipCacheClean
```

如果你要处理其他 npm 全局 CLI，再改用：

```bat
clean-npm-cli-update.cmd -PackageName <包名> -CommandName <命令名> -ProcessName <进程名>
```
