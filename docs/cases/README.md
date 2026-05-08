# 真实故障案例库

这里收集高频运维故障的排查路径。每个案例都按“现象 -> 快速判断 -> 排查命令 -> 常见原因 -> 处理建议 -> 高危提醒 -> 相关专题”的结构整理，适合值班、培训和应急排障。

## 按症状查找

| 现象 | 优先查看 |
| --- | --- |
| 页面打不开、网关错误 | [Nginx 502/504](NGINX-502-504.md)、[DNS 解析失败](DNS-RESOLUTION-FAILED.md)、[证书过期](CERTIFICATE-EXPIRED.md)、[TLS 证书链不完整](TLS-CHAIN-INCOMPLETE.md) |
| 服务端口不可用 | [端口被占用](PORT-IN-USE.md)、[Nginx 启动失败](NGINX-START-FAILED.md)、[MySQL 启动失败](MYSQL-START-FAILED.md)、[Redis 连接失败](REDIS-CONNECTION-FAILED.md) |
| 主机资源异常 | [磁盘空间满](DISK-FULL.md)、[CPU 飙高](CPU-HIGH.md)、[Java 服务 OOM](JAVA-OOM.md) |
| 容器或 Pod 异常 | [Docker 容器反复重启](DOCKER-RESTARTING.md)、[Pod CrashLoopBackOff](K8S-CRASHLOOPBACKOFF.md)、[ImagePullBackOff](K8S-IMAGEPULLBACKOFF.md)、[Kubernetes DNS 异常](K8S-DNS-FAILED.md) |
| 监控无数据或告警 | [Prometheus Target Down](PROMETHEUS-TARGET-DOWN.md)、[Grafana 无数据](GRAFANA-NO-DATA.md) |
| 远程登录失败 | [SSH 连接失败](SSH-CONNECTION-FAILED.md)、[DNS 解析失败](DNS-RESOLUTION-FAILED.md)、[端口被占用](PORT-IN-USE.md) |

## 案例列表

| 故障 | 文档 |
| --- | --- |
| 磁盘空间满 | [磁盘空间满排查](DISK-FULL.md) |
| CPU 飙高 | [CPU 飙高排查](CPU-HIGH.md) |
| 端口被占用 | [端口被占用排查](PORT-IN-USE.md) |
| SSH 连接失败 | [SSH 连接失败排查](SSH-CONNECTION-FAILED.md) |
| Nginx 启动失败 | [Nginx 启动失败排查](NGINX-START-FAILED.md) |
| Nginx 502/504 | [Nginx 502/504 排查](NGINX-502-504.md) |
| MySQL 启动失败 | [MySQL 启动失败排查](MYSQL-START-FAILED.md) |
| Redis 连接失败 | [Redis 连接失败排查](REDIS-CONNECTION-FAILED.md) |
| Java 服务 OOM | [Java 服务 OOM 排查](JAVA-OOM.md) |
| DNS 解析失败 | [DNS 解析失败排查](DNS-RESOLUTION-FAILED.md) |
| 证书过期 | [证书过期排查](CERTIFICATE-EXPIRED.md) |
| Docker 容器反复重启 | [Docker 容器反复重启排查](DOCKER-RESTARTING.md) |
| Docker Compose 启动失败 | [Docker Compose 启动失败排查](DOCKER-COMPOSE-FAILED.md) |
| Kubernetes Pod CrashLoopBackOff | [Pod CrashLoopBackOff 排查](K8S-CRASHLOOPBACKOFF.md) |
| Kubernetes ImagePullBackOff | [ImagePullBackOff 排查](K8S-IMAGEPULLBACKOFF.md) |
| Kubernetes DNS 异常 | [Kubernetes DNS 异常排查](K8S-DNS-FAILED.md) |
| TLS 证书链不完整 | [TLS 证书链不完整排查](TLS-CHAIN-INCOMPLETE.md) |
| Prometheus Target Down | [Prometheus Target Down 排查](PROMETHEUS-TARGET-DOWN.md) |
| Grafana 无数据 | [Grafana 无数据排查](GRAFANA-NO-DATA.md) |

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
