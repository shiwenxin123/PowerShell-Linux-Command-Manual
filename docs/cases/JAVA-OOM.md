# Java 服务 OOM 排查

## 现象

- Java 服务突然退出。
- 日志出现 `OutOfMemoryError`。
- 接口大量超时，进程内存持续升高。
- 系统日志出现 OOM Killer。

## 快速判断

```bash
ps aux --sort=-%mem | head -n 10
dmesg -T | grep -i "out of memory"
journalctl -k | grep -i "killed process"
```

## 排查命令

```bash
# 查看 Java 进程
jps -l

# 查看 JVM 参数
jcmd <PID> VM.flags

# 查看堆信息
jcmd <PID> GC.heap_info

# 导出线程栈
jstack <PID> > jstack.txt
```

如果服务仍可响应，可以导出堆转储:

```bash
jmap -dump:format=b,file=heap.hprof <PID>
```

## 常见原因

- JVM 堆设置过小。
- 内存泄漏。
- 大对象或大查询结果占用内存。
- 线程数过多。
- 容器内存限制小于 JVM 预期。
- 频繁 Full GC 导致服务不可用。

## 处理建议

- 先保留日志、GC 日志、线程栈和必要的 heap dump。
- 容器环境检查内存 limit 和 JVM 参数是否匹配。
- 结合监控确认内存增长趋势。
- 临时恢复可以重启服务，但需要继续定位根因。

## 高危提醒

- `jmap -dump` 可能生成很大的文件，执行前确认磁盘空间。
- heap dump 可能包含敏感业务数据，传输和分享前要脱敏。

## 相关专题

- [Linux 监控与日志](../manual/linux/MONITORING-LOGS.md)
- [系统性能调优](../manual/linux/PERFORMANCE-TUNING.md)
- [PromQL、LogQL 与告警规则](../manual/observability/PROMQL-LOGQL-ALERTS.md)
