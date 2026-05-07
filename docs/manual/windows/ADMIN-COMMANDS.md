# Windows 管理命令

这个页面整理 Windows 运维中常用的 PowerShell 管理命令，覆盖事件日志、注册表、计划任务、防火墙和远程管理。

## 事件日志

```powershell
# 查看系统日志
Get-WinEvent -LogName System -MaxEvents 20

# 查看应用日志
Get-WinEvent -LogName Application -MaxEvents 20

# 按级别筛选错误
Get-WinEvent -FilterHashtable @{LogName="System"; Level=2} -MaxEvents 20

# 传统事件日志命令
Get-EventLog -LogName System -Newest 20
```

## 注册表

```powershell
# 读取注册表
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion"

# 创建键
New-Item -Path "HKCU:\Software\Demo" -Force

# 设置值
Set-ItemProperty -Path "HKCU:\Software\Demo" -Name "Enabled" -Value 1

# 删除值
Remove-ItemProperty -Path "HKCU:\Software\Demo" -Name "Enabled"
```

风险提醒: 修改注册表可能影响系统或应用行为，执行前建议导出备份。

## 计划任务

```powershell
# 查看计划任务
Get-ScheduledTask

# 查看指定任务
Get-ScheduledTask -TaskName "<task>"

# 启动任务
Start-ScheduledTask -TaskName "<task>"

# 停止任务
Stop-ScheduledTask -TaskName "<task>"
```

## Windows 防火墙

```powershell
# 查看防火墙规则
Get-NetFirewallRule

# 查看启用的入站规则
Get-NetFirewallRule -Direction Inbound -Enabled True

# 新增允许端口规则
New-NetFirewallRule -DisplayName "Allow 8080" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow

# 禁用规则
Disable-NetFirewallRule -DisplayName "Allow 8080"
```

## 远程管理

```powershell
# 进入远程会话
Enter-PSSession -ComputerName <host>

# 远程执行命令
Invoke-Command -ComputerName <host> -ScriptBlock { hostname }

# 测试 WinRM
Test-WSMan <host>
```

## 软件包与模块

```powershell
# winget 搜索和安装
winget search <package>
winget install <package>

# PowerShell 模块
Find-Module <module>
Install-Module <module> -Scope CurrentUser
```

## 排查建议

- 先用 `Get-WinEvent` 查系统和应用日志。
- 服务类问题结合 `Get-Service`、`Get-Process`。
- 网络类问题结合 `Test-NetConnection` 和 `Get-NetTCPConnection`。
- 远程管理失败时检查 WinRM、防火墙、账号权限和网络连通。
