# SSH 连接失败排查

## 现象

- SSH 连接超时。
- 提示 `Connection refused`。
- 提示 `Permission denied`。
- 登录后立刻断开。

## 快速判断

从客户端开始确认网络、端口和认证。

```bash
ping <server>
nc -vz <server> 22
ssh -vvv user@server
```

## 排查命令

```bash
# 查看 SSH 服务
systemctl status sshd || systemctl status ssh

# 查看监听端口
ss -tulnp | grep ':22'

# 查看认证日志
journalctl -u sshd -n 100 --no-pager
```

## 常见原因

- 服务器不可达或安全组未放通。
- SSH 服务未启动。
- 防火墙阻断 22 端口。
- 用户名、密码或密钥错误。
- `sshd_config` 配置限制登录。

## 处理建议

- 云服务器先检查安全组和防火墙。
- 内网服务器先确认路由和堡垒机策略。
- 修改 SSH 配置前先保留一个已登录会话。
- 修改配置后执行 `sshd -t` 检查语法。

## 高危提醒

- 不要在远程会话里直接停止 SSH 服务后退出。
- 修改防火墙规则前确认不会阻断当前管理通道。

## 相关专题

- [Linux 网络排查](../manual/linux/NETWORK.md)
- [安全加固与基线检查](../manual/security/HARDENING.md)
- [防火墙、SELinux 与网络安全](../manual/security/FIREWALL-SELINUX.md)
