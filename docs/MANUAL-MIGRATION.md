# 主手册专题化迁移进度

根目录主手册已在 v2.16.0 完成最终收口，不再维护重复正文。当前主手册只保留总导航、历史说明和重点入口；日常内容维护以专题页、路线页、案例库和巡检脚本文档为准。

## 迁移状态

| 主手册章节 | 专题页 | 状态 |
| --- | --- | --- |
| Windows PowerShell 基础导航与文件操作 | [PowerShell 基础命令](manual/powershell/BASIC.md) | 已迁移 |
| Windows PowerShell 系统信息、进程、服务、网络 | [PowerShell 系统管理](manual/powershell/SYSTEM-ADMIN.md) | 已迁移 |
| PowerShell 管道、变量、脚本和错误处理 | [PowerShell 高级脚本](manual/powershell/ADVANCED-SCRIPTING.md) | 已迁移 |
| Linux 基础导航与文件操作 | [Linux 基础命令](manual/linux/BASIC.md) | 已迁移 |
| Linux 用户、组、权限管理 | [Linux 用户、组与权限](manual/linux/USERS-PERMISSIONS.md) | 已迁移 |
| Linux Shell 脚本基础与高级技巧 | [Shell 脚本基础与高级技巧](manual/linux/SHELL-SCRIPTING.md) | 已迁移 |
| Linux 网络相关命令 | [Linux 网络排查](manual/linux/NETWORK.md) | 已迁移 |
| Linux 系统监控与日志 | [Linux 系统监控与日志](manual/linux/MONITORING-LOGS.md) | 已迁移 |
| Linux 包管理 | [Linux 包管理](manual/linux/PACKAGE-MANAGEMENT.md) | 已专题化 |
| Linux 磁盘与存储管理 | [Linux 磁盘、挂载与 LVM](manual/linux/DISK-LVM.md) | 已专题化 |
| 系统性能调优 | [Linux 性能调优](manual/linux/PERFORMANCE-TUNING.md) | 已迁移 |
| Docker 与 Kubernetes 基础 | [Docker 与 Kubernetes 生产级命令](manual/kubernetes/DOCKER-K8S-PRODUCTION.md) | 已迁移 |
| Kubernetes 进阶排障 | [Kubernetes 进阶排障](manual/kubernetes/ADVANCED-TROUBLESHOOTING.md) | 已补充 |
| 安全加固 | [系统安全加固](manual/security/HARDENING.md) | 已迁移 |
| 防火墙与 SELinux | [防火墙与 SELinux](manual/security/FIREWALL-SELINUX.md) | 已专题化 |
| sudoers 与 AppArmor | [sudoers 与 AppArmor](manual/security/SUDOERS-APPARMOR.md) | 已专题化 |
| 企业级日志管理 | [日志轮转、审计与系统日志](manual/security/LOGGING-AUDIT.md) | 已补充 |
| Python/Node.js 跨平台脚本示例 | [Python 与 Node.js 跨平台脚本](manual/cross-platform/PYTHON-NODE-SCRIPTS.md) | 已迁移 |
| 跨平台脚本与工具 | [跨平台脚本与工具](manual/cross-platform/TOOLS.md) | 已补充 |
| Git、SSH、curl、jq 等开发工具 | [Git、SSH、curl、jq 开发工具](manual/devtools/GIT-SSH-CURL-JQ.md) | 已专题化 |
| 银河麒麟与统信 UOS | [银河麒麟与统信 UOS 常用命令](domestic-linux/KYLIN-UOS-COMMANDS.md) | 已补充 |
| 国产 Linux 离线安装 | [国产 Linux 离线安装指南](domestic-linux/OFFLINE-PACKAGE-GUIDE.md) | 已专题化 |
| 国产 Linux 架构兼容 | [国产 Linux 架构兼容清单](domestic-linux/ARCHITECTURE-CHECKLIST.md) | 已专题化 |
| 国产 Linux 版本差异 | [国产 Linux 版本差异](domestic-linux/VERSION-DIFFERENCES.md) | 已专题化 |
| 高可用与 Keepalived | [Keepalived 高可用](manual/ha/KEEPALIVED.md) | 已迁移 |
| 自动化巡检脚本 | [巡检脚本工具化说明](manual/automation/HEALTH-CHECK-SCRIPTS.md) | 已工具化 |

## 收口状态

- 根目录 `Windows-PowerShell-Linux-Command-Manual.md` 已压缩为总导航、历史说明和专题入口。
- README、FAQ、命令索引、命令速查表和专题手册入口已改为推荐专题页优先。
- 后续不再以“主手册逐章迁移”为主要任务，改为按专题持续补充命令、版本差异、真实案例和巡检脚本能力。

## 后续补充方向

- 补充 Kylin/UOS 不同真实版本和授权组件差异案例。
- 补充性能调优在数据库、中间件、容器场景下的参数对照。
- 补充企业日志接入 Loki、ELK、云日志服务的真实案例。
- 持续把新增案例反向链接到相关专题页。

## 维护原则

- 新增命令优先放入对应专题页，而不是根目录主手册。
- 新增专题后同步更新 `mkdocs.yml`、`docs/index.md`、`README.md` 和 `CHANGELOG.md`。
- 高危命令同步补风险提醒。
- 根目录主手册只维护入口、历史说明和项目定位。
