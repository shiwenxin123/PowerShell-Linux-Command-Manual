# Elasticsearch 磁盘水位排查

## 现象

- 写入失败，响应里出现 `cluster_block_exception`，原因含 `index read-only / allow delete (api)` 或 `index.blocks.read_only_allow_delete`。
- 集群从 green 变成 yellow 或 red，已有索引仍能查询，新索引主分片 `UNASSIGNED`。
- Elasticsearch 日志出现 `flood stage disk watermark` 或 `high disk watermark` exceeded。日志里的百分比是当前配置值，不一定是 95%。
- 节点磁盘使用率已经很高。`df` 显示 Elasticsearch 数据盘接近写满。
- 只读查询还在，副本无法分配，或者分配器说明是磁盘水位。

本案例只处理磁盘水位把索引打成只读、或阻止分片分配。JVM 堆、映射爆炸和主节点丢失要分开查。

## 快速判断

先看操作系统磁盘和集群只读接口。8.x 默认开启安全特性，本机 HTTP 无认证的命令会返回 401。有认证时使用环境变量，不要把口令写进命令或文档:

```bash
# 8.x 常见是 https，并且需要账号。ES_PASSWORD 由当前终端环境提供
curl -sk -u "elastic:${ES_PASSWORD}" 'https://127.0.0.1:9200/_cluster/health?pretty'

# 7.x 且安全特性未开启时，本机常用这个地址
curl -sS 'http://127.0.0.1:9200/_cluster/health?pretty'
```

下文用 `ES` 表示已经选好的基地址，例如 `http://127.0.0.1:9200` 或带账号的 `https://127.0.0.1:9200`。需要认证时给每条 `curl` 加上同样的 `-u "elastic:${ES_PASSWORD}"`。

```bash
df -hT
curl -sS "${ES}/_cluster/health?pretty"
curl -sS "${ES}/_cat/allocation?v&h=node,disk.used,disk.avail,disk.total,disk.percent,shards"
```

同时满足下面两条，再按磁盘水位处理:

- 某个节点 `disk.percent` 达到或超过 high / flood stage 水位。
- 索引设置里有 `index.blocks.read_only_allow_delete: true`，或分片 `unassigned.reason` 与磁盘阈值有关。

只有磁盘满、索引没有这个 block 时，先按 [磁盘空间满排查](DISK-FULL.md) 清理，同时继续看 Elasticsearch 是否即将触发水位。

## 排查命令

### 确认版本和水位配置

```bash
curl -sS "${ES}/"
curl -sS "${ES}/_cluster/settings?include_defaults=true&flat_settings=true" | grep -E 'watermark|threshold_enabled'
```

Elasticsearch 7.x 和 8.x 在没有改过设置时，常见默认值是:

| 设置 | 默认值 | 达到之后 |
| --- | --- | --- |
| `cluster.routing.allocation.disk.watermark.low` | `85%` | 不再把分片继续分配到这个节点，已有分片还在 |
| `cluster.routing.allocation.disk.watermark.high` | `90%` | 尝试把分片挪走；节点上不再接受新分片 |
| `cluster.routing.allocation.disk.watermark.flood_stage` | `95%` | 给该节点上持有分片的索引加上 `read_only_allow_delete` |

这三项也可以是 `100gb` 这种剩余空间写法。`persistent` 或 `transient` 里的值覆盖默认值。看到非 85/90/95 时，以接口返回为准，不要按默认百分比判断。

`cluster.routing.allocation.disk.threshold_enabled` 为 `false` 时，集群不会按磁盘水位分配。这时出现的只读块来自别的操作，不是 flood stage。

### 只读块和分片

```bash
# 只读查看哪些索引被打上删除以外的只读块。GET 不会改索引
curl -sS "${ES}/_all/_settings?filter_path=**.blocks&flat_settings=true&pretty"

curl -sS "${ES}/_cat/shards?v&h=index,shard,prirep,state,unassigned.reason,node"

# 解释某一个未分配主分片。index、shard 换成 _cat/shards 里看到的名字
curl -sS -X GET "${ES}/_cluster/allocation/explain?pretty" \
  -H 'Content-Type: application/json' \
  -d '{"index":"example-logs-0001","shard":0,"primary":true}'
```

`allocation/explain` 的 `deciders` 里如果写 watermark 或 disk，就可以把原因定到磁盘水位。解释接口不移动分片。

数据目录不一定在 `/var/lib/elasticsearch`。只看路径配置，不要把整份 `elasticsearch.yml` 或 keystore 贴出来，里面可能有账号设置:

```bash
grep -E '^path\.(data|logs)' /etc/elasticsearch/elasticsearch.yml
du -xh --max-depth=1 /var/lib/elasticsearch /var/log/elasticsearch 2>/dev/null | sort -h
df -hT /var/lib/elasticsearch
```

`du` 路径以 `path.data` 为准。目录不存在就跳过，不要创建它。

### 日志里的水位句子

