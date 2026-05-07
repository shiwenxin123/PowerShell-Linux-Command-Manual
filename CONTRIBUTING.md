# 贡献指南

感谢你愿意完善这个命令手册。这个项目的目标是: 让中文用户能快速、准确、安全地查到 PowerShell、Linux、银河麒麟和统信 UOS 的常用命令。

## 可以贡献什么

- 补充缺失命令
- 修正错误命令或过时参数
- 增加真实运维场景示例
- 增加 PowerShell 与 Linux 对照
- 标注高危命令和替代方案
- 改进排版、目录和可读性

## 贡献一个故障案例

故障案例建议放在 `docs/cases/`，文件名使用英文大写短横线，例如 `GATEWAY-TIMEOUT.md`。

推荐结构:

````markdown
# 案例标题

## 现象

描述用户能看到的报错、告警或异常表现。

## 快速判断

```bash
# 只放低风险的只读检查命令
command --check
```

## 排查命令

按网络、进程、日志、配置等维度列出命令。

## 处理建议

说明修复方向，涉及生产变更时要提醒备份、回滚和审批。

## 高危提醒

- 不放真实 IP、密码、Token、内网域名。
- 删除、重启、格式化、权限递归修改等命令必须标注风险。
````

## 命令条目建议格式

````markdown
### 场景名称

```bash
# 简短说明
command --option value
```

说明:
- 适用系统: Linux / PowerShell / 银河麒麟 / 统信 UOS
- 风险等级: 低 / 中 / 高
- 常见错误: 可选
````

## 提交前检查

- 命令可以在对应系统上执行，或者注明版本限制。
- 高危命令必须写清楚风险。
- 不提交真实服务器 IP、账号、密码、Token、内网域名等敏感信息。
- Markdown 表格和代码块可以正常渲染。
- 中文标点和英文命令之间尽量留一个空格。

## Issue 建议

提交问题时请尽量包含:

- 操作系统和版本
- 命令原文
- 报错信息
- 你期望的结果
- 你认为应该如何修改

## Pull Request 建议

PR 标题建议使用:

- `docs: add Linux log commands`
- `fix: correct PowerShell service example`
- `docs: add UOS package management notes`

小而清晰的 PR 更容易被 review 和合并。
