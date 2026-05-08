# DNS 解析失败排查

## 现象

- 可以 Ping IP，但不能访问域名。
- `curl` 提示 `Could not resolve host`。
- 应用日志出现 DNS 解析失败。

## 快速判断

```bash
ping 8.8.8.8
ping example.com
cat /etc/resolv.conf
```

## 排查命令

```bash
# 查询 DNS
nslookup example.com
dig example.com

# 查看 systemd-resolved 状态
systemctl status systemd-resolved 2>/dev/null

# 查看路由
ip route

# 测试指定 DNS
nslookup example.com 8.8.8.8
```

## 常见原因

- DNS 服务器不可达。
- `/etc/resolv.conf` 配置错误。
- 内网域名需要特定 DNS。
- 防火墙拦截 UDP/TCP 53。
- 容器或 Pod 内 DNS 配置异常。

## 处理建议

- 先确认 IP 网络是否正常。
- 再确认 DNS 服务器是否可达。
- 内网域名不要随意切到公网 DNS。
- Kubernetes 场景需要检查 CoreDNS 和 Pod DNS 配置。

## 高危提醒

- 修改 DNS 配置可能影响整台机器的所有域名访问。
- 生产环境修改前记录原始 `/etc/resolv.conf`。

## 相关专题

- [Linux 网络排查](../manual/linux/NETWORK.md)
- [云网络与负载均衡排查](../manual/cloud/CLOUD-LB-TROUBLESHOOTING.md)
- [Kubernetes 进阶排查](../manual/kubernetes/ADVANCED-TROUBLESHOOTING.md)
