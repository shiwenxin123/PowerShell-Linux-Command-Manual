# Windows PowerShell 与 Linux 常用命令手册

一份中文命令速查与运维排障文档，覆盖 Windows PowerShell、Linux、银河麒麟、统信 UOS 和跨平台脚本场景。

项目地址: [GitHub 仓库](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual)
当前版本: [v2.16.0](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/releases/tag/v2.16.0)

## 推荐从这里开始

| 角色/场景 | 推荐路径 |
| --- | --- |
| 新手快速入门 | [命令速查表](COMMAND-CHEATSHEET.md) -> [PowerShell 基础](manual/powershell/BASIC.md) -> [Linux 基础](manual/linux/BASIC.md) |
| 运维值班排障 | [Linux 应急排查](troubleshooting/LINUX-INCIDENT-CHECKLIST.md) -> [真实故障案例](cases/README.md) -> [命令风险等级](security/RISK-LEVELS.md) |
| 国产 Linux 环境 | [Kylin/UOS 常用命令](domestic-linux/KYLIN-UOS-COMMANDS.md) -> [离线安装](domestic-linux/OFFLINE-PACKAGE-GUIDE.md) -> [版本差异](domestic-linux/VERSION-DIFFERENCES.md) |
| Kubernetes 排障 | [Kubernetes 排障路线](routes/KUBERNETES-TROUBLESHOOTING.md) -> [Kubernetes 进阶排查](manual/kubernetes/ADVANCED-TROUBLESHOOTING.md) -> [K8s 故障案例](cases/README.md) |
| 自动化巡检 | [巡检脚本工具化](manual/automation/HEALTH-CHECK-SCRIPTS.md) -> [JSON Schema](schema/health-check-report.schema.json) |
| 参与贡献 | [Good First Issues](GOOD-FIRST-ISSUES.md) -> [维护者指南](MAINTAINER-GUIDE.md) |
| 发布运营 | [开源运营手册](OPEN-SOURCE-OPERATIONS.md) -> [Release 检查清单](RELEASE-CHECKLIST.md) |

## 快速入口

