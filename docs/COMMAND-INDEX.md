# 命令索引

这个索引用于按关键词快速定位常用命令。需要更完整的说明时，请进入对应专题页或故障案例库；根目录 [主手册总导航](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/blob/main/Windows-PowerShell-Linux-Command-Manual.md) 只保留入口和历史说明。

## 文件与目录

| 命令 | 平台 | 场景 |
| --- | --- | --- |
| `Get-ChildItem` | PowerShell | 列出文件、筛选文件、递归查找 |
| `Get-Content` | PowerShell | 查看文件、实时查看日志 |
| `Copy-Item` | PowerShell | 复制文件或目录 |
| `Move-Item` | PowerShell | 移动或重命名 |
| `Remove-Item` | PowerShell | 删除文件或目录 |
| `ls` | Linux | 列出目录内容 |
| `find` | Linux | 查找文件 |
| `grep` | Linux | 搜索文本 |
| `cp` | Linux | 复制文件或目录 |
| `mv` | Linux | 移动或重命名 |
| `rm` | Linux | 删除文件或目录 |

## 系统信息

| 命令 | 平台 | 场景 |
| --- | --- | --- |
| `Get-ComputerInfo` | PowerShell | 查看 Windows 系统信息 |
| `Get-Process` | PowerShell | 查看进程 |
| `Get-Service` | PowerShell | 查看服务 |
| `Get-PSDrive` | PowerShell | 查看磁盘和驱动器 |
| `uname` | Linux | 查看内核和架构 |
| `cat /etc/os-release` | Linux | 查看发行版信息 |
| `free` | Linux | 查看内存 |
| `df` | Linux | 查看磁盘空间 |
| `du` | Linux | 查看目录占用 |
| `top` | Linux | 实时查看资源 |
| `htop` | Linux | 交互式查看资源 |
| `lscpu` | Linux | 查看 CPU 信息 |
| `lsblk` | Linux | 查看块设备 |
| `uptime` | Linux | 查看运行时间和负载 |

## 包管理

| 命令 | 平台 | 场景 |
| --- | --- | --- |
| `apt` | Debian/UOS | 安装、更新、搜索软件包 |
| `dpkg` | Debian/UOS | 查询和安装 `.deb` 包 |
| `yum` | RHEL/Kylin | 安装、更新、搜索软件包 |
| `dnf` | RHEL/Fedora | 新版 RPM 系包管理 |
| `rpm` | RPM 系 | 查询和安装 `.rpm` 包 |
| `winget` | Windows | Windows 软件包管理 |
| `Install-Module` | PowerShell | 安装 PowerShell 模块 |

## 网络

| 命令 | 平台 | 场景 |
| --- | --- | --- |
| `Test-Connection` | PowerShell | Ping 测试 |
| `Test-NetConnection` | PowerShell | 测试端口 |
| `Get-NetTCPConnection` | PowerShell | 查看 TCP 连接 |
| `ipconfig` | Windows | 查看网络配置 |
| `ping` | Linux | 测试连通性 |
| `ip addr` | Linux | 查看 IP |
| `ip route` | Linux | 查看路由 |
| `ss` | Linux | 查看端口和连接 |
| `curl` | Linux/Windows | HTTP 请求测试 |
| `nc` | Linux | 端口连通测试 |
| `traceroute` | Linux | 路由跟踪 |
| `mtr` | Linux | 连通性和丢包分析 |
| `tcpdump` | Linux | 抓包分析 |
| `nslookup` | Windows/Linux | DNS 查询 |
| `dig` | Linux | DNS 详细查询 |

## 服务与日志

| 命令 | 平台 | 场景 |
| --- | --- | --- |
| `Start-Service` | PowerShell | 启动服务 |
| `Stop-Service` | PowerShell | 停止服务 |
| `Restart-Service` | PowerShell | 重启服务 |
| `systemctl` | Linux | 管理 systemd 服务 |
| `journalctl` | Linux | 查看 systemd 日志 |
| `tail -f` | Linux | 实时查看日志 |
| `Get-WinEvent` | PowerShell | 查看 Windows 事件日志 |
| `Get-EventLog` | PowerShell | 查看传统 Windows 日志 |
| `logrotate` | Linux | 日志轮转 |
| `rsyslogd` | Linux | 系统日志服务 |

## 权限与用户

| 命令 | 平台 | 场景 |
| --- | --- | --- |
| `whoami` | Windows/Linux | 查看当前用户 |
| `sudo` | Linux | 提权执行 |
| `su` | Linux | 切换用户 |
| `useradd` | Linux | 创建用户 |
| `passwd` | Linux | 修改密码 |
| `chmod` | Linux | 修改权限 |
| `chown` | Linux | 修改属主 |
| `sudo -l` | Linux | 查看 sudo 权限 |
| `visudo` | Linux | 安全编辑 sudoers |
| `getenforce` | Linux | 查看 SELinux 状态 |
| `setenforce` | Linux | 临时调整 SELinux 模式 |

