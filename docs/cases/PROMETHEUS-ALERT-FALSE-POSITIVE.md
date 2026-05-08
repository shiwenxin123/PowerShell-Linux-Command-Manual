# Prometheus 告警规则误报排查

## 现象

- 服务实际正常，但 Prometheus、Alertmanager 或通知群持续触发告警。
- 告警只在发布、扩缩容、短暂抖动或指标缺失时出现。

## 快速判断

```bash
# 查看目标抓取状态
curl -s http://<prometheus>:9090/api/v1/targets | jq '.data.activeTargets[] | {job:.labels.job, health:.health, lastError:.lastError}'

# 查询告警表达式原始值
curl -G http://<prometheus>:9090/api/v1/query --data-urlencode 'query=<alert_expr>'

# 查看当前告警
curl -s http://<prometheus>:9090/api/v1/alerts | jq '.data.alerts[] | {name:.labels.alertname, state:.state, value:.value}'
```

## 排查命令

```promql
# 检查是否为瞬时抖动
avg_over_time(up{job="<job>"}[10m])

# 检查指标是否缺失
absent(up{job="<job>"})

# 检查标签维度是否过宽
count by (job, instance) (up{job="<job>"})
```

```bash
# 查看规则文件
promtool check rules rules/*.yml

# 查看 Alertmanager 静默和路由
amtool silence query
amtool config routes show
```

## 常见原因

- 告警表达式使用瞬时值，缺少 `for` 或时间窗口。
- 发布、滚动重启、扩缩容期间实例短暂消失。
- 标签匹配过宽，把测试环境或临时实例纳入生产告警。
- 指标采集失败被误判为业务异常。
- 阈值没有结合业务峰谷和历史基线。

## 处理建议

- 为抖动型告警增加 `for`，例如 `for: 5m` 或 `for: 10m`。
- 区分指标缺失、抓取失败和业务异常，分别使用不同告警级别。
- 给规则增加环境、集群、服务等级等标签过滤。
- 发布窗口可使用 Alertmanager silence，但不要长期静默真实风险。
- 用 `promtool check rules` 和历史查询回放验证规则。

## 高危提醒

- 不要因为误报直接删除告警规则；应先降低级别、调整窗口或加标签过滤。
- 修改告警路由和静默规则前确认不会屏蔽生产关键告警。

## 相关专题

- [PromQL、LogQL 与告警规则](../manual/observability/PROMQL-LOGQL-ALERTS.md)
- [集中日志与监控告警](../manual/observability/LOGGING-MONITORING.md)
- [Prometheus Target Down 排查](PROMETHEUS-TARGET-DOWN.md)
