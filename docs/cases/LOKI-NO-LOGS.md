# Loki 日志查询为空排查

## 现象

- Grafana Explore 选择 Loki 数据源后显示 `No data`，同一时间范围内 Prometheus 指标仍然有数据。
- `logcli` 或 Loki HTTP 接口返回 HTTP 200，`resultType` 为 `streams`，`result` 是空数组。
- 只有某个应用、命名空间或 job 为空，`{job="example-app"}` 没有行，其他 job 有日志。
- 采集端机器上的日志文件在增长，Loki 里仍然查不到。
- 查询直接报 400，或采集端日志出现 `entry too far behind`、`429`、`max streams`。这和“查询成功但没有行”不是同一个故障，要分开处理。

空结果只说明这条 LogQL 在这个时间范围没有命中。它不说明 Loki 进程一定停了。

## 快速判断

三层各看一次只读接口。端口以现场配置为准: Promtail 常见 `9080`，Grafana Alloy 常见 `12345`，Loki 常见 `3100`。

```bash
# 采集端。两个单元往往只会存在一个
systemctl status promtail --no-pager
systemctl status alloy --no-pager

# Loki 是否就绪，以及现在有哪些标签
curl -sS http://127.0.0.1:3100/ready
curl -sS http://127.0.0.1:3100/loki/api/v1/labels
```

在 Grafana Explore 里把时间范围调到最近 1 小时，数据源选 Loki，先跑 `{job="example-app"}`。如果标签接口里根本没有 `job` 这个名字，查询为空是选择器写错，不是面板坏了。

多租户 Loki 没带租户头时，可能返回空标签，也可能返回 401，取决于 `auth_enabled` 和网关。怀疑租户时再加一次:

```bash
curl -sS -H 'X-Scope-OrgID: example' http://127.0.0.1:3100/loki/api/v1/labels
```

`example` 换成现场租户名。不要把生产租户名贴到公开记录里。

## 排查命令

### 采集端

Promtail 仍常见于现有集群。Grafana Alloy 是后续采集器，配置格式不同，空查询的现象一样。先确认哪个在运行。

```bash
systemctl status promtail --no-pager
systemctl status alloy --no-pager
journalctl -u promtail -n 100 --no-pager
journalctl -u alloy -n 100 --no-pager
```

```bash
# Promtail 内置页面。配置改过端口时不要死记 9080
curl -sS http://127.0.0.1:9080/ready
curl -sS http://127.0.0.1:9080/targets

# Alloy 常见端口
curl -sS http://127.0.0.1:12345/ready
```

`/targets` 里对应任务不是 `ready`，或文件路径不存在，日志不会进入 Loki。再看有没有把行送出去、有没有被丢弃:

```bash
curl -sS http://127.0.0.1:9080/metrics | grep -E 'promtail_sent_entries_total|promtail_dropped_entries_total'
```

Alloy 的指标名不同。以 `alloy` 或 `loki` 组件自己的 metrics 为准，不要因为 grep 不到 `promtail_` 就判断没有采集。

Kubernetes 里采集器通常是 DaemonSet:

```bash
kubectl get pods -A | grep -E 'promtail|alloy|fluent-bit'
kubectl logs -n example daemonset/promtail --tail=80
kubectl logs -n example daemonset/alloy --tail=80
```

采集配置里经常有租户和推送地址。只查看 job、路径和标签，不要把完整配置贴到工单:

```bash
# 路径因安装方式变化。文件不存在就改看 DaemonSet 的 ConfigMap
grep -nE 'job_name|__path__|loki.source|url:' /etc/promtail/config.yml
```

日志文件有内容、采集目标也是 ready，但 Loki 仍为空时，看采集端是否报推送失败:

```bash
journalctl -u promtail -n 200 --no-pager | grep -E 'error|429|500|entry too far|timestamp'
```

`entry too far behind` 或 `too far in the future` 表示日志时间戳落在 Loki 拒绝窗口外。文件里看得到旧行，查询最近 15 分钟会一直为空。

positions 文件只查看，不删除:

```bash
ls -l /var/lib/promtail/positions.yaml
```

路径以采集配置为准。删掉 positions 会让采集器从头重读或跳过一段，可能重复灌入大量日志。

### Loki 服务端

```bash
systemctl status loki --no-pager
curl -sS http://127.0.0.1:3100/ready
curl -sS http://127.0.0.1:3100/metrics | grep -E 'loki_distributor_lines_received_total|loki_discarded_samples_total'
journalctl -u loki -n 200 --no-pager | grep -E 'discarded|rate limit|max_streams|entry too far|403|429'
```

`loki_distributor_lines_received_total` 不增加，说明推送没到这台 Loki，继续查采集端地址和网络。`loki_discarded_samples_total` 增加，说明请求到了但被限制丢掉，查询为空是丢弃，不是选择器拼写的唯一原因。丢弃原因以日志里的 `reason` 为准，例如 `rate_limited`、`stream_limit`、`line_too_long`。

确认标签实际存在后，再查行。Loki 2.9 和 3.x 都使用这个查询接口。时间戳单位是纳秒。`date -d` 适用于 GNU date，本手册的 Linux 排查机可用:

```bash
END=$(date -u +%s)000000000
START=$(date -u -d '1 hour ago' +%s)000000000
curl -sS -G 'http://127.0.0.1:3100/loki/api/v1/query_range' \
  --data-urlencode 'query={job="example-app"}' \
  --data-urlencode "start=${START}" \
  --data-urlencode "end=${END}" \
  --data-urlencode 'limit=20'

curl -sS 'http://127.0.0.1:3100/loki/api/v1/label/job/values'
```

