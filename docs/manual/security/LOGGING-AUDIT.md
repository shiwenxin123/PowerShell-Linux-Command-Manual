# 日志轮转、审计与系统日志

日志系统排查要关注三件事: 日志是否写入、是否轮转、是否能保留足够的审计证据。

## journalctl

```bash
# 查看最近系统日志
journalctl -xe --no-pager

# 查看指定服务日志
journalctl -u nginx -n 100 --no-pager

# 按时间查看
journalctl --since "1 hour ago"

# 实时查看
journalctl -f
```

### journald 持久化

```bash
# 编辑配置
sudo vi /etc/systemd/journald.conf
```

示例:

```ini
[Journal]
Storage=persistent
Compress=yes
Seal=yes
SystemMaxUse=10G
SystemKeepFree=5G
SystemMaxFileSize=100M
MaxRetentionSec=1month
ForwardToSyslog=yes
```

应用配置:

```bash
sudo systemctl restart systemd-journald
systemctl status systemd-journald
journalctl --disk-usage
```

常用高级查询:

```bash
# 多服务查询
journalctl -u nginx -u mysql

# 按优先级查询
journalctl -p err..alert

# 按时间窗口查询
journalctl --since today
journalctl --since "2026-03-13 09:00:00" --until "2026-03-13 17:00:00"
journalctl --since "-2h"

# JSON 输出
journalctl -u nginx -o json
journalctl -u nginx -o json-pretty

# 清理旧日志
journalctl --vacuum-time=1month
journalctl --vacuum-size=5G
```

## logrotate

```bash
# 查看 logrotate 主配置
cat /etc/logrotate.conf

# 查看应用配置
ls /etc/logrotate.d/

# 调试指定配置
sudo logrotate -d /etc/logrotate.conf

# 强制轮转
sudo logrotate -f /etc/logrotate.conf
```

示例:

```text
/var/log/app/*.log {
    daily
    rotate 14
    compress
    missingok
    notifempty
    copytruncate
}
```

生产配置示例:

```text
/var/log/custom/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root adm
    sharedscripts
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
```

注意:

- `copytruncate` 适合无法重启或 reload 的应用，但可能丢少量日志。
- 更推荐应用支持 reopen log 或配合服务 reload。

## rsyslog

```bash
# 查看服务状态
systemctl status rsyslog

# 查看配置
cat /etc/rsyslog.conf
ls /etc/rsyslog.d/

# 测试写入日志
logger "test rsyslog message"

# 查看系统日志
tail -n 50 /var/log/messages 2>/dev/null
tail -n 50 /var/log/syslog 2>/dev/null
```

### rsyslog 集中日志

```bash
# 主配置文件
sudo vi /etc/rsyslog.conf

# 自定义配置
sudo vi /etc/rsyslog.d/50-custom.conf
```

模板示例:

```text
$template HighPrecisionFormat,"%timestamp:::date-rfc3339% %HOSTNAME% %syslogtag%%msg:::sp-if-no-1st-sp%%msg:::drop-last-lf%\n"
$template JsonFormat,"{\"timestamp\":\"%timestamp:::date-rfc3339%\",\"host\":\"%HOSTNAME%\",\"tag\":\"%syslogtag%\",\"msg\":\"%msg:::json%\"}\n"
$template PerHostLog,"/var/log/remote/%HOSTNAME%/%PROGRAMNAME%.log"
```

远程接收和转发:

```text
# UDP 接收
module(load="imudp")
input(type="imudp" port="514")

# TCP 接收
module(load="imtcp")
input(type="imtcp" port="514")

# TCP 转发
*.* @@logserver.example.com:514

# UDP 转发
*.* @logserver.example.com:514

# 按程序名过滤
if $programname == 'sshd' then /var/log/sshd.log
& stop

# 同时写入本地和远程
*.* /var/log/all.log
*.* @@logserver.example.com:514
```

TLS 传输需要证书、CA 和服务端配置匹配，建议先在测试环境验证:

```text
module(load="imtcp" StreamDriver.Name="gtls" StreamDriver.Mode="1" StreamDriver.AuthMode="x509/name" PermittedPeer="*.example.com")
global(DefaultNetstreamDriver="gtls" DefaultNetstreamDriverCAFile="/etc/pki/rsyslog/ca.pem" DefaultNetstreamDriverCertFile="/etc/pki/rsyslog/server-cert.pem" DefaultNetstreamDriverKeyFile="/etc/pki/rsyslog/server-key.pem")
```

## auditd

```bash
# 查看服务状态
systemctl status auditd

# 查看规则
auditctl -l

# 搜索 sudo 执行
ausearch -x sudo

# 搜索最近拒绝
ausearch -m avc -ts recent

# 生成报告
aureport
```

示例规则:

```bash
# 监控 sudoers 修改
-w /etc/sudoers -p wa -k sudoers_changes

# 监控 passwd 修改
-w /etc/passwd -p wa -k passwd_changes
```

## 生产变更前检查

```bash
# 检查磁盘空间
df -h
du -sh /var/log/* 2>/dev/null

# 检查服务状态
systemctl status rsyslog
systemctl status systemd-journald
systemctl status auditd

# 备份配置
sudo cp /etc/rsyslog.conf /etc/rsyslog.conf.bak
sudo cp /etc/systemd/journald.conf /etc/systemd/journald.conf.bak
```

## 常见问题

| 问题 | 排查 |
| --- | --- |
| 日志文件过大 | `du -sh /var/log/*`、`logrotate -d` |
| journal 占用大 | `journalctl --disk-usage` |
| 日志没有写入 | 服务状态、权限、配置路径 |
| 审计规则不生效 | `auditctl -l`、`systemctl status auditd` |

## 高危提醒

- 不要直接删除正在写入的日志文件，可能导致空间不释放。
- 删除日志前确认是否需要保留排障和审计证据。
- 审计规则过多可能影响性能，需要按关键路径配置。
- 修改集中日志转发前，先确认网络、防火墙、证书和接收端容量。
- 清理日志优先使用 `journalctl --vacuum-*`、logrotate 或服务 reload，不要直接 `rm -f` 正在写入的文件。
