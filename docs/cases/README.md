# 真实故障案例库

这里收集高频运维故障的排查路径。每个案例都按“现象 -> 快速判断 -> 排查命令 -> 常见原因 -> 处理建议 -> 高危提醒 -> 相关专题”的结构整理，适合值班、培训和应急排障。

## 按症状查找

| 现象 | 优先查看 |
| --- | --- |
| 页面打不开、网关错误 | [网关超时](GATEWAY-TIMEOUT.md)、[负载均衡健康检查失败](LB-HEALTH-CHECK-FAILED.md)、[Nginx 502/504](NGINX-502-504.md)、[DNS 解析失败](DNS-RESOLUTION-FAILED.md)、[证书过期](CERTIFICATE-EXPIRED.md)、[TLS 证书链不完整](TLS-CHAIN-INCOMPLETE.md) |
| 服务端口不可用 | [端口被占用](PORT-IN-USE.md)、[Nginx 启动失败](NGINX-START-FAILED.md)、[MySQL 启动失败](MYSQL-START-FAILED.md)、[Redis 连接失败](REDIS-CONNECTION-FAILED.md) |
| 服务启动失败 | [systemd 服务启动失败](SYSTEMD-SERVICE-FAILED.md)、[Nginx 启动失败](NGINX-START-FAILED.md)、[Docker Compose 启动失败](DOCKER-COMPOSE-FAILED.md) |
| 主机资源异常 | [磁盘空间满](DISK-FULL.md)、[CPU 飙高](CPU-HIGH.md)、[Java 服务 OOM](JAVA-OOM.md)、[Linux Permission denied](LINUX-PERMISSION-DENIED.md) |
| 容器或 Pod 异常 | [Docker 容器反复重启](DOCKER-RESTARTING.md)、[Docker 镜像拉取失败](DOCKER-IMAGE-PULL-FAILED.md)、[Pod CrashLoopBackOff](K8S-CRASHLOOPBACKOFF.md)、[ImagePullBackOff](K8S-IMAGEPULLBACKOFF.md)、[Kubernetes Node NotReady](K8S-NODE-NOTREADY.md)、[Kubernetes DNS 异常](K8S-DNS-FAILED.md) |
| 数据库连接异常 | [数据库连接池耗尽](DB-CONNECTION-POOL-EXHAUSTED.md)、[MySQL 启动失败](MYSQL-START-FAILED.md)、[MySQL 连接数打满](MYSQL-TOO-MANY-CONNECTIONS.md)、[Redis 连接失败](REDIS-CONNECTION-FAILED.md) |
| 中间件连接异常 | [消息队列连接失败](MESSAGE-QUEUE-CONNECTION-FAILED.md)、[Redis 连接失败](REDIS-CONNECTION-FAILED.md)、[数据库连接池耗尽](DB-CONNECTION-POOL-EXHAUSTED.md) |
| 监控无数据或告警 | [Prometheus 告警规则误报](PROMETHEUS-ALERT-FALSE-POSITIVE.md)、[Prometheus Target Down](PROMETHEUS-TARGET-DOWN.md)、[Grafana 无数据](GRAFANA-NO-DATA.md) |
| 远程登录失败 | [SSH 连接失败](SSH-CONNECTION-FAILED.md)、[DNS 解析失败](DNS-RESOLUTION-FAILED.md)、[端口被占用](PORT-IN-USE.md) |

## 案例列表

| 故障 | 文档 |
| --- | --- |
| 磁盘空间满 | [磁盘空间满排查](DISK-FULL.md) |
| CPU 飙高 | [CPU 飙高排查](CPU-HIGH.md) |
| 端口被占用 | [端口被占用排查](PORT-IN-USE.md) |
| SSH 连接失败 | [SSH 连接失败排查](SSH-CONNECTION-FAILED.md) |
| Linux Permission denied | [Linux Permission denied 排查](LINUX-PERMISSION-DENIED.md) |
| systemd 服务启动失败 | [systemd 服务启动失败排查](SYSTEMD-SERVICE-FAILED.md) |
| Nginx 启动失败 | [Nginx 启动失败排查](NGINX-START-FAILED.md) |
| Nginx 502/504 | [Nginx 502/504 排查](NGINX-502-504.md) |
| 网关超时 | [网关超时排查](GATEWAY-TIMEOUT.md) |
| 负载均衡健康检查失败 | [负载均衡健康检查失败排查](LB-HEALTH-CHECK-FAILED.md) |
| MySQL 启动失败 | [MySQL 启动失败排查](MYSQL-START-FAILED.md) |
| MySQL 连接数打满 | [MySQL 连接数打满排查](MYSQL-TOO-MANY-CONNECTIONS.md) |
| 数据库连接池耗尽 | [数据库连接池耗尽排查](DB-CONNECTION-POOL-EXHAUSTED.md) |
| Redis 连接失败 | [Redis 连接失败排查](REDIS-CONNECTION-FAILED.md) |
| 消息队列连接失败 | [消息队列连接失败排查](MESSAGE-QUEUE-CONNECTION-FAILED.md) |
| Java 服务 OOM | [Java 服务 OOM 排查](JAVA-OOM.md) |
| DNS 解析失败 | [DNS 解析失败排查](DNS-RESOLUTION-FAILED.md) |
| 证书过期 | [证书过期排查](CERTIFICATE-EXPIRED.md) |
| Docker 容器反复重启 | [Docker 容器反复重启排查](DOCKER-RESTARTING.md) |
| Docker 镜像拉取失败 | [Docker 镜像拉取失败排查](DOCKER-IMAGE-PULL-FAILED.md) |
| Docker Compose 启动失败 | [Docker Compose 启动失败排查](DOCKER-COMPOSE-FAILED.md) |
| Kubernetes Pod CrashLoopBackOff | [Pod CrashLoopBackOff 排查](K8S-CRASHLOOPBACKOFF.md) |
| Kubernetes ImagePullBackOff | [ImagePullBackOff 排查](K8S-IMAGEPULLBACKOFF.md) |
| Kubernetes Node NotReady | [Kubernetes Node NotReady 排查](K8S-NODE-NOTREADY.md) |
| Kubernetes DNS 异常 | [Kubernetes DNS 异常排查](K8S-DNS-FAILED.md) |
| TLS 证书链不完整 | [TLS 证书链不完整排查](TLS-CHAIN-INCOMPLETE.md) |
| Prometheus Target Down | [Prometheus Target Down 排查](PROMETHEUS-TARGET-DOWN.md) |
| Grafana 无数据 | [Grafana 无数据排查](GRAFANA-NO-DATA.md) |
| Prometheus 告警规则误报 | [Prometheus 告警规则误报排查](PROMETHEUS-ALERT-FALSE-POSITIVE.md) |

## 案例模板

完整写作说明见 [故障案例写作模板](CASE-TEMPLATE.md)。

```markdown
# 案例标题

## 现象

## 快速判断

## 排查命令

## 常见原因

## 处理建议

## 高危提醒

## 相关专题
```
