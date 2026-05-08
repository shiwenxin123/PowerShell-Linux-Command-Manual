# 数据库与中间件命令

这个页面整理常见数据库和中间件的基础排查命令，适合服务启动失败、连接失败、性能异常和日志分析场景。

## MySQL

```bash
# 查看服务状态
systemctl status mysql || systemctl status mysqld

# 查看错误日志
tail -n 100 /var/log/mysql/error.log 2>/dev/null
tail -n 100 /var/log/mysqld.log 2>/dev/null

# 查看 MySQL 状态
mysqladmin -uroot -p status

# 连接数据库
mysql -h 127.0.0.1 -P 3306 -uroot -p
```

SQL 排查:

```sql
SHOW PROCESSLIST;
SHOW VARIABLES LIKE 'max_connections';
SHOW STATUS LIKE 'Threads_connected';
SHOW ENGINE INNODB STATUS\G
```

延伸案例: [MySQL 启动失败排查](../../cases/MYSQL-START-FAILED.md)。

## Redis

```bash
# 查看服务状态
systemctl status redis || systemctl status redis-server

# 测试连接
redis-cli ping
redis-cli -h 127.0.0.1 -p 6379 ping

# 查看信息
redis-cli info

# 查看慢查询
redis-cli slowlog get 10
```

常用排查:

```bash
# 查看内存
redis-cli info memory

# 查看客户端
redis-cli client list

# 查看配置
redis-cli config get maxmemory
```

延伸案例: [Redis 连接失败排查](../../cases/REDIS-CONNECTION-FAILED.md)。

## Nginx

```bash
# 检查配置
nginx -t

# 输出完整配置
nginx -T

# 查看服务状态
systemctl status nginx

# 查看错误日志
tail -n 100 /var/log/nginx/error.log

# 查看访问日志
tail -n 100 /var/log/nginx/access.log
```

访问日志分析:

```bash
# 统计状态码
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -nr

# 查看访问最多的 IP
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head
```

延伸案例:

- [Nginx 启动失败排查](../../cases/NGINX-START-FAILED.md)
- [Nginx 502/504 排查](../../cases/NGINX-502-504.md)

## RabbitMQ

```bash
# 查看服务状态
systemctl status rabbitmq-server

# 查看节点状态
rabbitmqctl status

# 查看队列
rabbitmqctl list_queues

# 查看连接
rabbitmqctl list_connections

# 查看用户
rabbitmqctl list_users
```

常见问题:

- 队列堆积。
- 连接数过多。
- 磁盘水位触发 flow control。
- Erlang cookie 不一致导致集群异常。

## Kafka

```bash
# 查看 topic
kafka-topics.sh --bootstrap-server <broker>:9092 --list

# 查看 topic 详情
kafka-topics.sh --bootstrap-server <broker>:9092 --describe --topic <topic>

# 查看消费组
kafka-consumer-groups.sh --bootstrap-server <broker>:9092 --list

# 查看消费组 lag
kafka-consumer-groups.sh --bootstrap-server <broker>:9092 --describe --group <group>
```

常见问题:

- 消费 lag 增长。
- broker 磁盘满。
- ISR 不足。
- topic 分区和副本配置不合理。

## 通用排查顺序

1. 服务是否运行。
2. 端口是否监听。
3. 本机是否能连接。
4. 应用机器是否能连接。
5. 认证、权限、配置是否一致。
6. 查看错误日志和慢日志。

## 相关案例

- [MySQL 启动失败排查](../../cases/MYSQL-START-FAILED.md)
- [MySQL 连接数打满排查](../../cases/MYSQL-TOO-MANY-CONNECTIONS.md)
- [Redis 连接失败排查](../../cases/REDIS-CONNECTION-FAILED.md)
- [端口被占用排查](../../cases/PORT-IN-USE.md)
- [磁盘空间满排查](../../cases/DISK-FULL.md)
