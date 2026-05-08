# PowerShell 基础命令

这个页面整理 PowerShell 日常使用最频繁的文件、目录、文本查看和搜索命令。根目录主手册已收口为总导航，后续详细内容以本专题页为准。

## 目录导航

```powershell
# 查看当前路径
Get-Location

# 切换目录
Set-Location C:\Users

# 返回上级目录
Set-Location ..

# 切换到用户主目录
Set-Location ~
```

## 文件与目录

```powershell
# 列出当前目录内容
Get-ChildItem

# 列出隐藏文件
Get-ChildItem -Force

# 递归列出文件
Get-ChildItem -Recurse

# 创建目录
New-Item -ItemType Directory demo

# 创建文件
New-Item notes.txt
```

## 读取与搜索

```powershell
# 查看文件内容
Get-Content .\app.log

# 查看前 20 行
Get-Content .\app.log -TotalCount 20

# 查看后 100 行
Get-Content .\app.log -Tail 100

# 实时查看日志
Get-Content .\app.log -Tail 100 -Wait

# 搜索关键字
Select-String -Path .\*.log -Pattern "error"
```

## 复制、移动和删除

```powershell
# 复制文件
Copy-Item source.txt dest.txt

# 复制目录
Copy-Item source_dir dest_dir -Recurse

# 移动或重命名
Move-Item old.txt new.txt

# 删除文件
Remove-Item file.txt

# 删除目录前预览
Remove-Item C:\Temp\old -Recurse -Force -WhatIf
```

## 安全提醒

`Remove-Item -Recurse -Force` 属于高危删除命令。生产环境执行前建议先使用 `-WhatIf` 预览，确认路径无误后再执行。
