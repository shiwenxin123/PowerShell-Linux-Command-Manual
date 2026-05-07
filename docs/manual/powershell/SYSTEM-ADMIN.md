# PowerShell 系统管理

PowerShell 适合做 Windows 系统信息采集、进程排查、服务管理和网络诊断。

## 系统信息

```powershell
# 查看系统信息
Get-ComputerInfo

# 查看计算机名称
$env:COMPUTERNAME

# 查看磁盘
Get-PSDrive -PSProvider FileSystem
```

## 进程管理

```powershell
# 查看进程
Get-Process

# 按 CPU 排序
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, Id, CPU

# 按内存排序
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, Id, WorkingSet

# 停止进程
Stop-Process -Id <PID>
```

## 服务管理

```powershell
# 查看服务
Get-Service

# 查看指定服务
Get-Service -Name "Spooler"

# 启动服务
Start-Service -Name "Spooler"

# 停止服务
Stop-Service -Name "Spooler"

# 重启服务
Restart-Service -Name "Spooler"
```

## 网络诊断

```powershell
# Ping 测试
Test-Connection example.com

# 测试端口
Test-NetConnection example.com -Port 443

# 查看 TCP 连接
Get-NetTCPConnection

# 查看监听端口
Get-NetTCPConnection -State Listen
```

## 延伸阅读

- [PowerShell 实用场景](../../powershell/POWERSHELL-PRACTICAL.md)
- [PowerShell 与 Bash 命令对照](../../POWERSHELL-BASH-COMPARISON.md)
