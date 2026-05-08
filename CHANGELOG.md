# Changelog

## 2.16.0

- README 和文档站首页新增学习路线，覆盖新手、运维值班、国产 Linux、容器/Kubernetes 和脚本自动化。
- 案例库新增按症状查找索引。
- 新增 v2.16.0 Release 草案，补充 GitHub About、发布文案和推荐阅读。
- 更新维护者指南，补充后续 good first issue 候选方向。
- 新增 Good First Issues 清单和故障案例补充 Issue 模板。
- 新增 Kubernetes DNS 异常、Prometheus Target Down、Grafana 无数据排查案例。
- 统一故障案例模板，新增故障案例写作模板。
- 新增 systemd 服务启动失败、Linux Permission denied、Docker 镜像拉取失败、Kubernetes Node NotReady、MySQL 连接数打满排查案例。
- 重点专题页补充相关案例入口，形成专题页和故障案例的双向导航。
- 新增新手路线、运维值班路线、国产 Linux 路线、Kubernetes 排障路线和离线 PDF 发布流程。
- 根目录主手册最终收口为总导航、历史说明和专题入口，不再维护重复正文。
- 同步 README、FAQ、命令索引、迁移进度、路线图和审计文档中的主手册状态。
- 主手册收口第 1 批: 补充 Kylin/UOS 厂商命令细节、企业级日志配置样例和跨平台工具分类。
- 新增 Linux 性能调优专题，覆盖 sysctl、limits、磁盘 I/O、网络连接和变更建议。
- Linux 巡检脚本新增 JSON 输出，使用统一 metadata/modules/summary/errors 结构。
- Windows 巡检脚本新增 JSON 输出，使用 PowerShell 对象和 `ConvertTo-Json` 生成结构化报告。
- 巡检脚本新增明确退出码: 0 正常、1 告警、2 参数错误、3 内部异常或输出失败。
- 新增 Linux 和 Windows JSON 示例报告。
- 新增巡检脚本工具化文档。
- 新增 Health Check Report JSON Schema，明确自动化消费字段契约。
- 新增巡检脚本 GitHub Actions 功能测试，覆盖 JSON 输出、输出文件和参数错误退出码。
- 巡检脚本新增 `package`、`security`、`container`、`log` 模块，并同步 Schema、示例报告、文档说明和 CI 测试。
- 新增网关超时、负载均衡健康检查失败、消息队列连接失败、数据库连接池耗尽、Prometheus 告警规则误报案例。
- 新增 `PDF Export` 手动触发工作流，支持导出重点页面 PDF artifact。
- 更新开源运营资料，并维护 Good First Issues 候选池。
- README 顶部新增 Docs、Markdown、Script Quality、Secret Scan 和 License badges。
- `requirements.txt` 增加 MkDocs、Material for MkDocs 和 pymdown-extensions 版本范围。
- 更新维护者指南和 Release 检查清单，补充依赖维护和本地验证步骤。
- 新增 FAQ 页面，并挂载到 README、文档站首页和 MkDocs 导航。
- 修复 Issue 模板旧仓库链接，补充本地 Bash 检查说明并统一 GitHub Pages 发布说明。
- 更新 README、文档站首页、专题入口、覆盖矩阵、路线图、下一阶段计划和审查报告。

## 2.15.0

- 新增下一阶段优化计划。
- 更新项目审查报告，修正已完成事项和剩余重点。
- 更新 Roadmap，移除已完成的旧目标。
- 更新 README、文档站首页和 MkDocs 导航。

## 2.14.0

- 迁移 PowerShell 高级技巧章节，覆盖管道、对象、变量、控制流、函数和错误处理。
- 迁移 Linux 用户、组与权限章节。
- 迁移 Shell 脚本基础与高级技巧章节。
- 迁移 Python 与 Node.js 跨平台脚本章节。
- 迁移 Keepalived 高可用章节。
- 更新主手册专题化迁移进度、文档站导航、首页和专题化手册入口。

## 2.13.0

- 迁移主手册 Linux 网络章节到专题页，补充 mtr、dig、scp、sftp、rsync、SSH 转发等命令。
- 新增 Linux 系统监控与日志专题。
- 新增 Docker 与 Kubernetes 生产级命令专题。
- 新增主手册专题化迁移进度表。
- 更新 README、文档站首页、MkDocs 导航和专题化手册入口。

## 2.12.0

- 新增 Git、SSH、curl 与 jq 开发排障工具专题。
- 新增 PromQL、LogQL 与告警规则专题。
- 扩展命令索引，补充 Git、SSH、curl、jq、PromQL、LogQL。
- 更新文档站导航、首页、专题化手册入口和命令覆盖矩阵。

## 2.11.0

- 新增 PostgreSQL、MongoDB 与 Elasticsearch 专题。
- 新增云服务器与负载均衡排查专题，覆盖安全组、NAT、云盘、负载均衡健康检查。
- 新增集中日志与监控告警专题，覆盖 Prometheus、Node Exporter、Alertmanager、Grafana、Loki、ELK。
- 更新文档站导航、首页、专题化手册入口和命令覆盖矩阵。

