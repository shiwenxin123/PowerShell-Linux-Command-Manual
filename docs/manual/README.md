# 专题手册入口

根目录主手册已经收口为总导航和历史说明: [Windows-PowerShell-Linux-Command-Manual.md](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/blob/main/Windows-PowerShell-Linux-Command-Manual.md)。

这个目录承接原主手册中的高频命令、专题说明和运维场景。后续新增内容应优先进入对应专题页，根目录主手册只维护入口、历史说明和项目定位。

## 专题列表

| 专题 | 文档 |
| --- | --- |
| PowerShell 基础 | [PowerShell 基础命令](powershell/BASIC.md) |
| PowerShell 系统管理 | [PowerShell 系统管理](powershell/SYSTEM-ADMIN.md) |
| PowerShell 高级技巧 | [PowerShell 高级技巧](powershell/ADVANCED-SCRIPTING.md) |
| Linux 基础 | [Linux 基础命令](linux/BASIC.md) |
| Linux 包管理 | [Linux 包管理](linux/PACKAGE-MANAGEMENT.md) |
| Linux 用户、组与权限 | [Linux 用户、组与权限](linux/USERS-PERMISSIONS.md) |
| Shell 脚本 | [Shell 脚本基础与高级技巧](linux/SHELL-SCRIPTING.md) |
| Linux 网络排查 | [Linux 网络排查](linux/NETWORK.md) |
| Linux 存储与日志 | [Linux 存储与日志](linux/STORAGE-LOGS.md) |
| Linux 系统监控与日志 | [Linux 系统监控与日志](linux/MONITORING-LOGS.md) |
| Linux 磁盘与 LVM | [Linux 磁盘、挂载与 LVM](linux/DISK-LVM.md) |
| Linux 性能调优 | [Linux 性能调优](linux/PERFORMANCE-TUNING.md) |
| 安全加固 | [系统安全加固](security/HARDENING.md) |
| 防火墙与 SELinux | [防火墙与 SELinux](security/FIREWALL-SELINUX.md) |
| 日志轮转与审计 | [日志轮转、审计与系统日志](security/LOGGING-AUDIT.md) |
| sudoers 与 AppArmor | [sudoers 与 AppArmor](security/SUDOERS-APPARMOR.md) |
| Windows 管理 | [Windows 管理命令](windows/ADMIN-COMMANDS.md) |
| Kubernetes 进阶排查 | [Kubernetes 进阶排查](kubernetes/ADVANCED-TROUBLESHOOTING.md) |
| Docker 与 Kubernetes 生产级命令 | [Docker 与 Kubernetes 生产级命令](kubernetes/DOCKER-K8S-PRODUCTION.md) |
| 数据库与中间件 | [数据库与中间件命令](middleware/DATABASE-MIDDLEWARE.md) |
| PostgreSQL/MongoDB/Elasticsearch | [PostgreSQL、MongoDB 与 Elasticsearch](middleware/POSTGRES-MONGO-ELASTIC.md) |
| 云服务器与负载均衡 | [云服务器与负载均衡排查](cloud/CLOUD-LB-TROUBLESHOOTING.md) |
| 集中日志与监控告警 | [集中日志与监控告警](observability/LOGGING-MONITORING.md) |
| PromQL/LogQL/告警规则 | [PromQL、LogQL 与告警规则](observability/PROMQL-LOGQL-ALERTS.md) |
| 开发与排障工具 | [开发与排障工具](devtools/README.md) |
| 巡检脚本工具化 | [巡检脚本工具化](automation/HEALTH-CHECK-SCRIPTS.md) |
| Python 与 Node.js 跨平台脚本 | [Python 与 Node.js 跨平台脚本](cross-platform/PYTHON-NODE-SCRIPTS.md) |
| Keepalived 高可用 | [Keepalived 高可用](ha/KEEPALIVED.md) |
| 跨平台工具 | [跨平台脚本与工具](cross-platform/TOOLS.md) |

## 场景路线

| 路线 | 文档 |
| --- | --- |
| 新手路线 | [新手路线](../routes/BEGINNER.md) |
| 运维值班路线 | [运维值班路线](../routes/OPS-ONCALL.md) |
| 国产 Linux 路线 | [国产 Linux 路线](../routes/DOMESTIC-LINUX.md) |
| Kubernetes 排障路线 | [Kubernetes 排障路线](../routes/KUBERNETES-TROUBLESHOOTING.md) |

## 拆分原则

- README 和索引页只放入口，不堆长命令。
- 单个专题尽量控制在一个明确场景内。
- 高危命令必须链接到 [命令风险等级说明](../security/RISK-LEVELS.md)。
- 与故障相关的内容优先沉淀到 [真实故障案例库](../cases/README.md)。
