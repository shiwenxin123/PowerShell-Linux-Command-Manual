# Redis 连接失败排查

## 现象

- 应用连接 Redis 超时。
- 提示 `Connection refused`。
- 提示认证失败。
- Redis 服务运行但业务读写异常。

## 快速判断

```bash
systemctl status redis || systemctl status redis-server
ss -tulnp | grep ':6379'
redis-cli ping
```

## 排查命令

```bash
# 查看 Redis 日志
journalctl -u redis -n 100 --no-pager 2>/dev/null
journalctl -u redis-server -n 100 --no-pager 2>/dev/null

# 指定 host 和端口测试
redis-cli -h 127.0.0.1 -p 6379 ping

# 查看配置
grep -E "^(bind|port|requirepass|protected-mode)" /etc/redis/redis.conf 2>/dev/null
```

## 常见原因

- Redis 服务未启动。
- 端口未监听或被防火墙拦截。
- `bind` 只绑定了本地地址。
- 开启了 `protected-mode`。
- 密码配置不一致。
- Redis 内存达到上限。

## 处理建议

- 先在 Redis 本机用 `redis-cli ping` 验证。
- 再从应用机器测试网络连通。
- 检查应用配置中的 host、port、password、database。
- 生产环境不要为了连通性直接关闭认证。

## 高危提醒

- Redis 暴露到公网风险极高。
- 修改 `bind`、`protected-mode`、密码前确认网络边界和访问控制。
