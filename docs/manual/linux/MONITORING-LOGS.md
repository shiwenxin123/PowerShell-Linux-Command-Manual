# Linux 系统监控与日志

这个专题从主手册迁移 Linux 系统监控与日志相关内容，覆盖资源查看、硬件信息、systemd 日志、内核日志和传统日志文件。

## 系统资源

```bash
# 实时监控系统资源
top

# 更强的交互式监控
htop

# 内存
free -h

# 磁盘
df -h

# 目录大小
du -sh /path/to/dir

# 平均负载
uptime
```

## 硬件信息

```bash
# CPU 信息
lscpu

# PCI 设备
lspci

# USB 设备
lsusb

# 硬件信息
lshw
```

## systemd 日志

```bash
# 显示系统日志
journalctl

# 最近 100 条
journalctl -n 100

# 实时监控
journalctl -f

# 指定服务
journalctl -u nginx

# 今天的日志
journalctl --since today

# 指定时间段
journalctl --since "2026-03-13 09:00:00" --until "2026-03-13 17:00:00"
```

## 内核日志

```bash
# 显示内核日志
dmesg

# 实时监控内核日志
dmesg -w

# 查看 OOM 记录
dmesg -T | grep -i "out of memory"
```

## 传统日志文件

```bash
# Debian/Ubuntu/UOS 常见日志
cat /var/log/syslog
cat /var/log/auth.log
cat /var/log/kern.log

# RHEL/Kylin 常见日志
cat /var/log/messages
cat /var/log/secure
```

## 常见排查组合

```bash
# CPU 高
ps aux --sort=-%cpu | head -n 10

# 内存高
ps aux --sort=-%mem | head -n 10

# 磁盘满
df -h
du -sh /* 2>/dev/null | sort -h

# 已删除但仍占用空间的文件
lsof | grep deleted
```

## 相关案例

- [Linux 故障应急排查清单](../../troubleshooting/LINUX-INCIDENT-CHECKLIST.md)
- [日志轮转、审计与系统日志](../security/LOGGING-AUDIT.md)
- [CPU 飙高排查](../../cases/CPU-HIGH.md)
- [磁盘空间满排查](../../cases/DISK-FULL.md)
- [Java 服务 OOM 排查](../../cases/JAVA-OOM.md)
- [systemd 服务启动失败排查](../../cases/SYSTEMD-SERVICE-FAILED.md)
