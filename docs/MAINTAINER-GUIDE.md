# 维护者指南

这份文档用于帮助项目维护者持续运营仓库，让项目保持可读、可贡献、可发布。

## 每次更新前

- 确认新增命令适用平台和版本。
- 高危命令必须补充风险说明。
- 示例中不要包含真实 IP、密码、Token、内网域名。
- 大专题优先放入 `docs/`，不要继续堆到 README。

## 推荐发布流程

1. 更新文档或脚本。
2. 更新 `CHANGELOG.md`。
3. 检查 README 快速入口是否需要新增链接。
4. 检查 `mkdocs.yml` 是否需要加入导航。
5. 本地执行 `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-docs.ps1`。
6. 本地执行 `python -m mkdocs build --strict`。
7. 如更新巡检脚本，确认 GitHub Actions 中的 Script Quality 工作流通过。
8. 提交 PR 或直接合并。
9. 发布 GitHub Release。

## 依赖维护

- `requirements.txt` 使用版本范围，避免 MkDocs 或主题大版本升级导致文档站突然构建失败。
- 升级 MkDocs、Material for MkDocs 或 `pymdown-extensions` 前，先在分支中执行 `python -m mkdocs build --strict`。
- 如果上游发布大版本，优先阅读迁移说明，再调整 `requirements.txt` 的版本范围。
- 不建议在没有构建验证的情况下放宽到无限制版本。

## Release 标题建议

- `v2.2.0 - 新增命令索引与故障排查专题`
- `v2.3.0 - 新增国产 Linux 运维专题`
- `v2.4.0 - 新增 Docker 与 Kubernetes 速查`

## 首批可创建的 Issues

这些 Issue 可以帮助项目显得活跃，也方便其他人参与。更完整的候选任务见 [Good First Issues 清单](GOOD-FIRST-ISSUES.md)。

| 标题 | 标签 |
| --- | --- |
| 补充网关超时排查案例 | `documentation`, `troubleshooting`, `good first issue` |
| 补充消息队列连接失败案例 | `documentation`, `middleware`, `help wanted` |
| 补充数据库连接池耗尽案例 | `documentation`, `database`, `help wanted` |
| 补充云负载均衡健康检查失败案例 | `documentation`, `cloud`, `good first issue` |
| 补充 Prometheus 告警规则误报案例 | `documentation`, `observability`, `good first issue` |
| 为巡检脚本增加 package 模块 | `script`, `linux`, `windows`, `help wanted` |
| 为巡检脚本增加 security 模块 | `script`, `security`, `help wanted` |
| 为巡检脚本增加 container 模块 | `script`, `container`, `help wanted` |
| 补充 Kylin/UOS 不同版本命令差异 | `documentation`, `kylin`, `uos`, `good first issue` |
| 将主手册附录整理为专题入口 | `documentation`, `manual-migration`, `good first issue` |

## README 维护原则

- README 只放项目定位、快速入口、路线图摘要和贡献入口。
- 具体命令放到 `docs/`。
- 新增专题后，同步更新 README、`docs/index.md`、`mkdocs.yml`。

## 文档站维护

GitHub Pages 推荐统一使用 `.github/workflows/docs-site.yml` 发布。推送到 `main` 或手动触发 Docs Site 工作流后，会执行 `mkdocs build --strict` 并部署到 Pages。

如果仓库曾使用 `gh-pages` 分支发布，建议在 GitHub Pages 设置中统一选择 GitHub Actions 作为发布来源，避免同时维护两套发布方式。

如果构建失败，优先检查:

- `mkdocs.yml` 导航路径是否存在。
- Markdown 代码块是否闭合。
- 文件名大小写是否与导航一致。
