# 集中日志与监控告警

集中日志和监控告警的目标是快速回答三个问题: 是否采集到了、是否存储正常、是否能查询和告警。

## Prometheus

```bash
# 查看服务状态
systemctl status prometheus

# 检查端口
ss -tulnp | grep ':9090'

# 查看 targets
curl -s http://127.0.0.1:9090/api/v1/targets

# 查询 up 指标
curl -s 'http://127.0.0.1:9090/api/v1/query?query=up'
```

常见问题:

- target down。
- scrape timeout。
- label 配置不一致。
- PromQL 查询为空。

## Node Exporter

```bash
# 查看服务状态
systemctl status node_exporter

# 检查端口
ss -tulnp | grep ':9100'

# 查看指标
curl -s http://127.0.0.1:9100/metrics | head
```

## Alertmanager

```bash
# 查看服务状态
systemctl status alertmanager

# 检查端口
ss -tulnp | grep ':9093'

# 查看告警
curl -s http://127.0.0.1:9093/api/v2/alerts
```

## Grafana

```bash
# 查看服务状态
systemctl status grafana-server

# 检查端口
ss -tulnp | grep ':3000'

# 查看日志
journalctl -u grafana-server -n 100 --no-pager
```

常见问题:

- 数据源连接失败。
- Dashboard 变量为空。
- 时间范围不正确。
- PromQL 查询错误。

## Loki 与 Promtail

```bash
# Loki
systemctl status loki
ss -tulnp | grep ':3100'

# Promtail
systemctl status promtail
journalctl -u promtail -n 100 --no-pager
```

排查重点:

- Promtail 是否读取到日志文件。
- label 是否符合查询条件。
- Loki 是否可写入。
- 日志时间戳是否异常。

## ELK/Elastic Stack

```bash
# Elasticsearch 健康
curl -s http://127.0.0.1:9200/_cluster/health?pretty

# Logstash 状态
systemctl status logstash
journalctl -u logstash -n 100 --no-pager

# Kibana 状态
systemctl status kibana
ss -tulnp | grep ':5601'
```

## 排查顺序

1. Agent/exporter 是否运行。
2. 端口是否监听。
3. 采集端是否能访问服务端。
4. 服务端是否写入成功。
5. 查询语句和时间范围是否正确。
6. 告警规则是否被加载。

## 常见现象

| 现象 | 优先排查 |
| --- | --- |
| 监控没有数据 | exporter、Prometheus targets、网络 |
| 告警不触发 | PromQL、规则加载、Alertmanager |
| 日志查不到 | agent、路径、label、时间范围 |
| Dashboard 空白 | 数据源、变量、时间范围 |

## 相关案例

- [Prometheus Target Down 排查](../../cases/PROMETHEUS-TARGET-DOWN.md)
- [Grafana 无数据排查](../../cases/GRAFANA-NO-DATA.md)
- [Kubernetes DNS 异常排查](../../cases/K8S-DNS-FAILED.md)
