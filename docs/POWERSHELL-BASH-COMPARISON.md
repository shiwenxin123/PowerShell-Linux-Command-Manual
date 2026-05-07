# PowerShell 与 Bash 命令对照

这份对照表适合经常在 Windows 和 Linux 之间切换的用户。PowerShell 更偏对象管道，Bash 更偏文本管道，很多命令看起来相似，但处理方式不同。

## 文件与目录

| 场景 | PowerShell | Bash/Linux |
| --- | --- | --- |
| 当前目录 | `Get-Location` | `pwd` |
| 切换目录 | `Set-Location C:\Work` | `cd /work` |
| 列出文件 | `Get-ChildItem` | `ls -la` |
| 创建目录 | `New-Item -ItemType Directory demo` | `mkdir demo` |
| 创建文件 | `New-Item file.txt` | `touch file.txt` |
| 复制文件 | `Copy-Item a.txt b.txt` | `cp a.txt b.txt` |
| 复制目录 | `Copy-Item src dst -Recurse` | `cp -r src dst` |
| 移动/重命名 | `Move-Item old new` | `mv old new` |
| 删除文件 | `Remove-Item file.txt` | `rm file.txt` |
| 删除目录 | `Remove-Item dir -Recurse` | `rm -r dir` |

## 文本查看与搜索

| 场景 | PowerShell | Bash/Linux |
| --- | --- | --- |
| 查看文件 | `Get-Content app.log` | `cat app.log` |
| 查看前 20 行 | `Get-Content app.log -TotalCount 20` | `head -n 20 app.log` |
| 查看后 20 行 | `Get-Content app.log -Tail 20` | `tail -n 20 app.log` |
| 实时看日志 | `Get-Content app.log -Wait` | `tail -f app.log` |
| 搜索文本 | `Select-String -Path *.log -Pattern "error"` | `grep "error" *.log` |
| 递归搜索 | `Select-String -Path **/*.log -Pattern "error"` | `grep -R "error" .` |

## 进程、端口与服务

| 场景 | PowerShell | Bash/Linux |
| --- | --- | --- |
| 查看进程 | `Get-Process` | `ps aux` |
| 查找进程 | `Get-Process nginx` | `pgrep -a nginx` |
| 停止进程 | `Stop-Process -Id 1234` | `kill 1234` |
| 强制停止 | `Stop-Process -Id 1234 -Force` | `kill -9 1234` |
| 查看 TCP 连接 | `Get-NetTCPConnection` | `ss -tan` |
| 查看监听端口 | `Get-NetTCPConnection -State Listen` | `ss -tulnp` |
| 查看服务 | `Get-Service` | `systemctl list-units --type=service` |
| 重启服务 | `Restart-Service nginx` | `sudo systemctl restart nginx` |

## 管道差异

PowerShell 管道传递的是对象:

```powershell
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name,CPU
```

Bash 管道传递的是文本:

```bash
ps aux --sort=-%cpu | head -n 6
```

## 安全建议

- PowerShell 删除前可以先加 `-WhatIf` 预览。
- Linux 删除前先用 `ls` 或 `find` 确认范围。
- 批量操作时优先在测试目录验证。
