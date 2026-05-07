# 主手册专题化迁移进度

根目录完整手册仍保留为历史完整版本和总参考。专题化迁移的目标是把长文档逐步拆成更易搜索、维护和贡献的页面。

## 迁移状态

| 主手册章节 | 专题页 | 状态 |
| --- | --- | --- |
| Windows PowerShell 基础导航与文件操作 | [PowerShell 基础命令](manual/powershell/BASIC.md) | 已迁移第一版 |
| Windows PowerShell 系统信息、进程、服务、网络 | [PowerShell 系统管理](manual/powershell/SYSTEM-ADMIN.md) | 已迁移第一版 |
| PowerShell 管道、变量、脚本和错误处理 | [PowerShell 高级技巧](manual/powershell/ADVANCED-SCRIPTING.md) | 已迁移 |
| Linux 基础导航与文件操作 | [Linux 基础命令](manual/linux/BASIC.md) | 已迁移第一版 |
| Linux 用户、组、权限管理 | [Linux 用户、组与权限](manual/linux/USERS-PERMISSIONS.md) | 已迁移 |
| Linux Shell 脚本基础与高级技巧 | [Shell 脚本基础与高级技巧](manual/linux/SHELL-SCRIPTING.md) | 已迁移 |
| Linux 网络相关命令 | [Linux 网络排查](manual/linux/NETWORK.md) | 已迁移 |
| Linux 系统监控与日志 | [Linux 系统监控与日志](manual/linux/MONITORING-LOGS.md) | 已迁移 |
| Linux 包管理 | [Linux 包管理](manual/linux/PACKAGE-MANAGEMENT.md) | 已专题化 |
| Linux 磁盘与存储管理 | [Linux 磁盘、挂载与 LVM](manual/linux/DISK-LVM.md) | 已专题化 |
| 系统性能调优 | [Linux 性能调优](manual/linux/PERFORMANCE-TUNING.md) | 已迁移 |
| Docker 与 Kubernetes 基础 | [Docker 与 Kubernetes 生产级命令](manual/kubernetes/DOCKER-K8S-PRODUCTION.md) | 已迁移 |
| 安全加固 | [系统安全加固](manual/security/HARDENING.md) | 已迁移第一版 |
| 防火墙与 SELinux | [防火墙与 SELinux](manual/security/FIREWALL-SELINUX.md) | 已专题化 |
| Python/Node.js 跨平台脚本完整示例 | [Python 与 Node.js 跨平台脚本](manual/cross-platform/PYTHON-NODE-SCRIPTS.md) | 已迁移 |
| 跨平台脚本与工具 | [跨平台脚本与工具](manual/cross-platform/TOOLS.md) | 已补充工具分类 |
| 银河麒麟与统信 UOS | [银河麒麟与统信 UOS 常用命令](domestic-linux/KYLIN-UOS-COMMANDS.md) | 已补充厂商命令细节 |
| 企业级日志管理 | [日志轮转、审计与系统日志](manual/security/LOGGING-AUDIT.md) | 已补充配置样例 |
| 高可用与 Keepalived | [Keepalived 高可用](manual/ha/KEEPALIVED.md) | 已迁移 |

## 仍建议继续迁移

- Kylin/UOS 不同版本和授权组件的命令差异案例。
- 性能调优的数据库、中间件和容器场景参数对照。
- 企业日志接入 Loki、ELK、云日志服务的真实案例。
- 主手册剩余附录内容的入口化整理。

## 迁移原则

- 每次迁移一个明确章节，避免一次性大改。
- 迁移后同步更新 `mkdocs.yml`、`docs/index.md`、`CHANGELOG.md`。
- 高危命令同步补风险提醒。
- 原主手册保留链接，直到专题页完全覆盖。
