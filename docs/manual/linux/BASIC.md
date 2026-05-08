# Linux 基础命令

这个页面整理 Linux 日常操作中最常见的目录、文件、文本和进程命令。

## 目录导航

```bash
# 查看当前目录
pwd

# 切换目录
cd /var/log

# 返回上级目录
cd ..

# 返回上一次目录
cd -
```

## 文件与目录

```bash
# 列出文件
ls -la

# 创建目录
mkdir demo

# 创建文件
touch notes.txt

# 复制文件
cp source.txt dest.txt

# 复制目录
cp -r source_dir dest_dir

# 移动或重命名
mv old.txt new.txt
```

## 查看与搜索

```bash
# 查看文件
cat file.txt

# 查看前 20 行
head -n 20 file.txt

# 查看后 100 行
tail -n 100 app.log

# 实时查看日志
tail -f app.log

# 搜索关键字
grep -R "error" /var/log
```

## 进程与资源

```bash
# 查看进程
ps aux

# 实时资源
top

# 内存
free -h

# 磁盘空间
df -h

# 目录占用
du -sh /var/log
```

## 安全提醒

`rm -rf`、`chmod -R`、`chown -R` 等命令影响范围大，执行前请查看 [命令风险等级说明](../../security/RISK-LEVELS.md)。

## 相关案例

- [systemd 服务启动失败排查](../../cases/SYSTEMD-SERVICE-FAILED.md)
- [Linux Permission denied 排查](../../cases/LINUX-PERMISSION-DENIED.md)
- [端口被占用排查](../../cases/PORT-IN-USE.md)
