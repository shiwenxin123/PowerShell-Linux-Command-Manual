# 命令风险等级说明

命令手册中涉及系统配置、权限、删除和磁盘操作。为了降低误操作风险，建议后续新增命令时统一标注风险等级。

## 风险等级

| 等级 | 含义 | 示例 |
| --- | --- | --- |
| 低 | 只读查询，不改变系统状态 | `ls`、`Get-Process`、`df -h` |
| 中 | 修改普通文件、启动停止服务、安装软件 | `systemctl restart`、`apt install` |
| 高 | 可能导致数据丢失、权限失控、网络中断 | `rm -rf`、`chmod -R 777`、`mkfs` |

## 高危命令清单

| 命令 | 风险 | 更安全的做法 |
| --- | --- | --- |
| `rm -rf /path` | 递归强制删除，删除后通常不可恢复 | 先执行 `ls /path` 或 `find /path -maxdepth 1` |
| `Remove-Item -Recurse -Force` | Windows 递归强制删除 | 先加 `-WhatIf` 预览 |
| `chmod -R 777` | 过度开放权限 | 使用最小权限，例如 `chmod 750` |
| `chown -R user:group /path` | 批量修改属主，可能影响服务运行 | 先确认目录边界 |
| `mkfs.* /dev/sdX` | 格式化磁盘，清空文件系统 | 先执行 `lsblk` 确认设备 |
| `dd if=... of=...` | 低级磁盘写入，目标写错会破坏数据 | 反复确认 `of` 目标 |
| `iptables -F` | 清空防火墙规则，可能暴露服务 | 先备份规则 |
| `systemctl stop sshd` | 可能断开远程管理入口 | 保留现有 SSH 会话 |

## 按场景标注规范

### 删除类

风险等级: 高

典型命令:

```bash
rm -rf /path
find /path -type f -delete
```

```powershell
Remove-Item C:\Path -Recurse -Force
```

执行前检查:

```bash
pwd
ls -la /path
find /path -maxdepth 1 -print
```

```powershell
Get-Location
Get-ChildItem C:\Path
Remove-Item C:\Path -Recurse -Force -WhatIf
```

### 权限类

风险等级: 中到高

典型命令:

```bash
chmod -R 777 /path
chown -R user:group /path
```

执行前检查:

```bash
ls -ld /path
find /path -maxdepth 2 -ls | head
```

建议:

- 避免 `777`，优先使用最小权限。
- 修改目录前确认服务运行用户。
- 批量修改前先在单个文件或测试目录验证。

### 磁盘类

风险等级: 高

典型命令:

```bash
mkfs.ext4 /dev/sdX
dd if=image.iso of=/dev/sdX bs=4M
parted /dev/sdX
```

执行前检查:

```bash
lsblk
blkid
mount | grep /dev/sdX
```

建议:

- 反复确认设备名。
- 确认是否有备份。
- 不在业务运行时直接操作挂载中的数据盘。

### 网络与防火墙类

风险等级: 中到高

典型命令:

```bash
iptables -F
firewall-cmd --reload
ufw deny 22
```

执行前检查:

```bash
iptables-save > iptables.backup
firewall-cmd --list-all
ss -tulnp
```

建议:

- 远程服务器修改防火墙前保留当前 SSH 会话。
- 先增加允许规则，再删除旧规则。
- 使用定时回滚任务降低误操作风险。

### 服务类

风险等级: 中

典型命令:

```bash
systemctl restart nginx
systemctl stop sshd
```

```powershell
Restart-Service nginx
Stop-Service sshd
```

执行前检查:

```bash
systemctl status <service>
journalctl -u <service> -n 50 --no-pager
```

建议:

- 重启前确认是否有主备、负载均衡或维护窗口。
- SSH、数据库、网关等基础服务要特别谨慎。

## 推荐模板

```markdown
### 命令场景

风险等级: 低 / 中 / 高

```bash
# 命令说明
command --option value
```

注意事项:
- 适用系统:
- 版本限制:
- 执行前检查:
```

## 写作文档时的安全原则

- 高危命令必须给出执行前检查命令。
- 不把破坏性命令放在章节第一条。
- 不用真实密码、Token、内网地址作为示例。
- 涉及生产环境的命令尽量写明回滚方式。
