# Windows PowerShell 与 Linux 常用命令手册

[![Docs Site](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/actions/workflows/docs-site.yml/badge.svg)](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/actions/workflows/docs-site.yml)
[![Markdown Check](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/actions/workflows/markdown-check.yml/badge.svg)](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/actions/workflows/markdown-check.yml)
[![Script Quality](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/actions/workflows/script-quality.yml/badge.svg)](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/actions/workflows/script-quality.yml)
[![Secret Scan](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/actions/workflows/secret-scan.yml/badge.svg)](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/actions/workflows/secret-scan.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

一份面向桌面用户、运维工程师、国产 Linux 使用者和跨平台脚本学习者的命令速查手册。项目覆盖 Windows PowerShell、Linux、银河麒麟、统信 UOS、安全加固和常见自动化场景，适合日常查阅、教学和内部培训。

> 在线文档: [https://shiwenxin123.github.io/PowerShell-Linux-Command-Manual/](https://shiwenxin123.github.io/PowerShell-Linux-Command-Manual/)
> 当前版本: [v2.16.0](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/releases/tag/v2.16.0)
> 历史主手册: [Windows-PowerShell-Linux-Command-Manual.md](Windows-PowerShell-Linux-Command-Manual.md)

## 10 秒了解项目

| 你想做什么 | 直接入口 |
| --- | --- |
| 快速查一条命令 | [命令速查表](docs/COMMAND-CHEATSHEET.md) / [命令索引](docs/COMMAND-INDEX.md) |
| 按故障现象排查 | [真实故障案例库](docs/cases/README.md) |
| 学 PowerShell 与 Linux 对照 | [PowerShell 与 Bash 命令对照](docs/POWERSHELL-BASH-COMPARISON.md) |
| 运维值班快速检查 | [Linux 故障应急排查清单](docs/troubleshooting/LINUX-INCIDENT-CHECKLIST.md) |
| 生成巡检报告 | [巡检脚本工具化](docs/manual/automation/HEALTH-CHECK-SCRIPTS.md) |
| 参与贡献 | [Good First Issues](docs/GOOD-FIRST-ISSUES.md) / [贡献指南](CONTRIBUTING.md) |
| 推广运营 | [开源运营手册](docs/OPEN-SOURCE-OPERATIONS.md) |

## 项目亮点

- **跨平台对照**: 同时整理 PowerShell 与 Linux 常用命令，便于 Windows/Linux 用户互相迁移。
- **国产系统适配**: 包含银河麒麟、统信 UOS 相关命令和运维场景。
- **运维实用导向**: 覆盖文件、进程、服务、网络、日志、安全、脚本自动化等高频工作。
- **中文友好**: 命令说明以中文为主，降低新手和团队培训成本。
- **可自动化消费**: 巡检脚本支持 text、markdown、json 输出，可接入 CI 或二次脚本。

## 快速开始

克隆项目后可以直接查阅 Markdown，也可以运行巡检脚本生成报告。

```bash
git clone https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual.git
cd PowerShell-Linux-Command-Manual
bash scripts/linux-health-check.sh --format markdown --output reports/linux-health-check.md
```

Windows PowerShell:

```powershell
git clone https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual.git
Set-Location PowerShell-Linux-Command-Manual
.\scripts\windows-health-check.ps1 -Format markdown -OutputFile reports\windows-health-check.md
```

如果只想在线阅读，推荐直接打开 [文档站](https://shiwenxin123.github.io/PowerShell-Linux-Command-Manual/)。

## 快速入口

| 需求 | 推荐阅读 |
| --- | --- |
| 常见问题 | [FAQ](docs/FAQ.md) |
| 按命令查找 | [命令索引](docs/COMMAND-INDEX.md) |
| 覆盖面评估 | [命令覆盖矩阵](docs/COMMAND-COVERAGE-MATRIX.md) |
| 快速查命令 | [命令速查表](docs/COMMAND-CHEATSHEET.md) |
| 专题化手册 | [完整手册专题化入口](docs/manual/README.md) |
| 迁移进度 | [主手册迁移进度](docs/MANUAL-MIGRATION.md) |
| 下一阶段 | [下一阶段优化计划](docs/NEXT-STAGE-PLAN.md) |
| Linux 应急排障 | [Linux 故障应急排查清单](docs/troubleshooting/LINUX-INCIDENT-CHECKLIST.md) |
| 真实故障案例 | [真实故障案例库](docs/cases/README.md) |
| 国产 Linux 运维 | [银河麒麟与统信 UOS 常用命令](docs/domestic-linux/KYLIN-UOS-COMMANDS.md) |
| 命令安全 | [命令风险等级说明](docs/security/RISK-LEVELS.md) |
| 发布运营 | [开源运营手册](docs/OPEN-SOURCE-OPERATIONS.md) |
| 项目导航 | [文档站首页](docs/index.md) |

更多专题包括 PowerShell/Bash 对照、Bash 文本处理、Docker/Kubernetes、离线安装、巡检脚本和项目维护内容，请从 [文档站首页](docs/index.md) 进入。

## 学习路线

| 路线 | 建议顺序 |
| --- | --- |
| 新手入门 | [命令速查表](docs/COMMAND-CHEATSHEET.md) -> [PowerShell 基础](docs/manual/powershell/BASIC.md) -> [Linux 基础](docs/manual/linux/BASIC.md) |
| 运维值班 | [Linux 应急排查](docs/troubleshooting/LINUX-INCIDENT-CHECKLIST.md) -> [真实故障案例](docs/cases/README.md) -> [命令风险等级](docs/security/RISK-LEVELS.md) |
| 国产 Linux | [麒麟与 UOS](docs/domestic-linux/KYLIN-UOS-COMMANDS.md) -> [离线安装](docs/domestic-linux/OFFLINE-PACKAGE-GUIDE.md) -> [版本差异](docs/domestic-linux/VERSION-DIFFERENCES.md) |
| 容器/Kubernetes | [Docker/Kubernetes 生产命令](docs/manual/kubernetes/DOCKER-K8S-PRODUCTION.md) -> [Kubernetes 进阶排查](docs/manual/kubernetes/ADVANCED-TROUBLESHOOTING.md) -> [K8s 故障案例](docs/cases/README.md) |
| 脚本自动化 | [Shell 脚本](docs/manual/linux/SHELL-SCRIPTING.md) -> [跨平台脚本](docs/manual/cross-platform/PYTHON-NODE-SCRIPTS.md) -> [巡检脚本工具化](docs/manual/automation/HEALTH-CHECK-SCRIPTS.md) |

## 适合谁

- 刚开始学习 PowerShell 或 Linux 的用户
- 经常在 Windows 和 Linux 之间切换的开发者
- 维护银河麒麟、统信 UOS 等国产系统的运维人员
- 需要整理内部培训资料、应急命令清单或值班手册的团队

## 推荐使用方式

1. 先收藏项目，日常遇到命令时直接搜索关键字。
2. 从 [命令速查表](docs/COMMAND-CHEATSHEET.md) 找到常用命令。
3. 在完整手册里查看更详细示例。
4. 发现遗漏或错误时，通过 Issue 或 Pull Request 补充。

## 按场景找命令

| 场景 | 推荐入口 |
| --- | --- |
| 查端口、连通性、DNS | [Linux 网络排查](docs/manual/linux/NETWORK.md) / [常见报错排查](docs/troubleshooting/COMMON-ERRORS.md) |
| 找大文件、清理磁盘 | [Linux 磁盘与 LVM](docs/manual/linux/DISK-LVM.md) / [磁盘空间满案例](docs/cases/DISK-FULL.md) |
| 看服务和进程状态 | [Linux 基础](docs/manual/linux/BASIC.md) / [Windows 管理命令](docs/manual/windows/ADMIN-COMMANDS.md) |
| 分析日志和审计 | [日志轮转、审计与系统日志](docs/manual/security/LOGGING-AUDIT.md) |
| 排查 Kubernetes | [Kubernetes 进阶排查](docs/manual/kubernetes/ADVANCED-TROUBLESHOOTING.md) / [K8s 案例库](docs/cases/README.md) |
| 检查系统安全 | [系统安全加固](docs/manual/security/HARDENING.md) / [命令风险等级](docs/security/RISK-LEVELS.md) |

## 内容规划

- [x] PowerShell 常用命令
- [x] Linux 常用命令
- [x] 银河麒麟命令场景
- [x] 统信 UOS 命令场景
- [x] 运维与安全加固
- [x] 跨平台脚本与工具
- [x] PowerShell 与 Bash 对照表
- [x] Linux 故障应急排查
- [x] 国产 Linux 专题入口
- [x] 示例脚本目录
- [x] GitHub Pages 文档站配置
- [x] 命令索引
- [x] 命令风险等级说明
- [x] 常见报错排查扩展
- [x] Docker 与 Kubernetes 速查
- [x] Bash 文本处理专题
- [x] PowerShell 实用场景专题
- [x] 维护者指南与 Release 检查清单
- [x] 真实故障案例库
- [x] 国产 Linux 离线安装与架构兼容性专题
- [x] 巡检脚本支持保存报告
- [x] 巡检脚本支持模块化检查和 Markdown 报告
- [x] 完整手册专题化入口第一阶段
- [x] Nginx、DNS、证书过期故障案例
- [x] ImagePullBackOff、Docker Compose、TLS 证书链案例
- [x] ShellCheck、PSScriptAnalyzer、markdownlint、敏感信息扫描
- [x] 命令覆盖矩阵
- [x] 数据库与中间件命令专题
- [x] 日志轮转、auditd、rsyslog 专题
- [x] sudoers 与 AppArmor 专题
- [x] 国产 Linux 版本差异专题
- [x] PostgreSQL、MongoDB、Elasticsearch 专题
- [x] 云服务器与负载均衡排查专题
- [x] 集中日志与监控告警专题
- [x] Git、SSH、curl、jq 开发工具专题
- [x] PromQL、LogQL 与告警规则专题
- [x] Linux 网络、监控日志、Docker/Kubernetes 主手册章节迁移
- [x] PowerShell 高级、Linux 权限、Shell 脚本、跨平台脚本、Keepalived 章节迁移
- [x] 下一阶段优化计划
- [x] 巡检脚本 JSON 输出、统一结构和明确退出码
- [ ] 完整手册原文逐章迁移

## 安全提醒

涉及删除、权限、磁盘、网络和系统服务的命令请先在测试环境验证。特别是 `rm -rf`、`Remove-Item -Recurse -Force`、磁盘格式化、用户权限修改等操作，执行前务必确认路径、目标机器和备份状态。

## 让项目更容易被看见

建议在 GitHub 仓库的 **About** 区域补充:

- Description: `Windows PowerShell、Linux、银河麒麟、统信 UOS 常用命令中文速查手册`
- Topics: `powershell`, `linux`, `windows`, `kylin`, `uos`, `devops`, `sysadmin`, `command-line`, `cheatsheet`, `chinese`
- Website: 启用 GitHub Pages 后可填写 `https://shiwenxin123.github.io/PowerShell-Linux-Command-Manual/`

发布 CSDN、微信公众号或技术社区文章时，可以参考 [开源运营手册](docs/OPEN-SOURCE-OPERATIONS.md)，并在文章中回链 GitHub、在线文档和 Release 页面。

## 贡献

欢迎补充命令、修正文档、增加真实场景示例。提交前请阅读 [贡献指南](CONTRIBUTING.md)，也可以直接 [创建 Issue](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/issues/new/choose)。

如果你第一次参与，可以从这些任务开始:

- [Good First Issues 清单](docs/GOOD-FIRST-ISSUES.md)
- 补充一个真实故障案例
- 给某个专题页增加版本限制或风险提示
- 修正命令输出示例中的错别字、过时参数或缺失说明

## 更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 了解版本变化。

## License

本项目使用 [MIT License](LICENSE)。
