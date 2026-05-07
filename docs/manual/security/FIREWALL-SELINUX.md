# 防火墙与 SELinux

防火墙和 SELinux 属于高风险变更。远程服务器操作前应保留当前 SSH 会话，并准备回滚命令。

## firewalld

```bash
# 查看状态
firewall-cmd --state

# 查看当前 zone
firewall-cmd --get-active-zones

# 查看规则
firewall-cmd --list-all

# 临时开放端口
sudo firewall-cmd --add-port=8080/tcp

# 永久开放端口
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# 删除端口
sudo firewall-cmd --permanent --remove-port=8080/tcp
sudo firewall-cmd --reload
```

## ufw

```bash
# 查看状态
sudo ufw status verbose

# 允许 SSH
sudo ufw allow 22/tcp

# 允许 HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 拒绝端口
sudo ufw deny 8080/tcp
```

## iptables

```bash
# 查看规则
sudo iptables -L -n -v

# 备份规则
sudo iptables-save > iptables.backup

# 允许端口
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
```

高危提醒: `iptables -F` 会清空规则，可能导致服务暴露或远程连接中断。

## nftables

```bash
# 查看规则
sudo nft list ruleset

# 查看表
sudo nft list tables
```

## SELinux

```bash
# 查看状态
getenforce
sestatus

# 临时切换为 Permissive
sudo setenforce 0

# 临时切换为 Enforcing
sudo setenforce 1
```

查看 SELinux 拒绝记录:

```bash
sudo ausearch -m avc -ts recent
sudo journalctl | grep -i selinux
```

## 排查顺序

1. 先确认服务是否监听: `ss -tulnp`。
2. 再确认本机访问是否正常: `curl 127.0.0.1:<port>`。
3. 再确认防火墙规则。
4. 最后检查 SELinux 或安全中心策略。

## 高危提醒

- 不要为了排障长期关闭防火墙或 SELinux。
- 修改远程服务器防火墙前保留当前 SSH 会话。
- 生产环境建议先添加允许规则，再删除旧规则。

延伸阅读: [命令风险等级说明](../../security/RISK-LEVELS.md)。
