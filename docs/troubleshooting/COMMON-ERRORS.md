# 常见报错排查

这个页面收集日常命令行和运维中最常见的错误。每个问题都尽量给出“先查什么、再怎么处理”的路径。

## Permission denied

常见原因:

- 当前用户没有文件或目录权限。
- 文件没有执行权限。
- 目录缺少进入权限。
- SELinux、AppArmor 或安全中心策略限制。

排查命令:

```bash
whoami
id
ls -l /path/to/file
ls -ld /path/to/dir
```

处理建议:

```bash
# 给脚本增加执行权限
chmod +x script.sh

# 使用 sudo 执行需要管理员权限的命令
sudo command
```

不要一上来就执行 `chmod -R 777`。这会扩大权限风险。

## command not found

常见原因:

- 命令没有安装。
- 命令所在目录不在 `PATH`。
- 使用了错误的软件包名。

排查命令:

```bash
which command
command -v command
echo "$PATH"
```

处理建议:

```bash
# Debian/Ubuntu/UOS 兼容环境
sudo apt update
sudo apt install <package>

# RPM/YUM 兼容环境
sudo yum install <package>
```

## Address already in use

常见原因:

- 端口已经被其他进程占用。
- 服务重复启动。
- 上一次进程没有退出。

排查命令:

```bash
ss -tulnp | grep ':8080'
lsof -i :8080
```

Windows PowerShell:

```powershell
Get-NetTCPConnection -LocalPort 8080
```

处理建议:

- 确认占用端口的进程是否属于当前服务。
- 优先使用服务管理命令停止，不确定时不要直接强杀。

## No space left on device

常见原因:

- 磁盘空间满。
- inode 用完。
- 日志或临时文件暴涨。

排查命令:

```bash
df -h
df -i
du -sh /* 2>/dev/null
find / -type f -size +500M 2>/dev/null
```

处理建议:

- 优先清理可确认的临时文件、旧日志、旧备份。
- 删除日志前先确认是否需要保留排障证据。
- 删除文件后空间未释放时，检查是否有进程仍占用已删除文件。

```bash
lsof | grep deleted
```

## Network is unreachable

常见原因:

- 网卡未配置 IP。
- 默认路由缺失。
- DNS 配置错误。
- 防火墙或安全策略拦截。

排查命令:

```bash
ip addr
ip route
ping 8.8.8.8
ping example.com
cat /etc/resolv.conf
```

## systemctl service failed

排查命令:

```bash
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
systemctl --failed
```

处理建议:

- 先看启动失败日志，不要反复重启。
- 检查配置文件语法。
- 检查端口、权限、路径、依赖服务。
