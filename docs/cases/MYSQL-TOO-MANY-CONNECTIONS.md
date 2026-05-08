# MySQL 连接数打满排查

## 现象

- 应用连接数据库失败，报 `Too many connections`。
- MySQL CPU 或线程数升高，连接池等待超时。
- 新连接无法建立，但已有连接可能仍在执行。
- 监控显示 `Threads_connected` 接近或达到 `max_connections`。

## 快速判断

先确认当前连接数、最大连接数和主要来源。

```sql
SHOW GLOBAL STATUS LIKE 'Threads_connected';
SHOW VARIABLES LIKE 'max_connections';
SHOW PROCESSLIST;
```

## 排查命令

```sql
-- 查看连接来源和用户分布
SELECT user, host, db, command, COUNT(*) AS cnt
FROM information_schema.processlist
GROUP BY user, host, db, command
ORDER BY cnt DESC;

-- 查看长时间运行连接
SELECT id, user, host, db, command, time, state, info
FROM information_schema.processlist
WHERE time > 60
ORDER BY time DESC;

-- 查看连接相关状态
SHOW GLOBAL STATUS LIKE 'Threads%';
SHOW GLOBAL STATUS LIKE 'Aborted_connects';
```

Linux 侧可辅助确认来源连接。

```bash
ss -antp | grep ':3306' | head
ss -ant | grep ':3306' | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head
```

## 常见原因

- 应用连接池配置过大，多实例叠加超过数据库上限。
- 应用连接泄漏，连接未及时释放。
- 慢 SQL 或锁等待导致连接长时间占用。
- 定时任务、批处理或压测流量集中打到数据库。
- MySQL `max_connections` 过低，或内存不足不适合继续增大。

## 处理建议

- 先按来源统计连接，确认是哪个应用、主机或用户占用最多。
- 对长时间连接结合 SQL、锁等待和慢日志定位根因。
- 临时恢复可谨慎 kill 明确异常的空闲连接或异常任务连接。
- 从应用侧收敛连接池大小，避免所有实例连接池总和超过数据库承载。
- 调整 `max_connections` 前评估内存、线程栈和数据库负载。

## 高危提醒

- 不要批量 kill 不明连接，可能中断正在执行的业务事务。
- 不要只调大 `max_connections` 掩盖连接泄漏或慢 SQL。
- 生产变更连接池和数据库参数前确认灰度和回滚方式。

## 相关专题

- [数据库与中间件运维命令](../manual/middleware/DATABASE-MIDDLEWARE.md)
- [MySQL 启动失败排查](MYSQL-START-FAILED.md)
- [系统性能调优](../manual/linux/PERFORMANCE-TUNING.md)
