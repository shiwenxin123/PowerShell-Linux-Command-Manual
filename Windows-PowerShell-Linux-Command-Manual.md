# Windows PowerShell 与 Linux 常用命令手册

> 当前版本: v2.16.0
> 状态: 主手册已完成最终收口
> 说明: 根目录主手册不再维护重复正文。日常阅读、检索和贡献请优先使用专题页、路线页、案例库和在线文档站。

- 在线文档: <https://shiwenxin123.github.io/PowerShell-Linux-Command-Manual/>
- GitHub 仓库: <https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual>
- Release: <https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/releases/tag/v2.16.0>

## 为什么收口

早期主手册承担了完整正文、命令速查、运维案例和专题导航的全部职责。随着项目扩展到 PowerShell、Linux、国产 Linux、Kubernetes、巡检脚本、真实故障案例和开源运营材料，继续在根目录维护一份超长正文会带来三个问题:

1. 同一命令容易在多个页面出现不同写法。
2. 新贡献者很难判断内容应该补到哪里。
3. 文档站导航、搜索和专题维护成本会持续升高。

因此从 v2.16.0 开始，根目录主手册收口为总导航和历史说明。原有正文已经按主题迁入 `docs/` 下的专题页，后续新增内容也应优先进入对应专题。

## 推荐阅读入口

| 需求 | 推荐入口 |
| --- | --- |
| 在线阅读 | [文档站首页](docs/index.md) |
| 新手学习 | [新手路线](docs/routes/BEGINNER.md) |
| 运维值班 | [运维值班路线](docs/routes/OPS-ONCALL.md) |
| 国产 Linux | [国产 Linux 路线](docs/routes/DOMESTIC-LINUX.md) |
| Kubernetes 排障 | [Kubernetes 排障路线](docs/routes/KUBERNETES-TROUBLESHOOTING.md) |
| 快速查命令 | [命令速查表](docs/COMMAND-CHEATSHEET.md) |
| 按命令查找 | [命令索引](docs/COMMAND-INDEX.md) |
| PowerShell/Bash 对照 | [PowerShell 与 Bash 命令对照](docs/POWERSHELL-BASH-COMPARISON.md) |
| 真实故障排查 | [故障案例库](docs/cases/README.md) |
| 自动化巡检 | [巡检脚本工具化说明](docs/manual/automation/HEALTH-CHECK-SCRIPTS.md) |
| 命令风险 | [命令风险等级说明](docs/security/RISK-LEVELS.md) |

## 专题手册

