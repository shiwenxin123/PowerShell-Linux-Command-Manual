# 数据库连接池耗尽排查

## 现象

- 应用日志出现 `connection pool exhausted`、`timeout waiting for connection`、`Too many connections`。
- 接口响应变慢，数据库 CPU 不一定很高，但应用线程大量等待连接。

## 快速判断

```bash
# MySQL 当前连接
mysql -e "SHOW STATUS LIKE 'Threads_connected'; SHOW VARIABLES LIKE 'max_connections';"

# PostgreSQL 当前连接
psql -c "select state, count(*) from pg_stat_activity group by state;"

# 应用日志中统计连接池错误
grep -Ei "pool|connection.*timeout|too many connections" /var/log/<app>/*.log | tail -n 100
```

## 排查命令

```bash
# MySQL 活跃会话
mysql -e "SHOW FULL PROCESSLIST;"

# PostgreSQL 等待和慢 SQL
psql -c "select pid, usename, state, wait_event_type, query from pg_stat_activity limit 20;"

# Java 应用线程栈
jcmd <pid> Thread.print | grep -Ei "Hikari|Druid|jdbc|Connection" -C 3

# Kubernetes 应用副本数和重启
kubectl get deploy,pod -n <namespace> -o wide
```

## 常见原因

- 应用连接池最大值过小，或服务副本扩容后数据库总连接数超限。
- 慢 SQL、事务未提交、连接泄漏导致连接长期占用。
- 数据库 `max_connections` 设置偏低。
- 突发流量导致应用线程和连接池同时打满。
- 健康检查或定时任务频繁创建连接。

## 处理建议

- 先定位是连接泄漏、慢 SQL、事务阻塞还是容量不足。
- 计算总连接预算: 应用副本数乘以单实例连接池上限，不要只看单个服务。
- 临时恢复可先限流、扩容应用或释放异常会话；长期需要优化 SQL、事务和池参数。
- 为连接池配置获取连接超时、空闲回收、泄漏检测和监控指标。

## 高危提醒

- 直接提高数据库 `max_connections` 可能增加内存占用和上下文切换，需结合实例规格评估。
- 杀会话前确认 SQL 类型、事务影响和业务回滚风险。

## 相关专题

- [数据库与中间件命令](../manual/middleware/DATABASE-MIDDLEWARE.md)
- [MySQL 连接数打满排查](MYSQL-TOO-MANY-CONNECTIONS.md)
- [Linux 性能调优](../manual/linux/PERFORMANCE-TUNING.md)
