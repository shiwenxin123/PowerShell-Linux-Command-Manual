# 网关超时排查

## 现象

- 用户访问页面返回 `504 Gateway Timeout`、`upstream timed out` 或接口一直等待后失败。
- Nginx、Ingress、API Gateway、SLB/ALB 后面的应用实例仍可能是 Running 状态。

## 快速判断

```bash
# 查看网关错误日志
grep -Ei "timeout|upstream timed out|504" /var/log/nginx/error.log | tail -n 50

# 直接访问后端，确认是否绕过网关也慢
curl -I --connect-timeout 3 --max-time 10 http://127.0.0.1:8080/health

# 查看当前连接和等待情况
ss -antp | awk 'NR==1 || /:80|:443|:8080/'
```

## 排查命令

```bash
# Nginx 配置中查看超时参数
nginx -T | grep -Ei "proxy_(connect|read|send)_timeout|fastcgi_read_timeout|keepalive_timeout"

# 查看上游应用最近日志
journalctl -u <app-service> -n 200 --no-pager

# Kubernetes Ingress 场景
kubectl describe ingress <ingress-name> -n <namespace>
kubectl get endpoints <service-name> -n <namespace> -o wide
kubectl logs deploy/<deploy-name> -n <namespace> --tail=200

# 观察后端响应耗时
curl -w "connect=%{time_connect} starttransfer=%{time_starttransfer} total=%{time_total}\n" -o /dev/null -s http://<backend>/health
```

## 常见原因

- 后端接口本身慢，数据库、缓存或第三方接口阻塞。
- 网关超时时间小于后端实际处理时间。
- 上游连接池耗尽、线程池耗尽或实例数不足。
- Ingress/Service 指向的 Endpoints 不正确。
- 网络链路丢包、MTU 异常或防火墙策略导致长连接异常。

## 处理建议

- 先确认是“后端慢”还是“网关到后端链路异常”，不要只调大超时。
- 对慢接口增加应用日志、Trace ID、数据库慢查询和线程栈分析。
- 临时扩容后端实例或限流高耗时接口，降低网关等待堆积。
- 确需调整超时时，先灰度修改 `proxy_read_timeout`、Ingress 注解或网关策略。

## 高危提醒

- 盲目拉长超时时间可能放大连接堆积，导致网关 worker、应用线程池或数据库连接池被拖垮。
- 修改网关配置前先执行 `nginx -t` 或平台提供的配置校验。

## 相关专题

- [云服务器与负载均衡排查](../manual/cloud/CLOUD-LB-TROUBLESHOOTING.md)
- [Linux 网络排查](../manual/linux/NETWORK.md)
- [Nginx 502/504 排查](NGINX-502-504.md)
