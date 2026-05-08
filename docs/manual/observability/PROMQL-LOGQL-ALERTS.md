# PromQL、LogQL 与告警规则

监控告警不只是部署 Prometheus 和 Grafana，还需要能写查询、定位指标、配置告警规则，并理解告警为什么触发或没有触发。

## PromQL 基础

```promql
# 服务是否在线
up

# 指定 job
up{job="node"}

# CPU 使用率示例
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# 内存可用率
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100

# 磁盘使用率
100 - (node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"} * 100)
```

## PromQL 排查技巧

```promql
# 查看某个指标有哪些标签
count by(__name__) ({__name__=~"node_.*"})

# 查看 scrape 是否成功
up == 0

# 过去 5 分钟请求速率
rate(http_requests_total[5m])

# 95 分位延迟
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
```

## LogQL 基础

```logql
# 查询 app 标签
{app="nginx"}

# 包含 error
{app="nginx"} |= "error"

# 正则匹配
{app="nginx"} |~ "error|timeout|failed"

# JSON 解析
{app="api"} | json | status >= 500
```

## LogQL 统计

```logql
# 5 分钟错误日志数量
count_over_time({app="api"} |= "error" [5m])

# 按状态码统计
sum by(status) (count_over_time({app="nginx"} | json [5m]))
```

## Prometheus 告警规则示例

```yaml
groups:
  - name: node-alerts
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Instance down"
          description: "{{ $labels.instance }} has been down for more than 2 minutes."

      - alert: DiskUsageHigh
        expr: 100 - (node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"} * 100) > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Disk usage high"
          description: "{{ $labels.instance }} disk usage is above 85%."
```

## 告警不触发排查

```bash
# 查看 Prometheus 规则
curl -s http://127.0.0.1:9090/api/v1/rules

# 查看告警
curl -s http://127.0.0.1:9090/api/v1/alerts

# 查看 Alertmanager 告警
curl -s http://127.0.0.1:9093/api/v2/alerts
```

排查重点:

- PromQL 是否有数据。
- `for` 时间是否还没满足。
- label 是否匹配路由规则。
- Alertmanager 是否收到告警。
- silence 是否屏蔽告警。

## 告警规则建议

- 告警表达式要能直接指向影响。
- 避免过度敏感导致告警风暴。
- 为每条告警写清楚 summary 和 description。
- 告警标签至少包含 severity、service、instance。

## 相关案例

- [Prometheus Target Down 排查](../../cases/PROMETHEUS-TARGET-DOWN.md)
- [Grafana 无数据排查](../../cases/GRAFANA-NO-DATA.md)
- [CPU 飙高排查](../../cases/CPU-HIGH.md)
- [磁盘空间满排查](../../cases/DISK-FULL.md)
