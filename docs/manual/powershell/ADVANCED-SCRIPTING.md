# PowerShell 高级技巧

这个专题从主手册迁移 PowerShell 管道、对象、变量、脚本控制流和错误处理内容。

## 管道与对象操作

```powershell
# 选择特定属性
Get-Process | Select-Object Name, ID, WorkingSet

# 过滤对象
Get-Process | Where-Object { $_.WorkingSet -gt 100MB }

# 排序
Get-Process | Sort-Object WorkingSet -Descending

# 分组
Get-Process | Group-Object -Property PriorityClass

# 测量
Get-ChildItem | Measure-Object -Property Length -Sum -Average -Maximum -Minimum
```

复杂管道示例:

```powershell
Get-WmiObject Win32_Service |
    Where-Object { $_.State -eq "Running" } |
    Group-Object -Property StartMode |
    Select-Object Name, Count |
    Sort-Object Count -Descending
```

## 变量与集合

```powershell
$name = "PowerShell"
$number = 42
$array = 1, 2, 3, 4, 5
$hash = @{ Key1 = "Value1"; Key2 = "Value2" }

# 数组
$array[0]
$array[-1]
$array[1..3]

# 哈希表
$hash["Key1"]
$hash.NewKey = "NewValue"
```

## 控制流

```powershell
if ($number -gt 40) {
    Write-Host "Number is greater than 40"
} elseif ($number -eq 40) {
    Write-Host "Number is exactly 40"
} else {
    Write-Host "Number is less than 40"
}

switch ($number) {
    42 { Write-Host "The answer!" }
    { $_ -gt 40 } { Write-Host "Greater than 40" }
    default { Write-Host "Something else" }
}
```

## 循环

```powershell
for ($i = 0; $i -lt 5; $i++) {
    Write-Host "Iteration $i"
}

foreach ($item in $array) {
    Write-Host "Item: $item"
}

$array | ForEach-Object { Write-Host "Item: $_" }

$i = 0
while ($i -lt 5) {
    Write-Host "Iteration $i"
    $i++
}
```

## 函数

```powershell
function Get-Hello {
    param([string]$Name = "World")
    Write-Host "Hello, $Name!"
}

Get-Hello -Name "PowerShell"
```

## 错误处理

```powershell
try {
    Get-Content -Path "nonexistent.txt" -ErrorAction Stop
} catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "File not found: $_"
} catch {
    Write-Host "An error occurred: $_"
} finally {
    Write-Host "This always runs"
}

if (Get-Command -Name "NonExistentCommand" -ErrorAction SilentlyContinue) {
    Write-Host "Command exists"
} else {
    Write-Host "Command does not exist"
}
```
