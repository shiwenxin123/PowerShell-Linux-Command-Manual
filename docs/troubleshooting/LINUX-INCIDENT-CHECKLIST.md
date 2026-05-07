# Linux 故障应急排查清单

这份清单面向值班、运维和开发排障场景。建议按顺序排查: 先确认现象，再看资源，再看日志，最后处理服务和配置。

## 1. 确认系统状态

```bash
# 系统版本
cat /etc/os-release

# 内核版本
uname -a

# 当前时间和运行时长
date
uptime

# 最近登录
last -n 10
```

## 2. CPU 飙高

```bash
# 实时查看资源
top

# 按 CPU 排序查看进程
ps aux --sort=-%cpu | head -n 10

# 查看指定进程线程
ps -T -p <PID>
```

处理建议:

- 先确认进程名称、启动用户和启动时间。
- 不确定进程用途时，不要直接 `kill -9`。
- Java、Node.js、Python 服务建议结合应用日志判断。

## 3. 内存不足

```bash
# 查看内存
free -h

# 按内存排序
ps aux --sort=-%mem | head -n 10

# 查看 OOM 记录
dmesg -T | grep -i "out of memory"
```

## 4. 磁盘空间满

```bash
# 查看磁盘空间
df -h

# 查看目录占用
du -sh /* 2>/dev/null

# 查找大文件
find / -type f -size +500M 2>/dev/null
```

处理建议:

- 优先清理日志、临时文件、旧备份。
- 删除前先确认文件是否仍被进程占用: `lsof | grep deleted`。
- 不建议直接删除数据库、容器、业务上传目录里的文件。

## 5. 服务启动失败

```bash
# 查看服务状态
systemctl status <service>

# 查看最近日志
journalctl -u <service> -n 100 --no-pager

# 查看启动耗时
systemd-analyze blame | head
```

## 6. 端口不通

```bash
# 查看监听
ss -tulnp

# 测试域名解析
nslookup example.com

# 测试端口
nc -vz 127.0.0.1 8080

# 查看防火墙
firewall-cmd --state 2>/dev/null || ufw status 2>/dev/null
```

## 7. 日志快速定位

```bash
# 查看系统日志
journalctl -xe --no-pager

# 搜索错误
grep -RniE "error|failed|exception|timeout" /var/log 2>/dev/null | head -n 50

# 实时看应用日志
tail -f /path/to/app.log
```

## 高危操作提醒

| 操作 | 风险 | 建议 |
| --- | --- | --- |
| `kill -9` | 可能造成数据未刷盘 | 优先正常停止服务 |
| `rm -rf` | 不可恢复删除 | 先确认路径和备份 |
| 清空日志 | 可能丢失排障证据 | 先备份或截取关键日志 |
| 修改防火墙 | 可能断开远程连接 | 保留当前 SSH 会话 |
