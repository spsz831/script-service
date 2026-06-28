# Changelog

## 1.2.2

- 调整 `open-port-killer.cmd` 为循环式交互：查完一个端口后可继续查询下一个端口，不再正常执行后立即关闭窗口。
- README 同步补充双击入口支持连续查询的说明。

## 1.2.1

- 调整 `open-port-killer.cmd`：双击后先列出当前 LISTENING TCP 端口、PID 和进程名，再提示输入要检查的端口号。
- README 同步补充双击入口的新交互方式。

## 1.2.0

- 重构输出：为活进程和 zombie socket 统一输出 `Port`、`State`、`Id` 和 `Recommendation` 等字段。
- 增加按进程类型生成的风险提示，帮助区分开发服务、编辑器辅助进程、本地模型服务和系统进程。
- `-Kill` 模式下明确提示 zombie socket 不会被触碰，并在无可杀活进程时给出更清楚的反馈。
- 新增 `port-killer/.gitignore`，默认忽略本机端口状态快照和 `.bak` 备份文件，避免把个人排障残留提交到仓库。

## 1.1.0

- 新增 `-IncludeZombie` 参数：通过 `netstat -ano` 检测 zombie socket（进程已死但 socket 被内核持有的情况）
- 向后兼容：不传 `-IncludeZombie` 时行为与 1.0.0 完全一致
- Zombie 检测会标记 `State=ZOMBIE` 并提示"需重启 Windows 才能释放"
- 由 Claude (spsz0) 于 2026-06-22 实现，灵感来自 claude-mem 13.7.0 反复遇到的端口占用问题

## 1.0.0

- 首个整理版。
- 支持查询 TCP 端口占用进程。
- 支持按参数结束占用进程。
