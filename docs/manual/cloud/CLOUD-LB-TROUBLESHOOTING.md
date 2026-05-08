# 云服务器与负载均衡排查

云上故障排查要同时看系统内部和云平台侧配置。很多“服务不通”并不是服务本身问题，而是安全组、负载均衡、NAT、路由或健康检查异常。

## 云服务器基础检查

```bash
# 系统状态
uptime
free -h
df -h

# 网络地址和路由
ip addr
ip route

# 监听端口
ss -tulnp
```

PowerShell:

```powershell
Get-ComputerInfo
Get-NetIPConfiguration
Get-NetTCPConnection -State Listen
```

## 安全组与防火墙

排查顺序:

1. 应用是否监听正确端口。
2. 本机防火墙是否允许。
3. 云安全组是否允许。
4. 网络 ACL 是否允许。
5. 客户端源 IP 是否在允许范围内。

Linux:

```bash
ss -tulnp | grep ':80'
firewall-cmd --list-all 2>/dev/null
ufw status 2>/dev/null
```

## 负载均衡排查

重点检查:

- 后端服务器是否加入负载均衡。
- 后端端口是否正确。
- 健康检查路径是否正确。
- 健康检查协议是否匹配 HTTP/TCP/HTTPS。
- 证书是否绑定正确。
- 后端安全组是否允许负载均衡访问。

后端机器检查:

```bash
# 本机访问
curl -I http://127.0.0.1:<port>

# 从同网段机器访问
curl -I http://<backend-ip>:<port>

# 查看访问日志
tail -f /var/log/nginx/access.log
```

## NAT 与公网访问

常见问题:

- 云服务器没有公网 IP。
- 出口依赖 NAT 网关但路由未配置。
- 安全组只允许入站，不允许出站。
- DNS 解析到错误地址。

排查命令:

```bash
curl -I https://example.com
curl ifconfig.me
ip route
nslookup example.com
```

## 云盘与快照

```bash
# 查看磁盘
lsblk
df -h

# 查看文件系统
blkid

# 查看挂载
findmnt
```

建议:

- 扩容云盘后，还需要在系统内扩分区或文件系统。
- 做高危磁盘操作前先创建快照。
- 不要只在控制台扩容后就认为系统内空间已扩大。

## 快速定位表

| 现象 | 优先排查 |
| --- | --- |
| 公网访问不通 | 安全组、公网 IP、负载均衡、应用监听 |
| 内网访问不通 | 路由、安全组、本机防火墙 |
| 负载均衡健康检查失败 | 后端端口、健康检查路径、安全组 |
| 服务器能访问 IP 不能访问域名 | DNS、NAT、出站规则 |
| 云盘扩容后空间不变 | 分区和文件系统扩容 |

## 相关案例

- [Nginx 502/504 排查](../../cases/NGINX-502-504.md)
- [DNS 解析失败排查](../../cases/DNS-RESOLUTION-FAILED.md)
- [TLS 证书链不完整排查](../../cases/TLS-CHAIN-INCOMPLETE.md)
- [端口被占用排查](../../cases/PORT-IN-USE.md)
- [Kubernetes Node NotReady 排查](../../cases/K8S-NODE-NOTREADY.md)