## 磁盘、挂载与归档

| 命令 | 平台 | 场景 |
| --- | --- | --- |
| `mount` | Linux | 挂载文件系统 |
| `umount` | Linux | 卸载文件系统 |
| `blkid` | Linux | 查看块设备 UUID |
| `fdisk` | Linux | 查看和管理分区 |
| `parted` | Linux | 分区管理 |
| `pvs` | Linux | 查看 LVM 物理卷 |
| `vgs` | Linux | 查看 LVM 卷组 |
| `lvs` | Linux | 查看 LVM 逻辑卷 |
| `lvextend` | Linux | 扩展逻辑卷 |
| `tar` | Linux | 打包归档 |
| `gzip` | Linux | 压缩文件 |
| `zip` | Windows/Linux | ZIP 压缩 |
| `unzip` | Windows/Linux | ZIP 解压 |

## Windows 管理

| 命令 | 平台 | 场景 |
| --- | --- | --- |
| `Get-ItemProperty` | PowerShell | 读取注册表或对象属性 |
| `Set-ItemProperty` | PowerShell | 修改注册表或对象属性 |
| `Get-ScheduledTask` | PowerShell | 查看计划任务 |
| `Start-ScheduledTask` | PowerShell | 启动计划任务 |
| `Get-NetFirewallRule` | PowerShell | 查看防火墙规则 |
| `New-NetFirewallRule` | PowerShell | 新增防火墙规则 |
| `Enter-PSSession` | PowerShell | 进入远程会话 |
| `Invoke-Command` | PowerShell | 远程执行命令 |

## 容器与集群

| 命令 | 平台 | 场景 |
| --- | --- | --- |
| `docker ps` | Linux/Windows | 查看容器 |
| `docker logs` | Linux/Windows | 查看容器日志 |
| `docker exec` | Linux/Windows | 进入容器执行命令 |
| `kubectl get pods` | Kubernetes | 查看 Pod |
| `kubectl logs` | Kubernetes | 查看 Pod 日志 |
| `kubectl describe` | Kubernetes | 查看资源详情 |
| `kubectl rollout` | Kubernetes | 发布与回滚 |
| `docker compose ps` | Docker | 查看 Compose 服务 |
| `docker compose logs` | Docker | 查看 Compose 日志 |
| `kubectl get svc` | Kubernetes | 查看 Service |
| `kubectl get ingress` | Kubernetes | 查看 Ingress |
| `kubectl get pvc` | Kubernetes | 查看持久卷声明 |
| `helm list` | Kubernetes | 查看 Helm Release |
| `helm rollback` | Kubernetes | 回滚 Helm Release |

## 数据库与中间件

| 命令 | 平台 | 场景 |
| --- | --- | --- |
| `mysqladmin` | MySQL | 查看状态和管理 MySQL |
| `mysql` | MySQL | 执行 SQL 和排查连接 |
| `redis-cli` | Redis | Redis 连接和状态排查 |
| `nginx -t` | Nginx | 检查 Nginx 配置 |
| `nginx -T` | Nginx | 输出完整 Nginx 配置 |
| `psql` | PostgreSQL | PostgreSQL 连接和 SQL 排查 |
| `mongosh` | MongoDB | MongoDB 连接和状态排查 |
| `curl _cluster/health` | Elasticsearch | 查看 Elasticsearch 集群健康 |

## 开发与排障工具

| 命令 | 平台 | 场景 |
| --- | --- | --- |
| `git status` | Git | 查看工作区状态 |
| `git diff` | Git | 查看差异 |
| `git log` | Git | 查看提交历史 |
| `git show` | Git | 查看提交详情 |
| `ssh-keygen` | Windows/Linux | 生成 SSH key |
| `ssh -T` | Windows/Linux | 测试 SSH 认证 |
| `curl -I` | Windows/Linux | 查看 HTTP 响应头 |
| `curl -v` | Windows/Linux | 查看连接细节 |
| `jq` | Windows/Linux | 解析和过滤 JSON |

## 监控与日志查询

| 命令/表达式 | 平台 | 场景 |
| --- | --- | --- |
| `up` | PromQL | 查看 target 是否在线 |
| `rate(metric[5m])` | PromQL | 计算速率 |
| `histogram_quantile` | PromQL | 计算分位延迟 |
| `{app="name"} \|= "error"` | LogQL | 查询错误日志 |
| `count_over_time` | LogQL | 统计日志数量 |
