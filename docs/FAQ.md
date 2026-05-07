# FAQ

## 这个项目适合谁使用？

适合正在学习 PowerShell 或 Linux 的用户，也适合需要维护 Windows、Linux、银河麒麟、统信 UOS、Docker、Kubernetes 和常见中间件的开发者、运维人员和值班团队。

如果只是临时查命令，可以从 [命令索引](COMMAND-INDEX.md) 或 [命令速查表](COMMAND-CHEATSHEET.md) 开始。如果要系统学习，建议从 [专题化手册](manual/README.md) 进入。

## 应该先看主手册还是专题页？

优先看专题页。专题页已经按 PowerShell、Linux、国产 Linux、安全、容器、数据库、监控和故障案例拆分，阅读和维护都更清晰。

根目录主手册仍保留完整历史内容，后续会继续收口为总目录和历史说明。

## 怎么快速找到某个命令？

推荐顺序：

1. 在 GitHub 或文档站搜索命令名。
2. 查 [命令索引](COMMAND-INDEX.md)。
3. 查 [命令覆盖矩阵](COMMAND-COVERAGE-MATRIX.md)，确认该领域是否已经覆盖。
4. 如果是故障场景，优先看 [真实故障案例库](cases/README.md) 和 [常见报错排查](troubleshooting/COMMON-ERRORS.md)。

## 文档里的命令可以直接复制执行吗？

不要无脑复制执行。涉及删除、格式化、权限递归修改、服务重启、防火墙、磁盘、用户和证书的命令，都应该先确认目标环境、路径、备份和回滚方式。

高风险命令建议先阅读 [命令风险等级说明](security/RISK-LEVELS.md)。

## Linux 和 Windows 巡检脚本能做什么？

巡检脚本用于快速收集系统、磁盘、网络、服务和进程信息。脚本支持 `text`、`markdown` 和 `json` 输出，适合终端查看、工单粘贴和自动化平台消费。

详细用法见 [巡检脚本工具化](manual/automation/HEALTH-CHECK-SCRIPTS.md)。JSON 输出字段契约见 [Health Check Report JSON Schema](schema/health-check-report.schema.json)。

## 生成的巡检报告可以直接公开吗？

不建议直接公开。巡检报告可能包含主机名、IP、端口、进程名、服务名、磁盘路径等信息。公开分享前应先脱敏。

项目中的 [Linux JSON 示例](examples/linux-health-check.sample.json) 和 [Windows JSON 示例](examples/windows-health-check.sample.json) 已使用示例化内容。

## 如何贡献内容？

可以补命令、修正文档、增加故障案例、扩展脚本模块或完善风险说明。提交前请阅读 [贡献指南](https://github.com/shiwenxin123/PowerShell-Linux-/blob/main/CONTRIBUTING.md)。

建议优先贡献小而清晰的内容，例如：

- 补充一个命令的常见用法。
- 增加一个真实故障案例。
- 给高危命令补充风险提示。
- 修复错别字、断链或过时参数。

## 维护者发布前应该检查什么？

发布前建议按 [Release 检查清单](RELEASE-CHECKLIST.md) 执行，至少确认：

- 文档检查通过。
- MkDocs 严格构建通过。
- 新增链接没有断链。
- 新增脚本通过对应 CI。
- `CHANGELOG.md` 已记录变更。

## GitHub Pages 文档站如何更新？

推送到 `main` 或 `master` 后，会触发 Docs Site 工作流。工作流会安装 `requirements.txt` 中的依赖并执行 `mkdocs build --strict`，然后部署到 GitHub Pages。

如果 Pages 构建失败，优先检查 `mkdocs.yml` 导航路径、Markdown 代码块闭合、文件名大小写和依赖版本范围。
