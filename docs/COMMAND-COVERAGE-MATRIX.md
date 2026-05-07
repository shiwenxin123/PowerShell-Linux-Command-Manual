# 命令覆盖矩阵

这个矩阵用于判断项目命令覆盖是否足够全面。覆盖等级分为:

- 完整: 已有独立专题或案例，命令和场景都较完整。
- 中等: 已有基础命令，但还缺专题化说明或真实案例。
- 待补: 目前覆盖不足，建议优先补充。

## 总览

| 领域 | 当前覆盖 | 优先级 | 建议 |
| --- | --- | --- | --- |
| PowerShell 文件/目录/进程/服务 | 完整 | 中 | 继续补远程管理、事件日志、注册表 |
| Linux 基础命令 | 完整 | 中 | 继续补更多文本处理组合 |
| Linux 网络排查 | 中等 | 高 | 继续补 DNS、路由、抓包案例 |
| Linux 存储与磁盘 | 完整 | 中 | 后续补更多真实扩容案例 |
| Linux 包管理 | 完整 | 中 | 后续补更多国产源差异 |
| 权限与安全 | 完整 | 中 | 后续补更多等保基线案例 |
| 日志与审计 | 完整 | 中 | 后续补集中日志和告警案例 |
| Windows 系统管理 | 完整 | 中 | 后续补更多远程管理案例 |
| 容器与 Kubernetes | 完整 | 中 | 后续补更多 Helm/Ingress/PVC 案例 |
| 国产 Linux | 完整 | 中 | 后续补更多真实版本案例 |
| 数据库与中间件 | 完整 | 中 | 后续补更多真实故障案例 |
| 自动化脚本 | 完整 | 中 | 后续补测试用例、JSON schema 和更多模块 |
| Git 与开发工具 | 完整 | 中 | 后续补更多 GitHub CLI 和调试工具 |
| 云服务器常用排查 | 完整 | 中 | 后续补不同云厂商差异 |
| 集中日志与监控告警 | 完整 | 中 | 后续补更多真实告警案例 |

## 必补命令族

### PowerShell/Windows

- 事件日志: `Get-EventLog`、`Get-WinEvent`
- 注册表: `Get-ItemProperty`、`Set-ItemProperty`
- 计划任务: `Get-ScheduledTask`、`Start-ScheduledTask`
- 防火墙: `Get-NetFirewallRule`、`New-NetFirewallRule`
- 远程管理: `Enter-PSSession`、`Invoke-Command`
- 软件包: `winget`、`choco`、`Install-Module`

### Linux 基础与运维

- 包管理: `apt`、`dpkg`、`yum`、`dnf`、`rpm`
- 压缩归档: `tar`、`gzip`、`zip`、`unzip`
- 磁盘挂载: `lsblk`、`blkid`、`mount`、`umount`、`fstab`
- LVM: `pvs`、`vgs`、`lvs`、`lvextend`
- 文件句柄: `lsof`、`fuser`
- 抓包: `tcpdump`
- 防火墙: `firewall-cmd`、`ufw`、`iptables`、`nft`
- 安全策略: `getenforce`、`setenforce`、`sestatus`

### 容器与 Kubernetes

- Docker Compose: `docker compose ps`、`logs`、`config`、`up`、`down`
- Kubernetes 网络: `kubectl get svc`、`endpoints`、`ingress`
- Kubernetes 存储: `kubectl get pvc`、`pv`、`storageclass`
- Helm: `helm list`、`helm status`、`helm rollback`
- 节点排查: `kubectl describe node`、`kubectl top node`

### 数据库与中间件

- MySQL: `mysqladmin`、`SHOW PROCESSLIST`、`SHOW SLAVE STATUS`
- Redis: `redis-cli info`、`slowlog`、`monitor`
- Nginx: `nginx -t`、`nginx -T`、访问日志分析
- 消息队列: RabbitMQ、Kafka 基础排查命令

## 推荐补充顺序

1. 将主手册相关章节迁移到专题目录。
2. 增加更多真实生产案例。
3. 新增不同云厂商差异说明。
4. 新增 GitHub CLI、OpenSSL、nmap 等排障工具专题。
5. 开始主手册原文逐章迁移。