| 方向 | 文档 |
| --- | --- |
| PowerShell | [基础命令](docs/manual/powershell/BASIC.md) / [系统管理](docs/manual/powershell/SYSTEM-ADMIN.md) / [高级脚本](docs/manual/powershell/ADVANCED-SCRIPTING.md) |
| Linux 基础 | [基础命令](docs/manual/linux/BASIC.md) / [包管理](docs/manual/linux/PACKAGE-MANAGEMENT.md) / [用户与权限](docs/manual/linux/USERS-PERMISSIONS.md) / [Shell 脚本](docs/manual/linux/SHELL-SCRIPTING.md) |
| Linux 排障 | [网络排查](docs/manual/linux/NETWORK.md) / [磁盘与 LVM](docs/manual/linux/DISK-LVM.md) / [监控与日志](docs/manual/linux/MONITORING-LOGS.md) / [性能调优](docs/manual/linux/PERFORMANCE-TUNING.md) |
| 安全加固 | [系统加固](docs/manual/security/HARDENING.md) / [防火墙与 SELinux](docs/manual/security/FIREWALL-SELINUX.md) / [日志审计](docs/manual/security/LOGGING-AUDIT.md) / [sudoers 与 AppArmor](docs/manual/security/SUDOERS-APPARMOR.md) |
| Windows 管理 | [Windows 管理命令](docs/manual/windows/ADMIN-COMMANDS.md) |
| 容器与 Kubernetes | [Docker/Kubernetes 生产命令](docs/manual/kubernetes/DOCKER-K8S-PRODUCTION.md) / [Kubernetes 进阶排障](docs/manual/kubernetes/ADVANCED-TROUBLESHOOTING.md) / [容器速查](docs/containers/DOCKER-KUBERNETES-CHEATSHEET.md) |
| 数据库与中间件 | [数据库与中间件](docs/manual/middleware/DATABASE-MIDDLEWARE.md) / [PostgreSQL、MongoDB、Elasticsearch](docs/manual/middleware/POSTGRES-MONGO-ELASTIC.md) |
| 云与可观测性 | [云服务器与负载均衡](docs/manual/cloud/CLOUD-LB-TROUBLESHOOTING.md) / [集中日志与监控](docs/manual/observability/LOGGING-MONITORING.md) / [PromQL、LogQL 与告警](docs/manual/observability/PROMQL-LOGQL-ALERTS.md) |
| 国产 Linux | [Kylin/UOS 常用命令](docs/domestic-linux/KYLIN-UOS-COMMANDS.md) / [离线安装](docs/domestic-linux/OFFLINE-PACKAGE-GUIDE.md) / [架构兼容](docs/domestic-linux/ARCHITECTURE-CHECKLIST.md) / [版本差异](docs/domestic-linux/VERSION-DIFFERENCES.md) |
| 自动化与工具 | [巡检脚本](docs/manual/automation/HEALTH-CHECK-SCRIPTS.md) / [Python 与 Node.js 脚本](docs/manual/cross-platform/PYTHON-NODE-SCRIPTS.md) / [跨平台工具](docs/manual/cross-platform/TOOLS.md) / [Git、SSH、curl、jq](docs/manual/devtools/GIT-SSH-CURL-JQ.md) |
| 高可用 | [Keepalived 高可用](docs/manual/ha/KEEPALIVED.md) |

## 故障案例库

故障案例已经独立维护，适合按现象直接查找:

- [案例库总入口](docs/cases/README.md)
- [Linux 故障应急排查清单](docs/troubleshooting/LINUX-INCIDENT-CHECKLIST.md)
- [常见报错排查](docs/troubleshooting/COMMON-ERRORS.md)
- [案例写作模板](docs/cases/CASE-TEMPLATE.md)

后续新增案例建议优先覆盖: Kubernetes NetworkPolicy 拦截、Elasticsearch 磁盘水位、Loki 日志查询为空、国产 Linux 真实版本差异等场景。

## 巡检脚本

项目已提供 Linux 和 Windows 巡检脚本，支持 `text`、`markdown`、`json` 输出，并提供统一 JSON Schema 和示例报告。

Linux:

```bash
bash scripts/linux-health-check.sh --format json --output reports/linux-health-check.json
```

Windows PowerShell:

```powershell
.\scripts\windows-health-check.ps1 -Format json -OutputFile reports\windows-health-check.json
```

相关文档:

- [巡检脚本工具化说明](docs/manual/automation/HEALTH-CHECK-SCRIPTS.md)
- [Linux 示例 JSON](docs/examples/linux-health-check.sample.json)
- [Windows 示例 JSON](docs/examples/windows-health-check.sample.json)
- [巡检 JSON Schema](docs/schema/health-check-report.schema.json)

## 历史说明

根目录主手册曾经保存完整长文档正文。为了降低重复维护成本，正文内容已经拆分到专题页、路线页和故障案例中。

需要查看历史完整正文时，可以通过 Git 历史或对应 Release 回溯。当前版本开始，根目录主手册只作为总导航、收口说明和历史入口维护。

## 贡献

欢迎继续补充命令、真实故障案例和巡检脚本能力。开始前建议阅读:

- [贡献指南](CONTRIBUTING.md)
- [Good First Issues](docs/GOOD-FIRST-ISSUES.md)
- [维护者指南](docs/MAINTAINER-GUIDE.md)
