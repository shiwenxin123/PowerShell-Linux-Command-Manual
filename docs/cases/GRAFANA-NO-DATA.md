# Grafana 无数据排查

## 现象

- Grafana 面板显示 `No data`。
- 同一数据源部分面板正常，部分面板无数据。
- 最近发布、迁移或改查询后指标消失。
- Prometheus、Loki、Elasticsearch 等数据源测试连接成功，但图表为空。

## 快速判断

```bash
# 检查 Grafana 服务
systemctl status grafana-server
journalctl -u grafana-server -n 100 --no-pager
```

在 Grafana 页面先确认:

- 时间范围是否正确。
- 变量是否选中了实际存在的环境、集群、命名空间或实例。
- 数据源是否选错。
- 查询语句在 Explore 中是否能返回数据。

## 排查命令

Prometheus:

```bash
# Prometheus 是否有数据
curl -G 'http://prometheus.example.com/api/v1/query' --data-urlencode 'query=up'

# 检查目标状态
curl -s http://prometheus.example.com/api/v1/targets
```

Loki:

```bash
# 查询标签
curl -G 'http://loki.example.com/loki/api/v1/labels'

# 查询日志
curl -G 'http://loki.example.com/loki/api/v1/query' --data-urlencode 'query={job!=""}'
```

Elasticsearch:

```bash
# 查看索引
curl -s http://elasticsearch.example.com:9200/_cat/indices?v

# 查看集群状态
curl -s http://elasticsearch.example.com:9200/_cluster/health?pretty
```

## 常见原因

- Grafana 时间范围选错。
- Dashboard 变量没有匹配到数据。
- 查询语句标签名、指标名或日志标签变更。
- 数据源地址、认证或组织权限配置错误。
- Prometheus target down，导致指标源头没有采集。
- Loki/Elasticsearch 索引或日志标签变更。
- 面板使用的 interval、rate 窗口过小或过大。

## 处理建议

- 先在 Explore 里运行最小查询，例如 `up` 或 `{job!=""}`。
- 再逐步加回变量、标签过滤和聚合条件。
- 如果只有某个 Dashboard 异常，优先检查变量和查询语句。
- 如果所有面板无数据，优先检查数据源连接、认证和后端采集链路。
- 对 Prometheus 面板，联动检查 [Prometheus Target Down 排查](PROMETHEUS-TARGET-DOWN.md)。

## 高危提醒

- 不要直接删除 Dashboard 或数据源，先导出 JSON 备份。
- 修改共享 Dashboard 变量会影响所有使用者。
- 为了“让图有数据”而扩大查询范围，可能导致数据源压力升高。
