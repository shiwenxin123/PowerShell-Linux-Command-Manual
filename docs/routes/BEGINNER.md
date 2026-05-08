# 新手路线

这条路线适合刚开始接触 PowerShell、Linux 或运维命令的读者。建议先掌握“怎么查、怎么确认、怎么避免高危操作”，再进入更细的专题。

## 学习顺序

| 阶段 | 目标 | 推荐文档 |
| --- | --- | --- |
| 1. 建立全局索引 | 知道项目里有哪些命令和专题 | [命令速查表](../COMMAND-CHEATSHEET.md)、[命令索引](../COMMAND-INDEX.md) |
| 2. 学 PowerShell 基础 | 掌握文件、目录、进程、服务等基础命令 | [PowerShell 基础](../manual/powershell/BASIC.md) |
| 3. 学 Linux 基础 | 掌握目录、文件、文本、进程和资源查看 | [Linux 基础](../manual/linux/BASIC.md) |
| 4. 理解跨平台差异 | 建立 PowerShell 和 Bash 的对应关系 | [PowerShell/Bash 对照](../POWERSHELL-BASH-COMPARISON.md) |
| 5. 认识风险命令 | 避免误删、误改权限、误重启服务 | [命令风险等级](../security/RISK-LEVELS.md) |

## 先掌握这些命令

```bash
pwd
ls -la
cd /path
cat file
tail -n 100 file
grep "keyword" file
ps aux
df -h
free -h
```

```powershell
Get-Location
Get-ChildItem
Set-Location C:\Path
Get-Content .\file.txt
Select-String -Path .\file.txt -Pattern "keyword"
Get-Process
Get-Service
```

## 常见学习路径

- 如果目标是日常查命令，优先看 [命令速查表](../COMMAND-CHEATSHEET.md)。
- 如果目标是从 Windows 转 Linux，优先看 [PowerShell/Bash 对照](../POWERSHELL-BASH-COMPARISON.md)。
- 如果目标是排障，学完基础后进入 [运维值班路线](OPS-ONCALL.md)。
- 如果目标是自动化，继续看 [Shell 脚本](../manual/linux/SHELL-SCRIPTING.md) 和 [巡检脚本工具化](../manual/automation/HEALTH-CHECK-SCRIPTS.md)。

## 下一步

- [运维值班路线](OPS-ONCALL.md)
- [Kubernetes 排障路线](KUBERNETES-TROUBLESHOOTING.md)
- [国产 Linux 路线](DOMESTIC-LINUX.md)
