# Prometheus Target Down 排查

## 现象

- Prometheus 页面中 Target 状态为 `DOWN`。
- 告警出现 `TargetDown`、`up == 0`。
- Grafana 指标断点或某些实例指标消失。
- Exporter 进程存在，但 Prometheus 抓取失败。

## 快速判断

```bash
# 查看 Prometheus 服务状态
systemctl status prometheus

# 查看 exporter 端口
ss -tulnp | grep -E '9100|9113|9121|9187|9090'

# 本机直接访问 exporter
curl -I http://127.0.0.1:9100/metrics
```

Kubernetes 环境:

```bash
kubectl get pods -A | grep -i prometheus
kubectl get servicemonitor,podmonitor -A
kubectl get endpoints -A | grep -i exporter
```

## 排查命令

```bash
# 查看 Prometheus 配置
promtool check config /etc/prometheus/prometheus.yml

# 查看抓取目标配置
grep -n "job_name\\|targets" /etc/prometheus/prometheus.yml

# 测试目标连通性
curl -v http://<target>:<port>/metrics

# 查看 Prometheus 日志
journalctl -u prometheus -n 100 --no-pager

# 查看 exporter 日志
journalctl -u node_exporter -n 100 --no-pager
```

Kubernetes 环境:

```bash
# 查看 Prometheus Operator 相关资源
kubectl describe servicemonitor <name> -n <namespace>
kubectl describe podmonitor <name> -n <namespace>

# 查看 Prometheus 日志
kubectl logs -n <monitoring-namespace> <prometheus-pod>

# 从集群内测试 exporter
kubectl run curl-test --rm -it --image=curlimages/curl --restart=Never -- curl -v http://<service>.<namespace>:<port>/metrics
```

## 常见原因

- Exporter 进程未启动或端口未监听。
- Prometheus 配置中的目标地址、端口或路径错误。
- 防火墙、安全组、NetworkPolicy 阻断抓取。
- `/metrics` 路径返回非 200 状态码。
- ServiceMonitor/PodMonitor 标签选择器不匹配。
- Prometheus 重新加载配置失败。
- TLS、Basic Auth 或 Bearer Token 配置不匹配。

## 处理建议

- 先确认 `curl http://target:port/metrics` 是否能返回指标。
- 再确认 Prometheus 配置、ServiceMonitor 选择器和目标标签。
- 修改配置后先用 `promtool check config`。
- Kubernetes 中优先检查 Service、Endpoints、ServiceMonitor 三者是否匹配。

```bash
# 重新加载 Prometheus，视部署方式而定
curl -X POST http://127.0.0.1:9090/-/reload
systemctl reload prometheus
```

## 高危提醒

- 不要只关闭告警，应先确认监控缺口是否影响生产发现能力。
- 修改全局 scrape interval 或 relabel 规则前，评估 Prometheus 负载和指标基数。
- 生产环境不要随意暴露 `/metrics` 到公网。
