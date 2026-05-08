# CPU 飙高排查

## 现象

- 系统响应变慢。
- 接口超时。
- 负载升高，`uptime` 中 load average 明显高于 CPU 核数。

## 快速判断

```bash
uptime
top
ps aux --sort=-%cpu | head -n 10
```

## 排查命令

```bash
# 查看进程线程
ps -T -p <PID>

# 查看进程打开文件
lsof -p <PID> | head

# 查看进程启动命令
ps -fp <PID>
```

Java 服务可继续查看线程栈:

```bash
jstack <PID> | head
```

## 常见原因

- 定时任务、报表任务、备份任务在高峰期运行。
- 应用线程死循环、锁竞争或频繁 GC。
- 异常进程、挖矿进程或未知脚本占用 CPU。
- 容器 CPU limit 过低，导致应用持续抢占。

## 处理建议

- 先确认高 CPU 进程是否为业务进程、定时任务、备份任务或异常进程。
- 对业务进程优先收集日志、线程栈、监控截图，再考虑重启。
- 对未知进程，先确认路径、用户、启动时间，不要直接强杀。

## 高危提醒

- `kill -9` 会直接终止进程，可能导致未写入数据丢失。
- 重启服务前确认是否有流量切换、主备切换或告警通知机制。

## 相关专题

- [Linux 监控与日志](../manual/linux/MONITORING-LOGS.md)
- [系统性能调优](../manual/linux/PERFORMANCE-TUNING.md)
- [PromQL、LogQL 与告警规则](../manual/observability/PROMQL-LOGQL-ALERTS.md)