| 需求 | 文档 |
| --- | --- |
| 常见问题 | [FAQ](FAQ.md) |
| 新手路线 | [新手路线](routes/BEGINNER.md) |
| 运维值班路线 | [运维值班路线](routes/OPS-ONCALL.md) |
| 国产 Linux 路线 | [国产 Linux 路线](routes/DOMESTIC-LINUX.md) |
| Kubernetes 排障路线 | [Kubernetes 排障路线](routes/KUBERNETES-TROUBLESHOOTING.md) |
| 离线 PDF 发布 | [离线 PDF 发布流程](PDF-EXPORT.md) |
| 按命令查找 | [命令索引](COMMAND-INDEX.md) |
| 覆盖面评估 | [命令覆盖矩阵](COMMAND-COVERAGE-MATRIX.md) |
| 迁移状态 | [主手册收口与专题化状态](MANUAL-MIGRATION.md) |
| 下一阶段 | [下一阶段优化计划](NEXT-STAGE-PLAN.md) |
| 快速查命令 | [命令速查表](COMMAND-CHEATSHEET.md) |
| 专题手册 | [专题手册入口](manual/README.md) |
| Linux 包管理 | [Linux 包管理](manual/linux/PACKAGE-MANAGEMENT.md) |
| Linux 用户权限 | [Linux 用户、组与权限](manual/linux/USERS-PERMISSIONS.md) |
| Shell 脚本 | [Shell 脚本基础与高级技巧](manual/linux/SHELL-SCRIPTING.md) |
| 磁盘与 LVM | [Linux 磁盘、挂载与 LVM](manual/linux/DISK-LVM.md) |
| 性能调优 | [Linux 性能调优](manual/linux/PERFORMANCE-TUNING.md) |
| 系统监控/日志 | [Linux 系统监控与日志](manual/linux/MONITORING-LOGS.md) |
| 防火墙/SELinux | [防火墙与 SELinux](manual/security/FIREWALL-SELINUX.md) |
| 日志与审计 | [日志轮转、审计与系统日志](manual/security/LOGGING-AUDIT.md) |
| sudoers/AppArmor | [sudoers 与 AppArmor](manual/security/SUDOERS-APPARMOR.md) |
| Windows 管理 | [Windows 管理命令](manual/windows/ADMIN-COMMANDS.md) |
| Kubernetes 进阶 | [Kubernetes 进阶排查](manual/kubernetes/ADVANCED-TROUBLESHOOTING.md) |
| Docker/Kubernetes 生产命令 | [Docker 与 Kubernetes 生产级命令](manual/kubernetes/DOCKER-K8S-PRODUCTION.md) |
| 数据库/中间件 | [数据库与中间件命令](manual/middleware/DATABASE-MIDDLEWARE.md) |
| PostgreSQL/MongoDB/Elasticsearch | [PostgreSQL、MongoDB 与 Elasticsearch](manual/middleware/POSTGRES-MONGO-ELASTIC.md) |
| 云服务器/负载均衡 | [云服务器与负载均衡排查](manual/cloud/CLOUD-LB-TROUBLESHOOTING.md) |
| 监控告警 | [集中日志与监控告警](manual/observability/LOGGING-MONITORING.md) |
| PromQL/LogQL | [PromQL、LogQL 与告警规则](manual/observability/PROMQL-LOGQL-ALERTS.md) |
| 开发工具 | [Git、SSH、curl 与 jq](manual/devtools/GIT-SSH-CURL-JQ.md) |
| 巡检脚本 | [巡检脚本工具化](manual/automation/HEALTH-CHECK-SCRIPTS.md) |
| 跨平台脚本 | [Python 与 Node.js 跨平台脚本](manual/cross-platform/PYTHON-NODE-SCRIPTS.md) |
| 高可用 | [Keepalived 高可用](manual/ha/KEEPALIVED.md) |
| Windows/Linux 迁移 | [PowerShell 与 Bash 命令对照](POWERSHELL-BASH-COMPARISON.md) |
| PowerShell 实战 | [PowerShell 实用场景](powershell/POWERSHELL-PRACTICAL.md) |
| Bash 文本处理 | [Bash 文本处理速查](linux/BASH-TEXT-PROCESSING.md) |
| Linux 线上排障 | [Linux 故障应急排查清单](troubleshooting/LINUX-INCIDENT-CHECKLIST.md) |
| 常见报错 | [常见报错排查](troubleshooting/COMMON-ERRORS.md) |
| 真实故障案例 | [真实故障案例库](cases/README.md) |
| 监控告警故障 | [Prometheus 告警规则误报](cases/PROMETHEUS-ALERT-FALSE-POSITIVE.md) / [Prometheus Target Down](cases/PROMETHEUS-TARGET-DOWN.md) / [Grafana 无数据](cases/GRAFANA-NO-DATA.md) |
| Kubernetes DNS | [Kubernetes DNS 异常排查](cases/K8S-DNS-FAILED.md) |
| Docker/Kubernetes | [Docker 与 Kubernetes 运维速查](containers/DOCKER-KUBERNETES-CHEATSHEET.md) |
| 国产 Linux 运维 | [银河麒麟与统信 UOS 常用命令](domestic-linux/KYLIN-UOS-COMMANDS.md) |
| 离线安装/软件源 | [国产 Linux 离线安装与软件源维护](domestic-linux/OFFLINE-PACKAGE-GUIDE.md) |
| 国产系统差异 | [国产 Linux 版本差异与排查要点](domestic-linux/VERSION-DIFFERENCES.md) |
| 命令安全 | [命令风险等级说明](security/RISK-LEVELS.md) |
| GitHub 项目优化 | [GitHub 热度优化清单](GITHUB-GROWTH-CHECKLIST.md) |
| 开源运营 | [开源运营手册](OPEN-SOURCE-OPERATIONS.md) |
| 技术文章草稿 | [v2.16.0 技术文章草稿](articles/V2.16.0-TECH-ARTICLE.md) |
| 项目审查 | [项目整体审查报告](PROJECT-AUDIT.md) |
| 新手任务 | [Good First Issues 清单](GOOD-FIRST-ISSUES.md) |
| 项目维护 | [维护者指南](MAINTAINER-GUIDE.md) |
| 发布检查 | [Release 检查清单](RELEASE-CHECKLIST.md) |
| Release 草案 | [v2.16.0 Release 草案](RELEASE-2.16-DRAFT.md) |

