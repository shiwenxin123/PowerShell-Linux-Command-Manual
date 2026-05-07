# Linux 存储与日志

磁盘和日志问题是线上故障中最常见的类型。排查时先判断空间、inode、目录占用和日志增长速度。

## 磁盘空间

```bash
# 查看磁盘空间
df -h

# 查看 inode
df -i

# 查看目录占用
du -sh /var/* 2>/dev/null | sort -h

# 查找大文件
find / -type f -size +500M 2>/dev/null
```

## 日志查看

```bash
# 查看系统日志
journalctl -xe --no-pager

# 查看服务日志
journalctl -u nginx -n 100 --no-pager

# 实时查看应用日志
tail -f /path/to/app.log

# 搜索错误
grep -RniE "error|failed|exception|timeout" /var/log 2>/dev/null | head
```

## 删除前检查

```bash
pwd
ls -la /path
find /path -maxdepth 1 -print
```

## 延伸案例

- [磁盘空间满排查](../../cases/DISK-FULL.md)
- [Linux 故障应急排查清单](../../troubleshooting/LINUX-INCIDENT-CHECKLIST.md)
