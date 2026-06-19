# CONTRIBUTING

欢迎为 `script-service` 提交脚本、修复、文档或截图改进。

这个仓库不是大而全的代码集合，更偏向“可复用、可理解、可单独运行”的脚本目录集合。所以贡献时最重要的不是数量，而是边界清楚、文档完整、行为可验证。

## 先看什么

| 文档 | 作用 |
|---|---|
| [README.md](README.md) | 了解仓库结构、项目清单、依赖、状态和入口 |
| [RELEASE_GUIDE.md](RELEASE_GUIDE.md) | 了解发布、截图、目录结构和维护流程 |

## 适合提交什么

| 类型 | 说明 |
|---|---|
| 新脚本 | 解决一个明确、独立、可复用的问题 |
| 脚本修复 | 修复 bug、提升兼容性、减少误删或误操作风险 |
| 文档改进 | 修正 README、参数说明、依赖说明、维护说明 |
| 预览图改进 | 补充或更新更准确的脚本展示图 |
| 结构整理 | 在不破坏行为的前提下，提升项目清晰度和维护性 |

## 不建议的贡献方式

| 情况 | 原因 |
|---|---|
| 一个脚本里混入多个不相关功能 | 会让目录边界越来越模糊 |
| 没验证就直接改 README 结论 | 容易把猜测写成事实 |
| 提交个人环境残留、测试垃圾、日志、临时文件 | 会污染仓库 |
| 为了“更强大”引入很重的依赖 | 不符合当前仓库偏简单、低耦合的方向 |
| 修改高风险删除逻辑但没有最小验证 | 风险过高 |

## 新增脚本时的最低要求

| 项目 | 要求 |
|---|---|
| 目录独立 | 一个脚本项目一个目录 |
| 主脚本 | 必须有可读、可运行的主脚本文件 |
| README | 必须说明用途、参数、依赖、风险边界 |
| VERSION | 建议补齐 |
| CHANGELOG | 建议补齐 |
| LICENSE | 建议补齐 |
| docs | 如有展示价值，建议补 `docs/` |
| 最小验证 | 至少说明你如何验证脚本能工作 |

## 推荐目录结构

```text
your-script/
  README.md
  VERSION
  CHANGELOG.md
  LICENSE
  docs/
  your-script.ps1
  open-your-script.cmd
```

## 文档要求

| 项目 | 要求 |
|---|---|
| 语言 | 中文优先 |
| 结构 | 尽量保持现有表格化 README 风格 |
| 结论 | 区分已验证、依赖外部工具、待补充 |
| 参数 | 写清必填、可选、默认值和风险影响 |
| 入口 | 如支持双击，写清 `.cmd` 入口；如仅命令行，给最小示例 |

## 提交前建议自检

```powershell
git status --short
git diff --stat
```

如果改了预览图或首页展示，也建议再跑一次：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\generate-readme-previews.ps1
```

## Pull Request 建议

| 项目 | 建议 |
|---|---|
| 改动范围 | 一个 PR 尽量只解决一类问题 |
| 说明方式 | 写清为什么改、改了什么、怎么验证 |
| 风险说明 | 如果改动涉及删除、清理、进程结束、缓存处理，必须说明风险边界 |
| 截图 | 如果改了菜单、输出样式、README 展示图，建议附图 |

## 提交信息建议

| 类型 | 示例 |
|---|---|
| `feat` | `feat: add folder diff helper` |
| `fix` | `fix: guard cleanup path traversal` |
| `docs` | `docs: refine project README tables` |
| `chore` | `chore: normalize repository structure` |

## 最重要的原则

| 原则 | 说明 |
|---|---|
| 先可用 | 先证明脚本可用，再谈包装 |
| 先清楚 | 目录边界、README、参数说明要足够清楚 |
| 先验证 | 未验证行为不要写成“已支持” |
| 先克制 | 不为了一点便利引入过重复杂度 |
