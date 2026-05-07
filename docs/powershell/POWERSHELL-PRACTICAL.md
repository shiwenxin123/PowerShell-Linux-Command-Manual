# PowerShell 实用场景

PowerShell 的核心优势是对象管道。日常运维中，尽量使用结构化对象筛选，而不是把输出当普通文本处理。

## 进程排查

```powershell
# 按 CPU 排序
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, Id, CPU

# 按内存排序
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, Id, WorkingSet

# 查找指定进程
Get-Process -Name "nginx" -ErrorAction SilentlyContinue
```

## 文件搜索

```powershell
# 查找日志文件
Get-ChildItem -Path C:\Logs -Recurse -Filter "*.log"

# 搜索错误关键字
Select-String -Path C:\Logs\*.log -Pattern "error"

# 查找大文件
Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue |
  Where-Object Length -gt 500MB |
  Sort-Object Length -Descending |
  Select-Object -First 20 FullName, Length
```

## 服务管理

```powershell
# 查看服务
Get-Service

# 查看指定服务
Get-Service -Name "Spooler"

# 重启服务
Restart-Service -Name "Spooler"
```

## 删除前预览

```powershell
# 预览将要删除的内容
Remove-Item C:\Temp\old -Recurse -Force -WhatIf

# 确认无误后再执行
Remove-Item C:\Temp\old -Recurse -Force
```

## 网络排查

```powershell
# Ping 测试
Test-Connection example.com

# 测试端口
Test-NetConnection example.com -Port 443

# 查看监听端口
Get-NetTCPConnection -State Listen
```