```bash
journalctl -u elasticsearch -n 200 --no-pager | grep -E 'watermark|read_only|flood stage'
```

没有 systemd 单元时，改看 `path.logs` 下的集群日志，仍然只筛选水位相关行。

## 常见原因

- 数据盘使用率超过 flood stage。Elasticsearch 给该节点上的索引加上 `index.blocks.read_only_allow_delete`，写入返回 403。
- 使用率超过 high、尚未到 flood stage。写入旧索引可能还在，新分片无法分配，集群 yellow 或 red。
- 日志、快照临时文件或其他进程把同一块盘写满。Elasticsearch 数据目录本身不一定是最大占用。
- 有人把水位改成剩余空间绝对值，节点剩余空间低于该值，百分比看起来还不高。
- 磁盘已经降下来，但只读块还在。7.4 之前，以及部分早期 7.x，不会在水位恢复后自动清除这个块。7.4 及以后的 7.x、以及 8.x，通常会在节点降到 high watermark 以下后自动去掉由水位加上的块。手动加过的块不会因为磁盘恢复就一定消失。
- 多个节点同时超过水位时，主分片没有可以去的节点，`allocation/explain` 会显示所有节点都被磁盘决策器拒绝。

## 处理建议

1. 先腾出磁盘，再谈解除只读。清理对象是确认过的系统日志、已过期且业务允许删除的文件、以及重复的临时导出。不要删除 `path.data` 目录，不要对索引名使用 `_all` 或通配符删除。

    ```bash
    # 只查看大目录。确认是日志而不是数据目录后，再按变更流程删除指定的旧文件
    du -xh --max-depth=1 /var/log /var/lib/elasticsearch 2>/dev/null | sort -h
    df -hT
    ```

    业务确认某个旧索引可以废弃时，在变更里删除那一个完整索引名，例如 `example-logs-2020.01`。这是不可恢复操作，不作为默认步骤，也不要写成可以复制的通配删除。

2. 磁盘降到 high watermark 以下之后，重新读只读块和水位:

    ```bash
    df -hT
    curl -sS "${ES}/_cat/allocation?v&h=node,disk.percent,disk.avail"
    curl -sS "${ES}/_all/_settings?filter_path=**.blocks.read_only_allow_delete&flat_settings=true"
    curl -sS "${ES}/_cluster/health?pretty"
    ```

    7.4 及更新的版本里，水位触发的块经常会自己消失。块还在时，先确认版本是不是更老，以及这个块是不是人工设置的。

3. 自动清除没有发生、磁盘已经低于 high watermark 时，只对仍然只读的那一个索引去掉块。下面的请求会修改索引设置:

    ```bash
    # 不要改成 _all。磁盘仍高于 flood stage 时，清掉后会被再次加上
    curl -sS -X PUT "${ES}/example-logs-0001/_settings" \
      -H 'Content-Type: application/json' \
      -d '{"index.blocks.read_only_allow_delete": null}'
    ```

4. 恢复确认。向该索引写入一条可识别的探测文档，确认不再返回 `cluster_block_exception`。探测文档不是业务数据，确认后按返回的 `_id` 删掉这一条，不要删除索引:

    ```bash
    curl -sS -X POST "${ES}/example-logs-0001/_doc" \
      -H 'Content-Type: application/json' \
      -d '{"probe":"disk-watermark-check","at":"2026-05-08T02:30:00Z"}'

    curl -sS -X DELETE "${ES}/example-logs-0001/_doc/<probe-id>"
    ```

5. 分片仍是 `UNASSIGNED` 时，再跑一次 `allocation/explain`。磁盘决策器不再拒绝后，集群会自行分配。不要为了让分片变绿去执行强制 `reroute`，除非分配器给出的是磁盘以外的原因，并且变更窗口允许搬迁数据。

不要上调 `flood_stage` 或关闭 `disk.threshold_enabled` 来恢复写入。阈值放宽后节点会继续写满，进程或操作系统随后会进入更难恢复的状态。

## 高危提醒

- `DELETE /索引名` 不可恢复。禁止 `DELETE /_all`、`DELETE /*` 和带通配符的删除。
- 清除 `read_only_allow_delete` 不会找回已经失败的写入，也不会增加磁盘。磁盘仍满时马上又会被只读块挡住。
- `POST /_cluster/reroute` 会搬动分片，增加磁盘和网络压力。本案例的只读步骤是 `allocation/explain`。
- 修改 `elasticsearch.yml` 或 keystore 前先备份。不要在文档、工单或 shell 历史里留下 `elastic` 口令。
- 重启 Elasticsearch 不是磁盘水位的修复办法。重启前数据盘写满，节点可能更难启动。

## 相关专题

- [PostgreSQL、MongoDB 与 Elasticsearch](../manual/middleware/POSTGRES-MONGO-ELASTIC.md)
- [磁盘空间满排查](DISK-FULL.md)
- [Linux 磁盘、挂载与 LVM](../manual/linux/DISK-LVM.md)
