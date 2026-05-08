# 命令速查表

这个页面用于快速查找高频命令。需要完整说明和更多示例时，请查看仓库根目录中的完整手册: [Windows-PowerShell-Linux-Command-Manual.md](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual/blob/main/Windows-PowerShell-Linux-Command-Manual.md)。

## PowerShell 与 Linux 常用对照

| 场景 | PowerShell | Linux |
| --- | --- | --- |
| 当前路径 | `Get-Location` / `pwd` | `pwd` |
| 切换目录 | `Set-Location C:\Path` / `cd` | `cd /path` |
| 列出文件 | `Get-ChildItem` / `ls` | `ls -la` |
| 查看文件内容 | `Get-Content file.txt` | `cat file.txt` |
| 读取前几行 | `Get-Content file.txt -TotalCount 10` | `head -n 10 file.txt` |
| 读取后几行 | `Get-Content file.txt -Tail 10` | `tail -n 10 file.txt` |
| 实时查看日志 | `Get-Content app.log -Wait` | `tail -f app.log` |
| 复制文件 | `Copy-Item source dest` | `cp source dest` |
| 移动文件 | `Move-Item old new` | `mv old new` |
| 删除文件 | `Remove-Item file.txt` | `rm file.txt` |
| 创建目录 | `New-Item -ItemType Directory demo` | `mkdir demo` |
| 查找文件 | `Get-ChildItem -Recurse -Filter "*.log"` | `find . -name "*.log"` |
| 搜索文本 | `Select-String -Path *.log -Pattern "error"` | `grep -R "error" .` |
| 查看进程 | `Get-Process` | `ps aux` |
| 停止进程 | `Stop-Process -Id 1234` | `kill 1234` |
| 查看服务 | `Get-Service` | `systemctl list-units --type=service` |
| 重启服务 | `Restart-Service nginx` | `sudo systemctl restart nginx` |
| 查看端口 | `Get-NetTCPConnection` | `ss -tulnp` |
| 测试连通 | `Test-Connection example.com` | `ping example.com` |
| 测试端口 | `Test-NetConnection host -Port 443` | `nc -vz host 443` |
| 下载文件 | `Invoke-WebRequest URL -OutFile file` | `curl -L URL -o file` |

## 高频排查命令

### Windows PowerShell

```powershell
# 查看占用 8080 端口的进程
Get-NetTCPConnection -LocalPort 8080 | Select-Object LocalAddress,LocalPort,State,OwningProcess

# 按 CPU 查看进程
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

# 实时查看日志
Get-Content .\app.log -Tail 100 -Wait

# 查找大文件
Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue |
  Where-Object Length -gt 100MB |
  Sort-Object Length -Descending |
  Select-Object FullName,Length -First 20
```

### Linux

```bash
# 查看系统版本
cat /etc/os-release

# 查看资源占用
top

# 查看端口监听
ss -tulnp

# 查看服务状态
systemctl status nginx

# 查看最近日志
journalctl -xe

# 查找大文件
find / -type f -size +100M 2>/dev/null
```

## 高危命令提醒

| 命令 | 风险 | 建议 |
| --- | --- | --- |
| `rm -rf /path` | 递归强制删除 | 先用 `ls /path` 确认目标，再删除 |
| `Remove-Item -Recurse -Force` | 递归强制删除 | 使用 `-WhatIf` 预览 |
| `chmod -R 777` | 放开权限 | 尽量使用最小权限 |
| `chown -R` | 批量修改属主 | 确认目录边界 |
| `mkfs.*` | 格式化磁盘 | 确认设备名和备份 |
| `dd if=... of=...` | 低级磁盘写入 | 确认 `of` 目标 |

## 建议继续补充的速查主题

- PowerShell 管道与对象处理
- Bash 文本处理三件套: `grep`、`awk`、`sed`
- `systemctl` 与 Windows 服务对照
- 防火墙命令对照
- 国产 Linux 包管理命令对照
