# Linux 性能调优

性能调优应先观测、再变更、最后回滚验证。生产环境不要直接套用模板参数，先确认内核版本、硬件类型、业务模型和基线指标。

## 调优前检查

```bash
# 系统与内核
uname -a
cat /etc/os-release

# CPU、内存、磁盘和网络概况
lscpu
free -h
lsblk
ip addr

# 当前负载
uptime
top
vmstat 1 5
iostat -x 1 5
```

## 内核参数

```bash
# 查看当前参数
sysctl net.core.somaxconn
sysctl net.ipv4.tcp_max_syn_backlog
sysctl vm.swappiness
sysctl fs.file-max

# 临时设置，重启后失效
sudo sysctl -w net.core.somaxconn=65535
sudo sysctl -w vm.swappiness=10

# 持久配置
sudo vi /etc/sysctl.conf
sudo sysctl -p
```

常见参数示例:

```text
# TCP 队列和缓冲区
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# TIME_WAIT 相关
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30

# 文件描述符
fs.file-max = 2097152
fs.nr_open = 2097152

# 虚拟内存
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50
```

注意: `net.ipv4.tcp_tw_recycle` 已不适合现代生产环境，尤其容易和 NAT 场景冲突，不建议启用。

## limits 资源限制

```bash
# 查看当前限制
ulimit -a
ulimit -n

# 编辑 limits
sudo vi /etc/security/limits.conf
```

示例:

```text
* soft nofile 655360
* hard nofile 655360
* soft nproc 655360
* hard nproc 655360

root soft nofile 1048576
root hard nofile 1048576

nginx soft nofile 1048576
nginx hard nofile 1048576
mysql soft nofile 1048576
mysql hard nofile 1048576
```

确认 PAM 已加载 limits:

```bash
grep pam_limits /etc/pam.d/login
grep pam_limits /etc/pam.d/sshd
```

## 磁盘 I/O

```bash
# 查看调度器
cat /sys/block/sda/queue/scheduler

# 临时修改调度器，需按实际设备名调整
echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler

# 查看和调整预读
sudo blockdev --getra /dev/sda
sudo blockdev --setra 8192 /dev/sda

# 查看 I/O 统计
iostat -x 1

# 查看进程 I/O
iotop

# 设置进程 I/O 优先级
ionice -c 2 -n 7 -p <pid>
ionice -c 3 -p <pid>
```

建议:

- SSD/NVMe 优先评估 `none`、`mq-deadline`、`kyber`。
- 机械盘可评估 `deadline`、`bfq`。
- 永久调整调度器前，先确认发行版和内核支持方式。

## 网络连接排查

```bash
# 监听和连接情况
ss -s
ss -ant
ss -tulnp

# 路由和邻居表
ip route
ip neigh

# 网卡统计
ip -s link
ethtool eth0
```

高并发服务建议同时关注:

- `somaxconn` 和应用 listen backlog 是否匹配。
- 文件描述符是否足够。
- 防火墙、负载均衡和应用连接池是否成为瓶颈。

## 变更建议

- 先记录基线，再改一个参数，最后复测。
- 所有持久配置都应保留变更记录和回滚值。
- 不同内核版本和发行版默认值差异较大，不建议照搬线上参数。
- 数据库、消息队列和 Web 服务应优先参考对应产品官方调优建议。

## 延伸阅读

- [Linux 系统监控与日志](MONITORING-LOGS.md)
- [Linux 磁盘、挂载与 LVM](DISK-LVM.md)
- [命令风险等级说明](../../security/RISK-LEVELS.md)