## 学习路线

| 路线 | 建议顺序 |
| --- | --- |
| 新手入门 | [命令速查表](COMMAND-CHEATSHEET.md) -> [PowerShell 基础](manual/powershell/BASIC.md) -> [Linux 基础](manual/linux/BASIC.md) |
| 运维值班 | [Linux 应急排查](troubleshooting/LINUX-INCIDENT-CHECKLIST.md) -> [真实故障案例](cases/README.md) -> [命令风险等级](security/RISK-LEVELS.md) |
| 国产 Linux | [麒麟与 UOS](domestic-linux/KYLIN-UOS-COMMANDS.md) -> [离线安装](domestic-linux/OFFLINE-PACKAGE-GUIDE.md) -> [版本差异](domestic-linux/VERSION-DIFFERENCES.md) |
| 容器/Kubernetes | [Docker/Kubernetes 生产命令](manual/kubernetes/DOCKER-K8S-PRODUCTION.md) -> [Kubernetes 进阶排查](manual/kubernetes/ADVANCED-TROUBLESHOOTING.md) -> [K8s 故障案例](cases/README.md) |
| 脚本自动化 | [Shell 脚本](manual/linux/SHELL-SCRIPTING.md) -> [跨平台脚本](manual/cross-platform/PYTHON-NODE-SCRIPTS.md) -> [巡检脚本工具化](manual/automation/HEALTH-CHECK-SCRIPTS.md) |

完整路线页:

- [新手路线](routes/BEGINNER.md)
- [运维值班路线](routes/OPS-ONCALL.md)
- [国产 Linux 路线](routes/DOMESTIC-LINUX.md)
- [Kubernetes 排障路线](routes/KUBERNETES-TROUBLESHOOTING.md)

## 项目定位

- 面向新手: 提供常用命令和简明说明。
- 面向开发者: 提供 PowerShell 与 Bash 迁移对照。
- 面向运维: 提供系统、进程、网络、日志、服务排查命令。
- 面向信创环境: 提供银河麒麟与统信 UOS 常用操作入口。

## 按场景查找

| 场景 | 推荐文档 |
| --- | --- |
| 查端口和连接 | [Linux 网络排查](manual/linux/NETWORK.md) |
| 找大文件和磁盘占用 | [Linux 磁盘、挂载与 LVM](manual/linux/DISK-LVM.md) |
| 排查网关超时 | [网关超时](cases/GATEWAY-TIMEOUT.md) / [负载均衡健康检查失败](cases/LB-HEALTH-CHECK-FAILED.md) |
| 排查 DNS | [DNS 解析失败](cases/DNS-RESOLUTION-FAILED.md) / [Kubernetes DNS 异常](cases/K8S-DNS-FAILED.md) |
| 排查数据库连接 | [数据库连接池耗尽](cases/DB-CONNECTION-POOL-EXHAUSTED.md) / [MySQL 连接数打满](cases/MYSQL-TOO-MANY-CONNECTIONS.md) |
| 排查消息队列 | [消息队列连接失败](cases/MESSAGE-QUEUE-CONNECTION-FAILED.md) |
| 分析日志 | [日志轮转、审计与系统日志](manual/security/LOGGING-AUDIT.md) |
| 看 Prometheus/Grafana | [PromQL、LogQL 与告警规则](manual/observability/PROMQL-LOGQL-ALERTS.md) |
| 排查容器和 Kubernetes | [Docker 与 Kubernetes 生产级命令](manual/kubernetes/DOCKER-K8S-PRODUCTION.md) |
| 检查安全风险 | [系统安全加固](manual/security/HARDENING.md) / [命令风险等级说明](security/RISK-LEVELS.md) |

## 快速运行巡检脚本

Linux:

```bash
bash scripts/linux-health-check.sh --format json
```

Windows PowerShell:

```powershell
.\scripts\windows-health-check.ps1 -Format json
```

## 安全提醒

删除、格式化、权限递归修改、服务重启等命令可能影响系统稳定性或数据安全。执行前请确认目标路径、备份状态和当前环境。
