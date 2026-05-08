# 消息队列连接失败排查

## 现象

- 应用日志出现 `connection refused`、`connection timeout`、`authentication failed`、`broker not available`。
- 消费者停止消费，生产者发送失败或大量重试。

## 快速判断

```bash
# 检查端口连通性
nc -vz <mq-host> 5672
nc -vz <mq-host> 9092

# DNS 和路由检查
dig <mq-host>
ip route get <mq-ip>

# 查看应用错误日志
grep -Ei "rabbit|kafka|mq|broker|timeout|auth" /var/log/<app>/*.log | tail -n 100
```

## 排查命令

```bash
# RabbitMQ 基础状态
rabbitmqctl status
rabbitmqctl list_connections
rabbitmqctl list_queues name messages consumers

# Kafka 基础连通性
kafka-broker-api-versions.sh --bootstrap-server <broker>:9092
kafka-topics.sh --bootstrap-server <broker>:9092 --list

# Kubernetes 中查看 Service 和 Endpoints
kubectl get svc,endpoints -n <namespace> | grep -Ei "rabbit|kafka|mq"
```

## 常见原因

- Broker 地址、端口、协议或 TLS 配置错误。
- 用户名、密码、vhost、ACL 或 SASL 配置错误。
- 安全组、防火墙、NetworkPolicy 未放行。
- Broker 连接数达到上限，或监听地址只绑定本机。
- Kafka advertised listeners 配置错误，客户端拿到不可达地址。

## 处理建议

- 先用只读命令确认端口、认证和服务端状态。
- 对 Kafka 优先核对 `advertised.listeners` 和客户端访问网络是否一致。
- 对 RabbitMQ 核对 vhost、用户权限和队列堆积。
- 客户端增加合理超时、重试退避和连接池上限，避免雪崩式重连。

## 高危提醒

- 不要直接清空队列或删除 Topic 来恢复连接问题，除非已经确认数据可丢弃且业务方同意。
- 修改 Broker 监听地址、认证或集群配置前必须确认回滚方案。

## 相关专题

- [数据库与中间件命令](../manual/middleware/DATABASE-MIDDLEWARE.md)
- [Linux 网络排查](../manual/linux/NETWORK.md)
- [Redis 连接失败排查](REDIS-CONNECTION-FAILED.md)
