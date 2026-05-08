# Good First Issues 清单

这份清单用于维护者批量创建适合新贡献者参与的 GitHub Issues。每个 Issue 都应尽量小、边界清晰，并附上建议修改位置。

## 文档类

| Issue 标题 | 建议标签 | 建议修改位置 |
| --- | --- | --- |
| 补充网关超时排查案例 | `documentation`, `troubleshooting`, `good first issue` | `docs/cases/` |
| 补充云负载均衡健康检查失败案例 | `documentation`, `cloud`, `good first issue` | `docs/cases/` |
| 补充 Kylin/UOS 不同版本命令差异 | `documentation`, `kylin`, `uos`, `good first issue` | `docs/domestic-linux/` |
| 补充国产 Linux 离线源目录示例 | `documentation`, `kylin`, `uos`, `good first issue` | `docs/domestic-linux/` |
| 给路线页补充初学者常见误区 | `documentation`, `good first issue` | `docs/routes/` |

## 脚本类

| Issue 标题 | 建议标签 | 建议修改位置 |
| --- | --- | --- |
| 为巡检脚本增加 package 模块 | `script`, `linux`, `windows`, `help wanted` | `scripts/`、`docs/manual/automation/` |
| 为巡检脚本增加 security 模块 | `script`, `security`, `help wanted` | `scripts/`、`docs/manual/automation/` |
| 为巡检脚本增加 container 模块 | `script`, `container`, `help wanted` | `scripts/`、`docs/manual/automation/` |
| 为巡检脚本增加 log 模块 | `script`, `linux`, `windows`, `help wanted` | `scripts/`、`docs/manual/automation/` |
| 为巡检脚本新增模块补示例报告 | `documentation`, `script`, `good first issue` | `docs/examples/`、`docs/manual/automation/` |

## 生产案例类

| Issue 标题 | 建议标签 | 建议修改位置 |
| --- | --- | --- |
| 补充消息队列连接失败排查案例 | `documentation`, `middleware`, `help wanted` | `docs/cases/` |
| 补充数据库连接池耗尽排查案例 | `documentation`, `database`, `help wanted` | `docs/cases/` |
| 补充 Prometheus 告警规则误报案例 | `documentation`, `observability`, `good first issue` | `docs/cases/` |

## Issue 描述模板

```markdown
## 背景

当前项目已经有相关专题，但缺少这个具体场景。

## 建议修改

- 新增或更新文档位置:
- 建议结构: 现象 -> 快速判断 -> 排查命令 -> 常见原因 -> 处理建议 -> 高危提醒 -> 相关专题

## 验收标准

- 文档链接没有断链
- 命令不包含真实 IP、密码、Token
- 高危操作有提醒
- `scripts/check-docs.ps1` 通过
```
