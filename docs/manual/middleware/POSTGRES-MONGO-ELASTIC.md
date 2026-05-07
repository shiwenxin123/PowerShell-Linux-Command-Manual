# PostgreSQL、MongoDB 与 Elasticsearch

这个页面补充常见数据库和搜索中间件的排查命令，适合连接失败、性能异常、磁盘占用、集群健康和索引问题。

## PostgreSQL

```bash
# 查看服务状态
systemctl status postgresql

# 查看监听端口
ss -tulnp | grep ':5432'

# 连接数据库
psql -h 127.0.0.1 -p 5432 -U postgres

# 查看版本
psql -U postgres -c "SELECT version();"
```

常用 SQL:

```sql
-- 查看连接
SELECT pid, usename, client_addr, state, query
FROM pg_stat_activity
ORDER BY query_start DESC;

-- 查看最大连接数
SHOW max_connections;

-- 查看数据库大小
SELECT datname, pg_size_pretty(pg_database_size(datname))
FROM pg_database;

-- 查看慢查询扩展是否可用
SELECT * FROM pg_extension;
```

常见问题:

- 连接数耗尽。
- 认证规则 `pg_hba.conf` 不匹配。
- 磁盘满。
- 长事务或锁等待。

## MongoDB

```bash
# 查看服务状态
systemctl status mongod

# 查看监听端口
ss -tulnp | grep ':27017'

# 连接
mongosh

# 查看日志
tail -n 100 /var/log/mongodb/mongod.log
```

常用命令:

```javascript
// 查看状态
db.serverStatus()

// 查看数据库
show dbs

// 查看集合
show collections

// 查看当前操作
db.currentOp()

// 查看慢查询配置
db.getProfilingStatus()
```

常见问题:

- 认证失败。
- 副本集状态异常。
- 磁盘空间不足。
- 慢查询或索引缺失。

## Elasticsearch

```bash
# 查看服务状态
systemctl status elasticsearch

# 集群健康
curl -s http://127.0.0.1:9200/_cluster/health?pretty

# 节点
curl -s http://127.0.0.1:9200/_cat/nodes?v

# 索引
curl -s http://127.0.0.1:9200/_cat/indices?v

# 分片
curl -s http://127.0.0.1:9200/_cat/shards?v
```

常见问题:

- 集群 yellow/red。
- 分片未分配。
- 磁盘水位触发只读。
- JVM heap 使用过高。
- 索引过多或分片过多。

## 通用排查顺序

1. 服务是否运行。
2. 端口是否监听。
3. 本机连接是否成功。
4. 认证和访问控制是否正确。
5. 磁盘、内存、连接数是否达到上限。
6. 查看错误日志和慢查询。
