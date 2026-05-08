# 负载均衡健康检查失败排查

## 现象

- 云负载均衡控制台显示后端实例 `unhealthy`、`异常` 或健康检查失败。
- 用户访问间歇性失败，直接访问单台后端可能正常。

## 快速判断

```bash
# 在后端本机确认服务端口监听
ss -tulnp | grep -E ':80|:443|:8080'

# 从同网段机器访问健康检查路径
curl -I --connect-timeout 3 --max-time 5 http://<backend-ip>:<port>/health

# 查看 Web 服务日志
tail -n 100 /var/log/nginx/access.log
tail -n 100 /var/log/nginx/error.log
```

## 排查命令

```bash
# 检查本机防火墙
firewall-cmd --list-all 2>/dev/null || true
iptables -S 2>/dev/null | head
nft list ruleset 2>/dev/null | head

# 检查应用健康接口状态码
curl -s -o /dev/null -w "%{http_code} %{time_total}\n" http://127.0.0.1:<port>/health

# Kubernetes Service 场景
kubectl get svc,endpoints -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
```

## 常见原因

- 健康检查路径、端口、协议与后端实际配置不一致。
- 健康检查期望 `200`，但应用返回 `301`、`302`、`401`、`403` 或 `5xx`。
- 安全组、防火墙、NetworkPolicy 未放行负载均衡探测源。
- 应用启动慢，健康检查阈值过低。
- 后端只监听 `127.0.0.1`，没有监听实例网卡地址。

## 处理建议

- 单独提供轻量健康检查接口，例如 `/healthz`，避免依赖数据库重查询。
- 核对负载均衡健康检查协议、端口、路径、成功状态码和超时阈值。
- 放行云厂商健康检查源地址或安全组引用。
- 对启动慢的服务适当增加健康检查宽限时间和失败阈值。

## 高危提醒

- 不要为了让健康检查通过而让所有异常都返回 `200`，否则会把真实故障实例继续留在流量池中。
- 批量摘除后端前确认至少保留足够健康实例。

## 相关专题

- [云服务器与负载均衡排查](../manual/cloud/CLOUD-LB-TROUBLESHOOTING.md)
- [Kubernetes 进阶排查](../manual/kubernetes/ADVANCED-TROUBLESHOOTING.md)
- [Nginx 502/504 排查](NGINX-502-504.md)
