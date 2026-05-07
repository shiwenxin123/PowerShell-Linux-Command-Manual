# 系统安全加固

安全加固应按“账号、权限、服务、网络、日志、审计”的顺序推进。生产环境修改前建议先备份配置，并准备回滚方案。

## 账号与权限

```bash
# 查看当前用户
whoami

# 查看用户和组
id

# 查看登录记录
last -n 20

# 查看 sudo 配置
sudo -l
```

建议:

- 最小权限原则。
- 管理员操作保留审计记录。
- 不共享 root 密码。
- 不长期使用 `chmod 777`。

## SSH 加固

```bash
# 检查 SSH 配置语法
sshd -t

# 查看 SSH 服务状态
systemctl status sshd || systemctl status ssh

# 查看 SSH 日志
journalctl -u sshd -n 100 --no-pager
```

建议:

- 禁止弱密码。
- 使用密钥登录。
- 修改配置前保留当前登录会话。

## 防火墙

```bash
# firewalld
firewall-cmd --list-all

# iptables 备份
iptables-save > iptables.backup

# ufw
ufw status verbose
```

## 日志与审计

```bash
# 查看系统日志
journalctl -xe --no-pager

# 查看认证日志
grep -i "failed" /var/log/auth.log 2>/dev/null
```

## 延伸阅读

- [命令风险等级说明](../../security/RISK-LEVELS.md)
- [SSH 连接失败排查](../../cases/SSH-CONNECTION-FAILED.md)