怎么读结果:

| 结果 | 含义 | 下一步 |
| --- | --- | --- |
| HTTP 200 且 `result` 有 streams | Loki 有数据 | 转到 Grafana 数据源和时间范围 |
| HTTP 200 且 `result` 为 `[]` | 查询执行了，但没有命中 | 对一下标签值和时间范围 |
| HTTP 400 | LogQL 语法错误，或查询窗口超过限制 | 先改成只有一个标签的选择器 |
| 标签接口没有 `example-app` | 采集端没打出这个标签，或租户不对 | 回到采集端和 `X-Scope-OrgID` |

Loki 3 可能因为客户端发送了服务端未打开的 structured metadata 而丢弃推送。现象在 Loki 日志和 discarded 指标里，不在 Grafana 面板配置里。

可用的 LogQL 从标签接口里真实存在的值开始:

```logql
{job="example-app"}
{namespace="example", app="example-app"} |= "error"
```

选择器至少要有一个标签匹配。`{}` 会被拒绝。不要在还没有确认标签时加上很宽的 `|~` 正则，大查询会打满查询器或直接 400。

### Grafana 查询端

Loki 的 `query_range` 已经有数据时，Grafana 仍然为空，就只查查询端:

- Explore 的数据源是 Loki，不是 Prometheus 或 Elasticsearch。
- 时间范围覆盖 `query_range` 使用的同一段。面板右上角停在 5 分钟时，会看不到更早的行。
- 数据源 URL 指向 Loki 根地址，例如 `http://loki.example.com:3100`。Grafana 会自己访问 `/loki/api/v1`。URL 如果已经包含重复路径，测试连接可能成功而查询为空或 404。
- 多租户时，数据源的 Custom HTTP Header 含 `X-Scope-OrgID`，并且和组织里保存的租户一致。
- Dashboard 变量没有把 `job` 设成一个不存在的值。变量为空时，先在 Explore 里写死 `{job="example-app"}`。

```bash
systemctl status grafana-server --no-pager
journalctl -u grafana-server -n 100 --no-pager | grep -Ei 'loki|datasource'
```

Grafana 日志里认证失败时，先改数据源凭据。不要为了查空日志去关闭 Loki 或 Grafana 的认证。

## 常见原因

- 采集器没运行，或 `/targets` 里的文件路径、Pod 标签选择器不匹配。
- LogQL 标签名和采集配置不一致。配置里是 `app`，查询写了 `job`。
- 时间范围太窄，或日志时间戳是旧文件里的历史时间。
- 推送被 Loki 拒绝: 超出 ingestion 时间窗口、流数量、行长度或速率限制。
- 多租户请求少了 `X-Scope-OrgID`，查到的是空租户。
- Grafana 数据源 URL、组织权限或 Header 与直接 curl Loki 时不一致。
- Promtail 与 Alloy 只有一个应在运行。两个同时推送不是本案例的修复方法；先确认哪个才是当前采集器。

## 处理建议

1. 用 `/loki/api/v1/label/job/values` 的返回值重写查询，把时间范围放到最近 1 小时。这一步只改查询，不改采集配置。
2. curl 为空、采集目标不是 ready: 修正路径或标签后，再启动或重载采集器。重载会改变采集进程，先在测试目标上确认配置语法。

    ```bash
    # Promtail 是否支持校验，取决于发行版里的 promtail 版本。失败就不要 reload
    promtail -config.file=/etc/promtail/config.yml -check-syntax
    sudo systemctl reload promtail
    ```

    Alloy 的配置文件和检查命令不同。不要把 Promtail 的 `-check-syntax` 用到 Alloy 上。Alloy 以 `alloy` 服务自己的文档或 `alloy --help` 为准。

3. 采集日志已经出现 `entry too far behind`: 修正应用时间戳或采集端时间，而不是把 Loki 的拒绝窗口改到无限大。放宽窗口会让过期日志一次性进入，查询和存储都会变重。
4. discarded 指标持续增加: 按日志里的 `reason` 处理超限，例如降低新标签的基数、截短超长行。不要直接关闭限制。
5. curl 有数据、Grafana 没有: 改 Grafana 数据源 URL、Header 和时间范围。修改前在 Grafana 里导出数据源或记下一份设置，共享数据源会影响其他面板。
6. 恢复确认:

    - `query_range` 的 `result` 不再是空数组。
    - Grafana Explore 使用同一条 LogQL 能看到同一行。
    - `loki_discarded_samples_total` 不再持续上升。
    - 采集端 `/targets` 为 ready，或 Alloy 对应组件没有新的推送错误。

## 高危提醒

- 不要删除 Loki 的数据目录或 boltdb/tsdb 索引来“让新日志出现”。那会丢掉已入库日志。
- 不要删除 Promtail positions 文件作为第一步。需要重置读取位置时，先复制一份，并在变更窗口评估重复采集的量。
- 不要在配置或工单里留下对象存储密钥、Basic Auth 和租户令牌。
- 放宽 `ingestion_rate_mb`、`max_streams` 或拒绝窗口属于容量变更，不是空查询的默认修复。
- `systemctl restart loki` 会中断写入。采集端没就绪时，重启服务端没有帮助。

## 相关专题

- [集中日志与监控告警](../manual/observability/LOGGING-MONITORING.md)
- [PromQL、LogQL 与告警规则](../manual/observability/PROMQL-LOGQL-ALERTS.md)
- [Grafana 无数据排查](GRAFANA-NO-DATA.md)
- [Prometheus Target Down 排查](PROMETHEUS-TARGET-DOWN.md)