## 2.10.0

- 新增数据库与中间件命令专题，覆盖 MySQL、Redis、Nginx、RabbitMQ、Kafka。
- 新增日志轮转、审计与系统日志专题，覆盖 journalctl、logrotate、rsyslog、auditd。
- 新增 sudoers 与 AppArmor 专题。
- 新增国产 Linux 版本差异与排查要点。
- 更新文档站导航、首页、专题化手册入口和命令覆盖矩阵。

## 2.9.0

- 新增 Linux 包管理专题，覆盖 apt、dpkg、yum、dnf、rpm 和软件源排查。
- 新增 Linux 磁盘、挂载与 LVM 专题。
- 新增防火墙与 SELinux 专题，覆盖 firewalld、ufw、iptables、nftables、SELinux。
- 新增 Windows 管理命令专题，覆盖事件日志、注册表、计划任务、防火墙、远程管理。
- 新增 Kubernetes 进阶排查专题，覆盖 Service、Endpoints、Ingress、PVC/PV、Node、Helm。
- 更新文档站导航、首页、专题化手册入口和命令覆盖矩阵。

## 2.8.0

- 新增命令覆盖矩阵，用于评估 PowerShell、Linux、Windows、容器、国产 Linux、数据库和中间件等领域覆盖程度。
- 扩展命令索引，补充包管理、网络诊断、日志、安全、磁盘挂载、LVM、Windows 管理、Kubernetes、数据库与中间件命令族。
- 更新 README、文档站首页和 MkDocs 导航。

## 2.7.0

- Linux 和 Windows 巡检脚本支持模块化检查。
- Linux 和 Windows 巡检脚本支持 Markdown 报告输出。
- 新增 Kubernetes ImagePullBackOff、Docker Compose 启动失败、TLS 证书链不完整故障案例。
- 新增 Secret Scan 工作流。
- 文档检查脚本增加基础敏感信息模式扫描。
- 更新 README、MkDocs 导航和项目审查报告。

## 2.6.0

- 精简 README 第一屏快速入口，将完整导航交给文档站首页。
- 新增 markdownlint 配置。
- 新增 Script Quality 工作流，加入 ShellCheck 和 PSScriptAnalyzer。
- 新增 Nginx 502/504、MySQL 启动失败、Redis 连接失败、Java OOM 故障案例。
- 更新项目审查报告和 MkDocs 导航。

## 2.5.0

- 新增项目整体审查报告，梳理当前不足和后续优先级。
- 新增 `scripts/check-docs.ps1` 文档检查脚本。
- 更新 Markdown Check 工作流，改为执行实际文档检查。
- 修复 README Issue 链接和 Release 检查清单中的相对链接。

## 2.4.0

- 新增完整手册专题化入口第一阶段。
- 新增 PowerShell 基础、PowerShell 系统管理专题页。
- 新增 Linux 基础、网络排查、存储与日志专题页。
- 新增系统安全加固和跨平台工具专题页。
- 新增 Nginx 启动失败、DNS 解析失败、证书过期故障案例。
- 更新 README、文档站首页和 MkDocs 导航。

## 2.3.0

- 新增真实故障案例库，覆盖磁盘满、CPU 飙高、端口占用、SSH 失败、Docker 重启、Kubernetes CrashLoopBackOff。
- 扩展命令风险等级说明，按删除、权限、磁盘、网络、防火墙、服务等场景给出执行前检查。
- 新增国产 Linux 离线安装与软件源维护专题。
- 新增信创环境架构与兼容性检查专题。
- Linux 和 Windows 巡检脚本支持保存报告文件。
- 更新 README、文档站首页和 MkDocs 导航。

## 2.2.0

- 新增命令索引，便于按关键词快速定位命令。
- 新增命令风险等级说明和高危命令清单。
- 新增常见报错排查专题。
- 新增 Docker 与 Kubernetes 运维速查。
- 新增 PowerShell 实用场景专题。
- 新增 Bash 文本处理专题。
- 新增维护者指南、Release 检查清单和标签配置建议。
- 更新 README、文档站首页和 MkDocs 导航。

## 2.1.0

- 新增 README 项目首页，强化项目定位、快速入口和贡献说明。
- 新增 PowerShell 与 Linux 命令速查表。
- 新增 GitHub 热度优化清单。
- 新增 PowerShell 与 Bash 命令对照专题。
- 新增 Linux 故障应急排查清单。
- 新增银河麒麟与统信 UOS 常用命令专题。
- 新增 Linux 和 Windows 巡检示例脚本。
- 新增贡献指南、License、Issue 模板和 PR 模板。

## 2.0.0

- 完整手册覆盖 Windows PowerShell、Linux、银河麒麟、统信 UOS、专业运维与安全加固、跨平台脚本与工具。
