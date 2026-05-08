# 磁盘空间满排查

## 现象

- 应用写日志失败。
- 数据库写入失败。
- 部署时报 `No space left on device`。
- 服务突然停止或无法启动。

## 快速判断

先判断是磁盘块空间满，还是 inode 用完。

```bash
df -h
df -i
```

## 排查命令

```bash
# 查看一级目录占用
du -sh /* 2>/dev/null | sort -h

# 查看 /var 下目录占用
du -sh /var/* 2>/dev/null | sort -h

# 查找大文件
find / -type f -size +500M 2>/dev/null

# 查看仍被进程占用的已删除文件
lsof | grep deleted
```

## 常见原因

- 应用日志、访问日志或审计日志持续增长。
- 数据库 binlog、慢日志、备份文件未定期清理。
- 容器镜像、volume、构建缓存占用过大。
- inode 用尽，导致还有空间但无法创建新文件。
- 文件已删除但仍被进程占用，空间未释放。

## 处理建议

- 优先清理明确可删除的旧日志、临时文件、旧备份。
- 对日志文件优先使用日志轮转，而不是长期手动删除。
- 如果删除文件后空间没有释放，检查是否有进程占用已删除文件。
- 数据库、容器、对象存储、本地上传目录不要直接删除，先确认业务含义。

## 高危提醒

- 不要直接执行 `rm -rf /var/*`。
- 不要清理不了解用途的数据库目录。
- 删除生产日志前，先保留关键排障证据。

## 相关专题

- [磁盘、分区与 LVM](../manual/linux/DISK-LVM.md)
- [Linux 监控与日志](../manual/linux/MONITORING-LOGS.md)
- [日志轮转、审计与系统日志](../manual/security/LOGGING-AUDIT.md)
