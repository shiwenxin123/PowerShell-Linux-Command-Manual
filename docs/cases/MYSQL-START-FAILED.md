# MySQL 启动失败排查

## 现象

- `systemctl start mysql` 或 `systemctl start mysqld` 失败。
- 应用连接数据库失败。
- 日志中出现权限、端口、磁盘或配置错误。

## 快速判断

```bash
systemctl status mysql || systemctl status mysqld
journalctl -u mysql -n 100 --no-pager || journalctl -u mysqld -n 100 --no-pager
```

## 排查命令

```bash
# 查看 MySQL 错误日志
tail -n 100 /var/log/mysql/error.log 2>/dev/null
tail -n 100 /var/log/mysqld.log 2>/dev/null

# 检查端口占用
ss -tulnp | grep ':3306'

# 检查磁盘空间
df -h
df -i

# 检查数据目录权限
ls -ld /var/lib/mysql
```

## 常见原因

- 配置文件语法或参数错误。
- 3306 端口被占用。
- 磁盘空间或 inode 用完。
- 数据目录权限错误。
- 上次异常退出导致恢复失败。
- 内存不足或 OOM。

## 处理建议

- 优先查看 MySQL 错误日志，不要盲目反复启动。
- 检查磁盘和权限。
- 配置变更后回滚到最近可用版本验证。
- 数据目录问题先备份，不要直接删除文件。

## 高危提醒

- 不要删除 `/var/lib/mysql` 下不认识的文件。
- 不要在没有备份的情况下执行修复或初始化命令。
- 生产数据库操作前必须确认备份和恢复方案。
