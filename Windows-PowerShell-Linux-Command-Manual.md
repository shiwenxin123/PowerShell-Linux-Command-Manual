# Windows PowerShell 与 Linux 常用命令手册

> 版本: 2.0  
> 最后更新: 2026-03-13  
> 说明: 包含详细命令注释、高级用法与最佳实践，新增银河麒麟、统信 UOS 专用命令与专业运维内容
>
> 项目导航: [README](README.md) | [命令速查表](docs/COMMAND-CHEATSHEET.md) | [PowerShell/Bash 对照](docs/POWERSHELL-BASH-COMPARISON.md) | [Linux 排障清单](docs/troubleshooting/LINUX-INCIDENT-CHECKLIST.md) | [贡献指南](CONTRIBUTING.md)
>
> 安全提醒: 删除、格式化、权限修改、服务重启等命令可能影响系统或数据。执行 `rm -rf`、`Remove-Item -Recurse -Force`、`chmod -R`、`chown -R`、`mkfs`、`dd` 等命令前，请先确认目标路径、备份和执行环境。
>
> 风险等级说明: 高危命令请参考 [命令风险等级说明](docs/security/RISK-LEVELS.md)，后续贡献命令时建议统一标注风险等级、执行前检查和回滚建议。

---

## 目录

1. [Windows PowerShell 命令](#windows-powershell-命令)
2. [Linux 常用命令](#linux-常用命令)
3. [银河麒麟 (Kylin) 专用命令](#银河麒麟-kylin-专用命令)
4. [统信 UOS 专用命令](#统信-uos-专用命令)
5. [专业运维与安全加固](#专业运维与安全加固)
6. [跨平台脚本与工具](#跨平台脚本与工具)

---

## Windows PowerShell 命令

### 一、基础导航与文件操作

#### 1.1 目录导航

```powershell
# 查看当前目录
Get-Location
# 简写: pwd

# 切换目录
Set-Location C:\Users\YourName\Desktop
# 简写: cd C:\Users\YourName\Desktop

# 返回上一级目录
Set-Location ..
# 简写: cd ..

# 切换到用户主目录
Set-Location ~
# 简写: cd ~

# 切换到上次所在目录
Set-Location -
```

#### 1.2 列出目录内容

```powershell
# 列出当前目录内容
Get-ChildItem
# 简写: ls 或 dir

# 列出所有文件(包括隐藏文件)
Get-ChildItem -Force

# 递归列出所有子目录内容
Get-ChildItem -Recurse

# 只列出目录
Get-ChildItem -Directory

# 只列出文件
Get-ChildItem -File

# 按文件大小排序
Get-ChildItem | Sort-Object Length -Descending

# 按修改时间排序
Get-ChildItem | Sort-Object LastWriteTime -Descending

# 只显示特定扩展名的文件
Get-ChildItem -Filter *.txt

# 高级: 查找大于 100MB 的文件
Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | 
    Where-Object { $_.Length -gt 100MB } | 
    Select-Object FullName, @{Name="Size(MB)";Expression={[math]::Round($_.Length/1MB,2)}}
```

#### 1.3 文件与目录操作

```powershell
# 创建新目录
New-Item -Path "C:\test" -ItemType Directory
# 简写: mkdir C:\test

# 创建新文件
New-Item -Path "C:\test\file.txt" -ItemType File

# 写入内容到文件(覆盖)
Set-Content -Path "file.txt" -Value "Hello World"

# 追加内容到文件
Add-Content -Path "file.txt" -Value "Another line"

# 读取文件内容
Get-Content -Path "file.txt"
# 简写: cat file.txt

# 读取文件前 5 行
Get-Content -Path "file.txt" -Head 5

# 读取文件后 10 行
Get-Content -Path "file.txt" -Tail 10

# 实时监控文件变化
Get-Content -Path "file.txt" -Wait

# 复制文件
Copy-Item -Path "source.txt" -Destination "dest.txt"
# 简写: cp source.txt dest.txt

# 复制目录及其所有内容
Copy-Item -Path "source_dir" -Destination "dest_dir" -Recurse

# 移动/重命名文件
Move-Item -Path "old.txt" -Destination "new.txt"
# 简写: mv old.txt new.txt

# 删除文件
Remove-Item -Path "file.txt"
# 简写: rm file.txt

# 删除目录及其所有内容(不提示)
Remove-Item -Path "dir" -Recurse -Force

# 高级: 批量重命名文件
Get-ChildItem -Filter *.log | ForEach-Object {
    Rename-Item -Path $_.FullName -NewName ($_.BaseName + "_backup" + $_.Extension)
}
```

### 二、系统信息与管理

#### 2.1 系统信息

```powershell
# 获取操作系统信息
Get-ComputerInfo

# 获取计算机名称
$env:COMPUTERNAME

# 获取 Windows 版本
[System.Environment]::OSVersion.Version

# 获取处理器信息
Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors

# 获取内存信息
Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | 
    Select-Object @{Name="TotalMemory(GB)";Expression={[math]::Round($_.Sum/1GB,2)}}

# 获取磁盘信息
Get-PSDrive -PSProvider FileSystem | Select-Object Name, 
    @{Name="Used(GB)";Expression={[math]::Round($_.Used/1GB,2)}},
    @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB,2)}}

# 获取主板信息
Get-WmiObject Win32_BaseBoard | Select-Object Manufacturer, Product

# 获取 BIOS 信息
Get-WmiObject Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate
```

#### 2.2 进程管理

```powershell
# 列出所有进程
Get-Process
# 简写: ps

# 查找特定进程
Get-Process -Name notepad

# 按内存使用排序进程
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10

# 按 CPU 时间排序进程
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

# 启动进程
Start-Process -FilePath "notepad.exe"

# 启动进程并等待完成
Start-Process -FilePath "notepad.exe" -Wait

# 停止进程
Stop-Process -Name notepad

# 强制停止进程
Stop-Process -Id 1234 -Force

# 高级: 找出并停止占用特定端口的进程
$port = 8080
$processes = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
if ($processes) {
    $processes | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }
}
```

#### 2.3 服务管理

```powershell
# 列出所有服务
Get-Service

# 列出正在运行的服务
Get-Service | Where-Object { $_.Status -eq "Running" }

# 查找特定服务
Get-Service -Name wuauserv

# 启动服务
Start-Service -Name wuauserv

# 停止服务
Stop-Service -Name wuauserv

# 重启服务
Restart-Service -Name wuauserv

# 设置服务启动类型
Set-Service -Name wuauserv -StartupType Automatic
# 选项: Automatic, AutomaticDelayedStart, Manual, Disabled
```

### 三、网络相关命令

#### 3.1 网络配置

```powershell
# 获取网络适配器信息
Get-NetAdapter

# 获取 IP 地址信息
Get-NetIPAddress

# 获取 DNS 配置
Get-DnsClientServerAddress

# 设置静态 IP 地址
New-NetIPAddress -InterfaceIndex 3 -IPAddress 192.168.1.100 -PrefixLength 24 -DefaultGateway 192.168.1.1

# 设置 DNS 服务器
Set-DnsClientServerAddress -InterfaceIndex 3 -ServerAddresses ("8.8.8.8","8.8.4.4")

# 刷新 DNS 缓存
Clear-DnsClientCache
```

#### 3.2 网络诊断

```powershell
# Ping 测试
Test-Connection -ComputerName google.com

# Ping 测试并指定次数
Test-Connection -ComputerName google.com -Count 10

# 路由跟踪
Test-NetConnection -ComputerName google.com -TraceRoute

# 测试端口连接
Test-NetConnection -ComputerName google.com -Port 80

# 获取网络连接
Get-NetTCPConnection

# 查看监听端口
Get-NetTCPConnection -State Listen

# 高级: 查看所有网络连接及其所属进程
Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess | 
    ForEach-Object {
        $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            LocalAddress = $_.LocalAddress
            LocalPort = $_.LocalPort
            RemoteAddress = $_.RemoteAddress
            RemotePort = $_.RemotePort
            State = $_.State
            ProcessName = if ($proc) { $proc.ProcessName } else { "Unknown" }
            PID = $_.OwningProcess
        }
    }
```

### 四、用户与权限管理

```powershell
# 获取当前用户信息
[System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# 检查是否以管理员身份运行
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) { Write-Host "Running as Administrator" }

# 列出本地用户
Get-LocalUser

# 创建新用户
New-LocalUser -Name "TestUser" -Password (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) -FullName "Test User"

# 删除用户
Remove-LocalUser -Name "TestUser"

# 列出本地组
Get-LocalGroup

# 列出管理员组成员
Get-LocalGroupMember -Group "Administrators"

# 将用户添加到组
Add-LocalGroupMember -Group "Administrators" -Member "TestUser"

# 从组中移除用户
Remove-LocalGroupMember -Group "Administrators" -Member "TestUser"
```

### 五、PowerShell 高级技巧

#### 5.1 管道与对象操作

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

# 高级: 复杂管道操作示例
Get-WmiObject Win32_Service | 
    Where-Object { $_.State -eq "Running" } | 
    Group-Object -Property StartMode | 
    Select-Object Name, Count | 
    Sort-Object Count -Descending
```

#### 5.2 变量与脚本

```powershell
# 定义变量
$name = "PowerShell"
$number = 42
$array = 1, 2, 3, 4, 5
$hash = @{ Key1 = "Value1"; Key2 = "Value2" }

# 数组操作
$array[0]       # 访问第一个元素
$array[-1]      # 访问最后一个元素
$array[1..3]    # 访问第 2-4 个元素

# 哈希表操作
$hash["Key1"]   # 访问值
$hash.NewKey = "NewValue"  # 添加键值对

# 条件语句
if ($number -gt 40) {
    Write-Host "Number is greater than 40"
} elseif ($number -eq 40) {
    Write-Host "Number is exactly 40"
} else {
    Write-Host "Number is less than 40"
}

# Switch 语句
switch ($number) {
    42 { Write-Host "The answer!" }
    { $_ -gt 40 } { Write-Host "Greater than 40" }
    default { Write-Host "Something else" }
}

# For 循环
for ($i = 0; $i -lt 5; $i++) {
    Write-Host "Iteration $i"
}

# ForEach 循环
foreach ($item in $array) {
    Write-Host "Item: $item"
}

# ForEach-Object (管道)
$array | ForEach-Object { Write-Host "Item: $_" }

# While 循环
$i = 0
while ($i -lt 5) {
    Write-Host "Iteration $i"
    $i++
}

# 定义函数
function Get-Hello {
    param([string]$Name = "World")
    Write-Host "Hello, $Name!"
}

# 调用函数
Get-Hello -Name "PowerShell"
```

#### 5.3 错误处理

```powershell
# 尝试执行命令并捕获错误
try {
    Get-Content -Path "nonexistent.txt" -ErrorAction Stop
} catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "File not found: $_"
} catch {
    Write-Host "An error occurred: $_"
} finally {
    Write-Host "This always runs"
}

# 检查命令是否成功
if (Get-Command -Name "NonExistentCommand" -ErrorAction SilentlyContinue) {
    Write-Host "Command exists"
} else {
    Write-Host "Command does not exist"
}
```

---

## Linux 常用命令

### 一、基础导航与文件操作

#### 1.1 目录导航

```bash
# 查看当前目录
pwd
# 输出: /home/user

# 切换目录
cd /home/user/Documents

# 返回上一级目录
cd ..

# 返回上两级目录
cd ../..

# 切换到用户主目录
cd
# 或
cd ~

# 切换到上次所在目录
cd -

# 快速切换到常用目录(需要先设置 CDPATH)
export CDPATH=.:~:/projects
```

#### 1.2 列出目录内容

```bash
# 列出当前目录内容
ls

# 列出详细信息
ls -l
# 输出: -rw-r--r-- 1 user user  4096 Mar 13 10:00 file.txt

# 列出所有文件(包括隐藏文件)
ls -a

# 组合使用: 详细信息 + 所有文件
ls -la

# 按文件大小排序(降序)
ls -lhS

# 按修改时间排序(最新在前)
ls -lt

# 按修改时间排序(最新在后)
ls -ltr

# 只列出目录
ls -d */

# 递归列出所有子目录内容
ls -R

# 显示文件大小(人类可读格式)
ls -lh

# 高级: 查找最大的 10 个文件
du -ah / | sort -rh | head -n 10
```

#### 1.3 文件与目录操作

```bash
# 创建新目录
mkdir new_dir

# 创建多级目录
mkdir -p path/to/dir

# 创建新文件
touch new_file.txt

# 写入内容到文件(覆盖)
echo "Hello World" > file.txt

# 追加内容到文件
echo "Another line" >> file.txt

# 写入多行内容
cat > file.txt << 'EOF'
Line 1
Line 2
Line 3
EOF

# 读取文件内容
cat file.txt

# 分页读取大文件
less file.txt
# 操作: 空格=下一页, b=上一页, q=退出, /搜索

# 读取文件前 5 行
head -n 5 file.txt

# 读取文件后 10 行
tail -n 10 file.txt

# 实时监控文件变化
tail -f file.txt

# 查看文件类型
file file.txt

# 复制文件
cp source.txt dest.txt

# 复制目录及其所有内容
cp -r source_dir dest_dir

# 复制并保留权限、时间戳
cp -a source dest

# 移动/重命名文件
mv old.txt new.txt

# 删除文件
rm file.txt

# 强制删除文件(不提示)
rm -f file.txt

# 删除目录及其所有内容
# 高危操作: 执行前先用 ls dir 确认目标目录
rm -rf dir

# 创建文件链接(硬链接)
ln file.txt link.txt

# 创建符号链接(软链接)
ln -s file.txt link.txt

# 高级: 批量重命名文件(使用 rename 命令)
rename 's/\.log$/_backup.log/' *.log

# 高级: 使用 for 循环批量重命名
for file in *.log; do
    mv "$file" "${file%.log}_backup.log"
done
```

#### 1.4 文件内容搜索与处理

```bash
# 在文件中搜索字符串
grep "pattern" file.txt

# 递归搜索目录
grep -r "pattern" /path/to/dir

# 忽略大小写
grep -i "pattern" file.txt

# 显示行号
grep -n "pattern" file.txt

# 显示不匹配的行
grep -v "pattern" file.txt

# 只显示匹配的文件名
grep -l "pattern" *.txt

# 使用正则表达式
grep -E "pattern1|pattern2" file.txt

# 高级: awk 基本用法
# 打印第一列
awk '{print $1}' file.txt

# 打印最后一列
awk '{print $NF}' file.txt

# 打印包含 "error" 的行
awk '/error/' file.txt

# 计算列的总和
awk '{sum += $1} END {print sum}' file.txt

# 高级: sed 基本用法
# 替换文本
sed 's/old/new/g' file.txt

# 只替换第 2 次出现
sed 's/old/new/2' file.txt

# 删除包含 "pattern" 的行
sed '/pattern/d' file.txt

# 删除第 5-10 行
sed '5,10d' file.txt

# 插入行
sed '3i\New line' file.txt

# 高级: sort 与 uniq
# 排序
sort file.txt

# 反向排序
sort -r file.txt

# 按数字排序
sort -n file.txt

# 去重(需要先排序)
sort file.txt | uniq

# 统计重复次数
sort file.txt | uniq -c
```

### 二、系统信息与管理

#### 2.1 系统信息

```bash
# 显示系统信息
uname -a
# 输出: Linux host 5.4.0-90-generic #101-Ubuntu SMP Fri Oct 15 20:00:00 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux

# 显示内核版本
uname -r

# 显示发行版信息
cat /etc/os-release

# 显示主机名
hostname

# 显示系统运行时间
uptime
# 输出: 10:00:00 up 10 days, 2:30, 1 user, load average: 0.00, 0.01, 0.05

# 显示当前登录用户
who

# 显示当前用户及其操作
w

# 显示 CPU 信息
cat /proc/cpuinfo

# 显示内存信息
cat /proc/meminfo

# 以人类可读格式显示内存使用
free -h

# 显示磁盘使用
df -h

# 显示目录大小
du -sh /path/to/dir

# 高级: 完整系统信息概览
# 需要安装: sudo apt install inxi
inxi -Fxz
```

#### 2.2 进程管理

```bash
# 列出当前终端的进程
ps

# 列出所有进程
ps aux
# a=所有用户, u=显示用户, x=显示无控制终端的进程

# 列出所有进程(完整格式)
ps -ef

# 查找特定进程
ps aux | grep nginx

# 以树状显示进程
pstree

# 实时监控进程
top

# 更现代的进程监控
# 需要安装: sudo apt install htop
htop

# 按名称查找进程 PID
pgrep nginx

# 按名称查找进程(详细)
pidof nginx

# 终止进程(默认发送 TERM 信号)
kill 1234

# 强制终止进程
kill -9 1234

# 按名称终止进程
pkill nginx

# 按名称强制终止进程
pkill -9 nginx

# 显示进程打开的文件
lsof -p 1234

# 显示打开某个文件的进程
lsof /path/to/file

# 显示监听端口的进程
lsof -i :80

# 高级: 找出 CPU 使用率最高的 10 个进程
ps aux --sort=-%cpu | head -n 11

# 高级: 找出内存使用率最高的 10 个进程
ps aux --sort=-%mem | head -n 11
```

#### 2.3 服务管理 (systemd)

```bash
# 列出所有服务
systemctl list-units --type=service

# 列出正在运行的服务
systemctl list-units --type=service --state=running

# 查看服务状态
systemctl status nginx

# 启动服务
systemctl start nginx

# 停止服务
systemctl stop nginx

# 重启服务
systemctl restart nginx

# 重载服务配置
systemctl reload nginx

# 设置开机自启
systemctl enable nginx

# 禁止开机自启
systemctl disable nginx

# 查看服务开机自启状态
systemctl is-enabled nginx

# 查看服务日志
journalctl -u nginx

# 查看服务最近的日志
journalctl -u nginx -n 50

# 实时监控服务日志
journalctl -u nginx -f

# 查看系统启动日志
journalctl -b
```

#### 2.4 包管理

```bash
# Ubuntu/Debian 系统
# 更新包列表
apt update

# 升级所有已安装的包
apt upgrade

# 完整系统升级
apt full-upgrade

# 安装包
apt install package_name

# 安装多个包
apt install package1 package2 package3

# 移除包(保留配置)
apt remove package_name

# 移除包(删除配置)
apt purge package_name

# 自动移除不需要的依赖
apt autoremove

# 搜索包
apt search keyword

# 显示包信息
apt show package_name

# 查看已安装的包
dpkg -l

# 查看某个文件属于哪个包
dpkg -S /path/to/file

# CentOS/RHEL 系统
# 安装包
yum install package_name

# 或使用 dnf
dnf install package_name

# 升级包
yum update

# 搜索包
yum search keyword

# Arch Linux
# 安装包
pacman -S package_name

# 升级系统
pacman -Syu

# 搜索包
pacman -Ss keyword
```

### 三、网络相关命令

#### 3.1 网络配置

```bash
# 显示网络接口信息
ip addr show

# 简写
ip a

# 显示接口统计信息
ip -s link

# 显示路由表
ip route show

# 简写
ip r

# 配置临时 IP 地址
ip addr add 192.168.1.100/24 dev eth0

# 配置默认网关
ip route add default via 192.168.1.1

# 启用接口
ip link set eth0 up

# 禁用接口
ip link set eth0 down

# 显示 DNS 配置
cat /etc/resolv.conf

# 传统工具(已逐渐被 ip 替代)
ifconfig
route
```

#### 3.2 网络诊断

```bash
# Ping 测试
ping google.com

# Ping 测试并指定次数
ping -c 10 google.com

# Ping 测试并设置超时
ping -W 2 google.com

# 路由跟踪
traceroute google.com

# 或使用 mtr(更好的工具)
# 需要安装: sudo apt install mtr
mtr google.com

# DNS 查询
nslookup google.com

# 更强大的 DNS 查询工具
dig google.com

# 查询 MX 记录
dig google.com MX

# 测试端口连接(使用 telnet)
telnet google.com 80

# 测试端口连接(使用 netcat)
nc -zv google.com 80

# 测试端口连接(使用 curl)
curl -v telnet://google.com:80

# 显示网络连接
netstat -tuln

# 或使用 ss(更现代的工具)
ss -tuln

# 显示所有网络连接
ss -tupa

# 高级: 查看所有网络连接及其进程
ss -tupn

# 高级: 查看监听端口
ss -tuln
```

#### 3.3 文件传输

```bash
# 使用 scp 复制文件到远程服务器
scp local_file.txt user@remote:/path/to/dest/

# 使用 scp 从远程服务器复制文件
scp user@remote:/path/to/remote_file.txt /local/dest/

# 复制目录
scp -r local_dir user@remote:/path/to/dest/

# 使用 sftp 交互式文件传输
sftp user@remote

# 使用 rsync 同步文件(推荐)
rsync -avz local_file.txt user@remote:/path/to/dest/

# 同步目录
rsync -avz local_dir/ user@remote:/path/to/dest/

# 带进度显示的同步
rsync -avz --progress local_dir/ user@remote:/path/to/dest/

# 只同步更新的文件
rsync -avzu local_dir/ user@remote:/path/to/dest/

# 删除目标位置中源位置没有的文件
rsync -avz --delete local_dir/ user@remote:/path/to/dest/
```

#### 3.4 SSH 远程登录

```bash
# 基本 SSH 登录
ssh user@remote_host

# 使用非标准端口
ssh -p 2222 user@remote_host

# 使用私钥登录
ssh -i /path/to/private_key user@remote_host

# SSH 配置文件 (~/.ssh/config)
# 编辑配置文件可以简化登录
cat >> ~/.ssh/config << 'EOF'
Host myserver
    HostName 192.168.1.100
    User username
    Port 2222
    IdentityFile ~/.ssh/myserver_key
EOF

# 使用配置文件登录
ssh myserver

# SSH 密钥对生成
ssh-keygen -t ed25519 -C "your_email@example.com"

# 复制公钥到远程服务器
ssh-copy-id user@remote_host

# SSH 端口转发
# 本地转发: 将本地端口转发到远程
ssh -L 8080:localhost:80 user@remote_host

# 远程转发: 将远程端口转发到本地
ssh -R 9000:localhost:3000 user@remote_host

# 动态转发(SOCKS 代理)
ssh -D 1080 user@remote_host
```

### 四、用户与权限管理

#### 4.1 用户管理

```bash
# 显示当前用户
whoami

# 显示用户 ID 和组 ID
id

# 切换到其他用户
su - username

# 以 root 身份执行命令
sudo command

# 切换到 root 用户
sudo su -
# 或
sudo -i

# 创建新用户
useradd -m username

# 创建用户并指定 shell
useradd -m -s /bin/bash username

# 设置用户密码
passwd username

# 删除用户(保留主目录)
userdel username

# 删除用户(删除主目录和邮箱)
userdel -r username

# 修改用户信息
usermod -c "Full Name" username

# 修改用户 shell
usermod -s /bin/zsh username

# 显示所有用户
cat /etc/passwd

# 显示当前登录用户
who

# 显示用户登录历史
last
```

#### 4.2 组管理

```bash
# 创建新组
groupadd groupname

# 删除组
groupdel groupname

# 将用户添加到组
usermod -aG groupname username

# 从组中移除用户
gpasswd -d username groupname

# 显示用户所属组
groups username

# 显示所有组
cat /etc/group

# 显示组中的成员
getent group groupname
```

#### 4.3 权限管理

```bash
# 显示文件权限
ls -l file.txt
# 输出: -rw-r--r-- 1 user user  4096 Mar 13 10:00 file.txt
# 权限说明:
# - rw- r-- r--
#   |  |   |   |
#   |  |   |   其他用户权限
#   |  |   组用户权限
#   |  所有者权限
#   文件类型 (-=文件, d=目录, l=链接)

# 权限值:
# r = 4 (读)
# w = 2 (写)
# x = 1 (执行)

# 修改文件权限(符号模式)
chmod u+x file.txt          # 所有者添加执行权限
chmod g-w file.txt          # 组用户移除写权限
chmod o=r file.txt          # 其他用户只读
chmod a+x file.txt          # 所有用户添加执行权限

# 修改文件权限(数字模式)
chmod 755 file.txt          # rwxr-xr-x
chmod 644 file.txt          # rw-r--r--
chmod 600 file.txt          # rw------- (仅所有者可读写)

# 修改文件所有者
chown user file.txt

# 修改文件所有者和组
chown user:group file.txt

# 递归修改目录所有者
chown -R user:group dir/

# 修改文件组
chgrp group file.txt

# 特殊权限
# SUID: 以文件所有者身份执行
chmod 4755 file.txt

# SGID: 以文件组身份执行
chmod 2755 file.txt

# Sticky Bit: 目录中只有所有者可删除文件
chmod 1777 dir/
```

### 五、Shell 脚本与高级技巧

#### 5.1 Shell 脚本基础

```bash
#!/bin/bash
# 这是一个 Shell 脚本示例

# 定义变量
NAME="World"
NUMBER=42
ARRAY=(1 2 3 4 5)

# 使用变量
echo "Hello, $NAME!"
echo "Number: $NUMBER"
echo "First array element: ${ARRAY[0]}"

# 命令替换
CURRENT_DIR=$(pwd)
echo "Current directory: $CURRENT_DIR"

# 算术运算
RESULT=$((3 + 4 * 2))
echo "Result: $RESULT"

# 条件语句
if [ $NUMBER -gt 40 ]; then
    echo "Number is greater than 40"
elif [ $NUMBER -eq 40 ]; then
    echo "Number is exactly 40"
else
    echo "Number is less than 40"
fi

# 字符串比较
if [ "$NAME" = "World" ]; then
    echo "Name is World"
fi

# 文件测试
if [ -f "file.txt" ]; then
    echo "file.txt exists and is a regular file"
fi

if [ -d "dir" ]; then
    echo "dir exists and is a directory"
fi

# 常用测试条件:
# -f: 存在且是普通文件
# -d: 存在且是目录
# -e: 存在
# -r: 存在且可读
# -w: 存在且可写
# -x: 存在且可执行
# -s: 存在且大小大于 0

# For 循环
for i in 1 2 3 4 5; do
    echo "Iteration $i"
done

# For 循环(遍历文件)
for file in *.txt; do
    echo "File: $file"
done

# For 循环(C 风格)
for ((i=0; i<5; i++)); do
    echo "Iteration $i"
done

# While 循环
i=0
while [ $i -lt 5 ]; do
    echo "Iteration $i"
    i=$((i + 1))
done

# Until 循环
i=0
until [ $i -ge 5 ]; do
    echo "Iteration $i"
    i=$((i + 1))
done

# Case 语句
case $NUMBER in
    42)
        echo "The answer!"
        ;;
    40)
        echo "Exactly 40"
        ;;
    *)
        echo "Something else"
        ;;
esac

# 函数定义
function greet() {
    local name="$1"
    echo "Hello, $name!"
}

# 函数调用
greet "World"

# 带返回值的函数
function add() {
    local a=$1
    local b=$2
    echo $((a + b))
}

result=$(add 3 4)
echo "Result: $result"

# 命令行参数
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"

# 读取用户输入
read -p "Enter your name: " USER_NAME
echo "Hello, $USER_NAME!"

# 设置脚本选项
set -e  # 遇到错误立即退出
set -u  # 使用未定义变量时报错
set -x  # 打印执行的命令(调试用)

# 错误处理
if ! command_that_may_fail; then
    echo "Command failed"
    exit 1
fi

# 信号处理
trap 'echo "Script interrupted"; exit 1' INT

# 脚本结束
echo "Script completed successfully"
exit 0
```

#### 5.2 高级 Shell 技巧

```bash
# 快速备份文件
cp file.txt{,.bak}

# 快速还原
cp file.txt{.bak,}

# 使用花括号展开创建多个文件
touch file{1..5}.txt

# 使用花括号展开创建目录结构
mkdir -p project/{src,docs,tests,bin}

# 字符串操作
str="Hello World"
echo ${str:0:5}      # 截取前 5 个字符: "Hello"
echo ${str:6}        # 从第 6 个字符开始截取: "World"
echo ${str#H*o}      # 删除最短匹配前缀: " World"
echo ${str##H*o}     # 删除最长匹配前缀: "rld"
echo ${str%o*d}      # 删除最短匹配后缀: "Hello W"
echo ${str%%o*d}     # 删除最长匹配后缀: "Hell"
echo ${str/World/Universe}  # 替换第一个匹配: "Hello Universe"
echo ${str//l/L}     # 替换所有匹配: "HeLLo WorLd"
echo ${#str}         # 字符串长度: 11

# 数组操作
array=(apple banana cherry)
echo ${array[0]}     # 第一个元素: "apple"
echo ${array[-1]}    # 最后一个元素: "cherry"
echo ${array[@]}     # 所有元素: "apple banana cherry"
echo ${#array[@]}    # 数组长度: 3
echo ${!array[@]}    # 所有索引: "0 1 2"

# 高级: 关联数组(Bash 4+)
declare -A assoc
assoc["name"]="John"
assoc["age"]=30
echo ${assoc["name"]}  # 访问值: "John"
echo ${!assoc[@]}       # 所有键: "name age"

# 进程替换
diff <(sort file1.txt) <(sort file2.txt)

# 命名管道
mkfifo mypipe
echo "Hello" > mypipe &
cat mypipe
rm mypipe

# 并行执行
task1 &
task2 &
wait
echo "Both tasks completed"

# 使用 xargs 并行执行
find . -name "*.txt" | xargs -P 4 -I {} process {}
```

### 六、磁盘与存储管理

```bash
# 显示磁盘分区
fdisk -l

# 交互式分区工具
fdisk /dev/sda

# 更友好的分区工具
cfdisk /dev/sda

# 创建文件系统
mkfs.ext4 /dev/sda1
mkfs.xfs /dev/sda2
mkfs.vfat /dev/sda3

# 挂载文件系统
mount /dev/sda1 /mnt

# 挂载并指定选项
mount -o noatime,ro /dev/sda1 /mnt

# 卸载文件系统
umount /mnt

# 显示已挂载的文件系统
mount

# 显示磁盘 UUID
blkid

# 配置开机自动挂载
cat >> /etc/fstab << 'EOF'
UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /mnt ext4 defaults 0 2
EOF

# 检查文件系统
fsck /dev/sda1

# 逻辑卷管理(LVM)
# 创建物理卷
pvcreate /dev/sda1

# 创建卷组
vgcreate myvg /dev/sda1

# 创建逻辑卷
lvcreate -L 10G -n mylv myvg

# 格式化逻辑卷
mkfs.ext4 /dev/myvg/mylv

# 挂载逻辑卷
mount /dev/myvg/mylv /mnt

# 扩展逻辑卷
lvextend -L +5G /dev/myvg/mylv
resize2fs /dev/myvg/mylv
```

### 七、系统监控与日志

```bash
# 实时监控系统资源
top

# 更强大的系统监控
# 需要安装: sudo apt install htop
htop

# 显示内存使用
free -h

# 显示磁盘使用
df -h

# 显示目录大小
du -sh /path/to/dir

# 显示系统平均负载
uptime

# 显示 CPU 信息
lscpu

# 显示 PCI 设备
lspci

# 显示 USB 设备
lsusb

# 显示硬件信息
# 需要安装: sudo apt install lshw
lshw

# 显示系统日志
journalctl

# 显示最近的 100 条日志
journalctl -n 100

# 实时监控日志
journalctl -f

# 显示特定服务的日志
journalctl -u nginx

# 显示今天的日志
journalctl --since today

# 显示特定时间段的日志
journalctl --since "2026-03-13 09:00:00" --until "2026-03-13 17:00:00"

# 显示内核日志
dmesg

# 实时监控内核日志
dmesg -w

# 传统日志文件
cat /var/log/syslog
cat /var/log/auth.log
cat /var/log/kern.log
```

---

## 跨平台脚本与工具

### 一、Python 跨平台脚本

```python
#!/usr/bin/env python3
"""跨平台系统信息收集脚本"""

import platform
import sys
import os
import subprocess
import json
from datetime import datetime

def get_system_info():
    info = {
        "timestamp": datetime.now().isoformat(),
        "system": {},
        "python": {},
        "environment": {}
    }
    
    # 系统信息
    info["system"] = {
        "os": platform.system(),
        "os_version": platform.version(),
        "architecture": platform.architecture(),
        "machine": platform.machine(),
        "processor": platform.processor(),
        "hostname": platform.node()
    }
    
    # Python 信息
    info["python"] = {
        "version": sys.version,
        "implementation": platform.python_implementation(),
        "compiler": platform.python_compiler(),
        "executable": sys.executable
    }
    
    # 环境变量
    info["environment"] = dict(os.environ)
    
    return info

def run_command(cmd, shell=True):
    """运行命令并返回输出"""
    try:
        result = subprocess.run(
            cmd,
            shell=shell,
            capture_output=True,
            text=True,
            timeout=30
        )
        return {
            "success": result.returncode == 0,
            "returncode": result.returncode,
            "stdout": result.stdout.strip(),
            "stderr": result.stderr.strip()
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }

def main():
    print("=" * 60)
    print("跨平台系统信息收集")
    print("=" * 60)
    
    info = get_system_info()
    
    print(f"\n操作系统: {info['system']['os']} {info['system']['os_version']}")
    print(f"主机名: {info['system']['hostname']}")
    print(f"架构: {info['system']['architecture'][0]}")
    print(f"处理器: {info['system']['processor']}")
    print(f"Python: {info['python']['version'].split()[0]}")
    
    # 保存到文件
    with open("system_info.json", "w", encoding="utf-8") as f:
        json.dump(info, f, indent=2, ensure_ascii=False)
    
    print(f"\n完整信息已保存到: system_info.json")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

### 二、Node.js 跨平台脚本

```javascript
#!/usr/bin/env node
/**
 * 跨平台文件操作工具
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

// 获取系统信息
console.log('系统信息:');
console.log(`  操作系统: ${os.type()} ${os.release()}`);
console.log(`  架构: ${os.arch()}`);
console.log(`  主机名: ${os.hostname()}`);
console.log(`  CPU 核心数: ${os.cpus().length}`);
console.log(`  内存: ${formatBytes(os.totalmem())}`);
console.log(`  空闲内存: ${formatBytes(os.freemem())}`);
console.log();

// 文件工具函数
function formatBytes(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

function walkDir(dir, callback) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
            walkDir(fullPath, callback);
        } else {
            callback(fullPath, stat);
        }
    }
}

// 示例: 查找大文件
console.log('查找当前目录中大于 1MB 的文件:');
try {
    const currentDir = process.cwd();
    const largeFiles = [];
    
    walkDir(currentDir, (filePath, stat) => {
        if (stat.size > 1024 * 1024) {  // > 1MB
            largeFiles.push({
                path: filePath,
                size: stat.size,
                sizeFormatted: formatBytes(stat.size)
            });
        }
    });
    
    // 按大小排序
    largeFiles.sort((a, b) => b.size - a.size);
    
    if (largeFiles.length > 0) {
        largeFiles.slice(0, 10).forEach((file, i) => {
            console.log(`  ${i + 1}. ${file.sizeFormatted} - ${path.relative(currentDir, file.path)}`);
        });
        if (largeFiles.length > 10) {
            console.log(`  ... 还有 ${largeFiles.length - 10} 个大文件`);
        }
    } else {
        console.log('  没有找到大于 1MB 的文件');
    }
} catch (error) {
    console.error('错误:', error.message);
}

console.log();
console.log('完成!');
```

### 三、跨平台工具推荐

| 工具 | 描述 | Windows | Linux | macOS |
| --- | --- | --- | --- | --- |
| Git | 版本控制 | ✅ | ✅ | ✅ |
| VS Code | 代码编辑器 | ✅ | ✅ | ✅ |
| Docker | 容器化 | ✅ | ✅ | ✅ |
| Node.js | JavaScript 运行时 | ✅ | ✅ | ✅ |
| Python | 编程语言 | ✅ | ✅ | ✅ |
| curl | HTTP 客户端 | ✅ | ✅ | ✅ |
| wget | 下载工具 | ✅ | ✅ | ✅ |
| jq | JSON 处理 | ✅ | ✅ | ✅ |
| fzf | 模糊查找 | ✅ | ✅ | ✅ |
| ripgrep | 快速搜索 | ✅ | ✅ | ✅ |
| fd | 快速文件查找 | ✅ | ✅ | ✅ |
| bat | 带语法高亮的 cat | ✅ | ✅ | ✅ |
| exa | 现代 ls 替代 | ✅ | ✅ | ✅ |
| starship | 漂亮的 Shell 提示符 | ✅ | ✅ | ✅ |

---

## 银河麒麟 (Kylin) 专用命令

银河麒麟是基于 Linux 的国产操作系统，支持服务器版和桌面版，以下是其专用管理命令与工具。

### 一、系统信息与版本管理

```bash
# 查看银河麒麟版本
cat /etc/kylin-release
cat /etc/.kyinfo

# 查看详细系统信息
nkvers

# 查看内核版本（银河麒麟定制内核）
uname -r
# 通常包含 kylin 标识，例如: 5.4.18-85-generic-kylin

# 查看安全中心状态
systemctl status kylin-security-center

# 查看安全审计状态
systemctl status auditd
```

### 二、银河麒麟软件包管理

银河麒麟同时支持 apt 和银河麒麟自研的包管理工具。

```bash
# 更新软件源
apt update

# 安装银河麒麟专用安全工具
apt install kylin-security-tool

# 安装银河麒麟系统管理工具
apt install kylin-system-manager

# 银河麒麟软件商店命令行工具(如已安装)
 kylin-software-center --help

# 查看已安装的银河麒麟专用包
dpkg -l | grep kylin

# 安装统信兼容包(如需在银河麒麟上运行 UOS 应用)
apt install uos-compat
```

### 三、安全中心与访问控制

银河麒麟提供了强安全中心，包含访问控制、防火墙、病毒防护等。

```bash
# 查看安全中心当前策略
kylin-security-cli status

# 开启/关闭安全中心
kylin-security-cli enable
kylin-security-cli disable

# 查看防火墙状态
systemctl status firewalld
# 或使用 ufw
ufw status

# 查看 SELinux/AppArmor 状态(银河麒麟通常使用 AppArmor)
aa-status

# 列出 AppArmor 配置文件
aa-enabled
aa-status

# 查看当前审计日志
ausearch -m avc -ts today

# 实时监控安全事件
tail -f /var/log/kylin-security.log
```

### 四、银河麒麟定制服务

```bash
# 银河麒麟更新服务
systemctl status kylin-update

# 手动检查更新
kylin-update-check

# 银河麒麟备份服务
systemctl status kylin-backup

# 创建系统备份
kylin-backup create --full

# 恢复系统备份
kylin-backup restore /path/to/backup

# 银河麒麟远程协助服务
systemctl status kylin-remote-assistance

# 银河麒麟用户认证服务
systemctl status kylin-auth
```

### 五、银河麒麟高级功能

```bash
# 查看系统安全评级
kylin-security-level

# 设置系统安全级别
kylin-security-level set 2
# 级别: 1=基础, 2=标准, 3=增强, 4=严格

# 检查系统完整性
kylin-integrity-check

# 银河麒麟系统诊断
kylin-diagnose

# 生成系统诊断报告
kylin-diagnose --report /path/to/report.html

# 配置银河麒麟审计规则
auditctl -w /etc/passwd -p wa -k passwd_changes

# 查看银河麒麟定制内核参数
sysctl -a | grep kylin
```

---

## 统信 UOS 专用命令

统信操作系统 (UnionTech OS, UOS) 是另一个主流国产操作系统，分为服务器版、桌面版和专业版。

### 一、系统信息与版本

```bash
# 查看统信 UOS 版本
cat /etc/uos-release
cat /etc/os-version

# 详细版本信息
uosvers

# 查看内核信息
uname -r
# 统信 UOS 内核通常包含 uos 标识，例如: 4.19.0-210.63.0.130.uos.x86_64

# 查看激活状态
uos-activation status

# 查看安全中心状态
systemctl status deepin-defender
```

### 二、统信 UOS 软件包管理

统信 UOS 使用深度包管理和 apt 双轨制。

```bash
# 更新软件源
apt update

# 使用深度商店命令行工具
deepin-store-cli --help

# 安装统信安全中心
apt install uos-security-center

# 安装统信系统工具
apt install uos-system-tools

# 查看已安装的统信专用包
dpkg -l | grep uos
dpkg -l | grep deepin

# 统信软件仓库配置
cat /etc/apt/sources.list.d/uos.list

# 安装内核更新
apt install linux-image-uos-amd64
```

### 三、统信 UOS 安全中心

```bash
# 查看安全中心状态
deepin-defender status

# 启动安全中心
deepin-defender start

# 病毒扫描
deepin-defender scan /path/to/scan

# 查看防火墙状态
uos-firewall status

# 开启防火墙
uos-firewall enable

# 开放端口
uos-firewall allow 80/tcp
uos-firewall allow 443/tcp

# 查看安全审计
cat /var/log/uos/security.log

# 查看应用白名单
uos-app-whitelist list

# 添加应用到白名单
uos-app-whitelist add /path/to/app

# 统信 UOS 安全级别查看
uos-security-level
```

### 四、统信 UOS 系统管理

```bash
# 统信 UOS 更新服务
systemctl status uos-update

# 检查更新
uos-update check

# 执行更新
uos-update upgrade

# 统信备份与恢复
systemctl status uos-backup

# 创建备份
uos-backup create --name "系统备份"

# 查看备份列表
uos-backup list

# 恢复备份
uos-backup restore <backup-id>

# 统信远程协助
systemctl status uos-remote-assist

# 统信用户认证
systemctl status uos-auth
```

### 五、统信 UOS 高级功能

```bash
# 系统完整性检查
uos-verify

# 统信诊断工具
uos-diagnose

# 生成系统报告
uos-diagnose --report /path/to/report.pdf

# 统信内核参数配置
sysctl -a | grep uos

# 查看统信定制的内核模块
lsmod | grep uos

# 统信应用容器
uos-app-container list

# 启动应用容器
uos-app-container run <app-name>

# 统信文件保护
uos-file-protection status

# 开启文件保护
uos-file-protection enable

# 保护目录
uos-file-protection add /path/to/protect
```

---

## 专业运维与安全加固

本章节包含生产环境常用的专业运维、性能调优、安全加固、日志审计等内容。

### 一、系统性能调优

#### 1.1 内核参数调优 (/etc/sysctl.conf)

```bash
# 编辑 sysctl 配置
vi /etc/sysctl.conf

# ========== 网络性能调优 ==========
# 开启 TCP 窗口缩放
net.ipv4.tcp_window_scaling = 1

# 开启 TCP 时间戳
net.ipv4.tcp_timestamps = 1

# 开启 TCP 选择确认
net.ipv4.tcp_sack = 1

# TCP 缓冲区大小
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# 最大连接数
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535

# TIME_WAIT 优化
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0  # 生产环境建议关闭，可能与 NAT 冲突
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_max_tw_buckets = 2000000

# ========== 文件描述符 ==========
fs.file-max = 2097152
fs.nr_open = 2097152

# ========== 虚拟内存 ==========
# 使用比例 (0-100)
vm.swappiness = 10

# 脏页比例
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5

# 缓存压力
vm.vfs_cache_pressure = 50

# ========== 内存 ==========
kernel.shmmax = 68719476736
kernel.shmall = 4294967296

# 加载新配置
sysctl -p

# 临时应用参数(不保存)
sysctl -w net.ipv4.ip_forward=1
```

#### 1.2 资源限制 (/etc/security/limits.conf)

```bash
# 编辑 limits.conf
vi /etc/security/limits.conf

# ========== 示例配置 ==========
# 所有用户 - 打开文件数
* soft nofile 655360
* hard nofile 655360

# 所有用户 - 进程数
* soft nproc 655360
* hard nproc 655360

# root 用户单独配置
root soft nofile 1048576
root hard nofile 1048576
root soft nproc 1048576
root hard nproc 1048576

# 特定应用用户
nginx soft nofile 1048576
nginx hard nofile 1048576
mysql soft nofile 1048576
mysql hard nofile 1048576

# 内存锁定
* soft memlock unlimited
* hard memlock unlimited

# 栈大小
* soft stack 10240
* hard stack 10240

# ========== PAM 配置(确保生效) ==========
# 检查 /etc/pam.d/login 是否包含:
# session required pam_limits.so
cat /etc/pam.d/login | grep pam_limits

# 检查 /etc/pam.d/sshd 是否包含:
# session required pam_limits.so
cat /etc/pam.d/sshd | grep pam_limits
```

#### 1.3 磁盘 I/O 调优

```bash
# 查看磁盘调度器
cat /sys/block/sda/queue/scheduler

# 临时修改调度器
echo deadline > /sys/block/sda/queue/scheduler
# 可选: noop, deadline, cfq, kyber, mq-deadline, bfq

# SSD 推荐: none/kyber/mq-deadline
# 机械盘推荐: deadline/bfq

# 永久修改(grub2)
vi /etc/default/grub
# 在 GRUB_CMDLINE_LINUX 中添加: elevator=deadline

# 重新生成 grub 配置
grub2-mkconfig -o /boot/grub2/grub.cfg

# 调整预读
blockdev --getra /dev/sda
blockdev --setra 8192 /dev/sda

# 调整队列深度
echo 4096 > /sys/block/sda/queue/nr_requests

# 查看 I/O 统计
iostat -x 1

# 查看进程 I/O
iotop

# 使用 ionice 设置 I/O 优先级
ionice -c 2 -n 0 -p <pid>      # 实时
ionice -c 2 -n 7 -p <pid>      # 低优先级
ionice -c 3 -p <pid>            # 空闲时
```

### 二、系统安全加固

#### 2.1 SSH 安全加固 (/etc/ssh/sshd_config)

```bash
# 备份配置
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 编辑配置
vi /etc/ssh/sshd_config

# ========== 基础安全 ==========
# 修改 SSH 端口
Port 22222

# 禁止 root 直接登录
PermitRootLogin no

# 禁止空密码
PermitEmptyPasswords no

# 禁用密码认证(改用密钥)
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# 禁用不安全的认证方式
HostbasedAuthentication no
ChallengeResponseAuthentication no
GSSAPIAuthentication no

# ========== 超时与重试 ==========
# 客户端存活间隔
ClientAliveInterval 300
ClientAliveCountMax 2

# 登录超时
LoginGraceTime 60

# 最大认证尝试次数
MaxAuthTries 3

# 最大会话数
MaxSessions 10

# ========== 协议与算法 ==========
# 只使用 SSH v2
Protocol 2

# 安全的 Key 交换算法
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256

# 安全的主机密钥算法
HostKeyAlgorithms ecdsa-sha2-nistp521-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp521,ecdsa-sha2-nistp384,ecdsa-sha2-nistp256,ssh-ed25519-cert-v01@openssh.com,ssh-ed25519

# 安全的加密算法
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

# 安全的 MAC 算法
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com

# ========== 访问控制 ==========
# 允许的用户/组
AllowUsers admin@192.168.1.0/24 user1 user2
AllowGroups ssh-users

# 禁止的用户/组
DenyUsers root test
DenyGroups guests

# ========== 其他安全 ==========
# 禁止 .rhosts
IgnoreRhosts yes
IgnoreUserKnownHosts no

# 记录 SFTP 操作
Subsystem sftp internal-sftp -l INFO -f AUTH

# 禁用用户环境
PermitUserEnvironment no

# 禁用转发(按需开启)
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no

# 验证配置语法
sshd -t

# 重启 SSH 服务
systemctl restart sshd
systemctl status sshd
```

#### 2.2 防火墙配置 (firewalld)

```bash
# 启动 firewalld
systemctl enable firewalld
systemctl start firewalld
systemctl status firewalld

# 查看默认区域
firewall-cmd --get-default-zone

# 查看活动区域
firewall-cmd --get-active-zones

# 查看区域配置
firewall-cmd --list-all
firewall-cmd --list-all --zone=public

# ========== 基础服务 ==========
# 开放 SSH
firewall-cmd --permanent --add-service=ssh

# 开放 HTTP/HTTPS
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https

# ========== 端口管理 ==========
# 开放自定义端口
firewall-cmd --permanent --add-port=22222/tcp
firewall-cmd --permanent --add-port=53/udp

# 范围端口
firewall-cmd --permanent --add-port=10000-20000/tcp

# 移除端口
firewall-cmd --permanent --remove-port=8080/tcp

# ========== 富规则(高级) ==========
# 只允许特定 IP 访问 SSH
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.100/32" service name="ssh" accept'

# 限制连接速率
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="http" accept limit value="10/m"'

# 端口转发
firewall-cmd --permanent --add-masquerade
firewall-cmd --permanent --add-forward-port=port=8080:proto=tcp:toport=80:toaddr=192.168.1.10

# 封禁 IP
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.0.0.100" reject'

# 查看富规则
firewall-cmd --list-rich-rules

# ========== 应用与验证 ==========
# 重新加载配置
firewall-cmd --reload

# 查看运行时配置
firewall-cmd --list-all

# 应急: 紧急模式(阻断所有流量)
firewall-cmd --panic-on
firewall-cmd --panic-off
```

#### 2.3 防火墙配置 (ufw - 简单)

```bash
# 启用 ufw
ufw enable

# 默认策略
ufw default deny incoming
ufw default allow outgoing

# 允许 SSH
ufw allow ssh
ufw allow 22222/tcp

# 限制 SSH 连接频率
ufw limit ssh/tcp

# 允许 HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# 从特定 IP 允许
ufw allow from 192.168.1.100
ufw allow from 192.168.1.0/24 to any port 22

# 拒绝特定 IP
ufw deny from 10.0.0.100

# 查看状态
ufw status
ufw status verbose

# 删除规则
ufw delete allow 8080/tcp

# 禁用 ufw
ufw disable
```

#### 2.4 系统审计 (auditd)

```bash
# 安装 auditd
apt install auditd
yum install audit

# 启动服务
systemctl enable auditd
systemctl start auditd
systemctl status auditd

# ========== 基础审计规则 ==========
# 编辑规则文件
vi /etc/audit/rules.d/audit.rules

# 监控文件访问
-w /etc/passwd -p wa -k passwd_changes
-w /etc/group -p wa -k group_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/sudoers -p wa -k sudoers_changes

# 监控目录
-w /etc/ -p wa -k etc_changes
-w /root/ -p wa -k root_changes
-w /var/log/ -p wa -k log_changes

# 监控命令执行
-a exit,always -F path=/usr/bin/sudo -F perm=x -k sudo_exec
-a exit,always -F path=/usr/bin/su -F perm=x -k su_exec
-a exit,always -F path=/usr/bin/ssh -F perm=x -k ssh_exec

# 监控系统调用
-a exit,always -F arch=b64 -S mount -S umount -S reboot -k sys_mgmt
-a exit,always -F arch=b64 -S sethostname -S setdomainname -k network_changes

# 监控账户修改
-w /usr/sbin/useradd -p x -k useradd
-w /usr/sbin/userdel -p x -k userdel
-w /usr/sbin/usermod -p x -k usermod
-w /usr/sbin/groupadd -p x -k groupadd
-w /usr/sbin/groupdel -p x -k groupdel
-w /usr/sbin/groupmod -p x -k groupmod

# 不审计的事件
-a never,user -F subj_type=crond_t
-a never,exit -F subj_type=crond_t

# ========== 搜索审计日志 ==========
# 搜索所有 passwd 修改
ausearch -k passwd_changes

# 搜索今天的事件
ausearch -ts today

# 搜索特定时间范围
ausearch -ts "03/13/2026 09:00:00" -te "03/13/2026 17:00:00"

# 搜索特定用户
ausearch -ua root

# 搜索特定命令
ausearch -x sudo

# 搜索文件访问
ausearch -f /etc/passwd

# ========== 生成审计报告 ==========
# 总体报告
aureport

# 认证报告
aureport -au

# 可执行文件报告
aureport -x

# 系统调用报告
aureport -s

# 文件修改报告
aureport -f

# 实时监控
auditctl -s
tail -f /var/log/audit/audit.log
```

#### 2.5 文件完整性检查 (AIDE)

```bash
# 安装 AIDE
apt install aide
yum install aide

# 初始化数据库
aideinit
# 或
aide --init

# 移动新数据库到正式位置
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# 配置 AIDE
vi /etc/aide/aide.conf

# ========== 配置示例 ==========
# 定义规则组
ALL = p+i+n+u+g+s+m+c+acl+selinux+xattrs+sha256

# 监控系统目录
/bin ALL
/sbin ALL
/usr/bin ALL
/usr/sbin ALL
/etc ALL
/root ALL

# 排除不需要监控的目录
!/etc/mtab
!/etc/mnttab
!/etc/adjtime
!/etc/ld.so.cache
!/etc/lvm/cache
!/var/log
!/var/spool
!/var/tmp
!/tmp

# ========== 日常检查 ==========
# 执行检查
aide --check

# 检查并更新数据库
aide --update
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# 定时检查(cron)
cat > /etc/cron.daily/aide-check << 'EOF'
#!/bin/bash
/usr/bin/aide --check | mail -s "AIDE Check Report" admin@example.com
EOF
chmod +x /etc/cron.daily/aide-check
```

#### 2.6 系统基线检查与加固脚本示例

```bash
#!/bin/bash
# 系统安全基线检查与加固脚本

set -e

echo "========================================="
echo "系统安全基线检查"
echo "========================================="

# 1. 检查系统版本
echo "[1/10] 检查系统版本..."
cat /etc/os-release

# 2. 检查系统更新
echo -e "\n[2/10] 检查系统更新..."
apt update && apt list --upgradable 2>/dev/null || yum check-update 2>/dev/null || true

# 3. 检查 SELinux/AppArmor
echo -e "\n[3/10] 检查强制访问控制..."
if command -v sestatus &> /dev/null; then
    sestatus
elif command -v aa-status &> /dev/null; then
    aa-status
else
    echo "未检测到 SELinux 或 AppArmor"
fi

# 4. 检查防火墙
echo -e "\n[4/10] 检查防火墙..."
if systemctl is-active firewalld &> /dev/null; then
    echo "firewalld 状态: 运行中"
    firewall-cmd --list-all --zone=public
elif systemctl is-active ufw &> /dev/null; then
    echo "ufw 状态: 运行中"
    ufw status
else
    echo "警告: 未检测到活动的防火墙"
fi

# 5. 检查 SSH 配置
echo -e "\n[5/10] 检查 SSH 配置..."
sshd -T 2>/dev/null | grep -E "permitrootlogin|passwordauthentication|port"

# 6. 检查密码策略
echo -e "\n[6/10] 检查密码策略..."
cat /etc/login.defs | grep -E "PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE"
cat /etc/pam.d/common-password 2>/dev/null || cat /etc/pam.d/system-auth 2>/dev/null || true

# 7. 检查审计服务
echo -e "\n[7/10] 检查审计服务..."
if systemctl is-active auditd &> /dev/null; then
    echo "auditd: 运行中"
    auditctl -s
else
    echo "警告: auditd 未运行"
fi

# 8. 检查特殊权限文件
echo -e "\n[8/10] 检查 SUID/SGID 文件..."
find / -perm -4000 -type f 2>/dev/null | head -20
echo "..."

# 9. 检查监听端口
echo -e "\n[9/10] 检查监听端口..."
ss -tuln | grep LISTEN

# 10. 检查用户
echo -e "\n[10/10] 检查用户..."
echo "UID 为 0 的用户:"
awk -F: '$3 == 0' /etc/passwd
echo -e "\n可登录的用户:"
awk -F: '$7 ~ /bash|sh/' /etc/passwd

echo -e "\n========================================="
echo "检查完成"
echo "========================================="
```

### 三、企业级日志管理

#### 3.1 rsyslog 高级配置

```bash
# 主配置文件
vi /etc/rsyslog.conf

# 自定义配置目录
vi /etc/rsyslog.d/50-custom.conf

# ========== 配置模板 ==========
# 高精度时间戳模板
$template HighPrecisionFormat,"%timestamp:::date-rfc3339% %HOSTNAME% %syslogtag%%msg:::sp-if-no-1st-sp%%msg:::drop-last-lf%\n"

# JSON 格式模板
$template JsonFormat,"{\"timestamp\":\"%timestamp:::date-rfc3339%\",\"host\":\"%HOSTNAME%\",\"tag\":\"%syslogtag%\",\"msg\":\"%msg:::json%\"}\n"

# 文件路径模板
$template PerHostLog,"/var/log/remote/%HOSTNAME%/%PROGRAMNAME%.log"

# ========== 远程日志接收 ==========
# 启用 UDP 接收
module(load="imudp")
input(type="imudp" port="514")

# 启用 TCP 接收
module(load="imtcp")
input(type="imtcp" port="514")

# TLS 加密传输
module(load="imtcp" StreamDriver.Name="gtls" StreamDriver.Mode="1" StreamDriver.AuthMode="x509/name" PermittedPeer="*.example.com")
global(DefaultNetstreamDriver="gtls" DefaultNetstreamDriverCAFile="/etc/pki/rsyslog/ca.pem" DefaultNetstreamDriverCertFile="/etc/pki/rsyslog/server-cert.pem" DefaultNetstreamDriverKeyFile="/etc/pki/rsyslog/server-key.pem")

# ========== 日志过滤与路由 ==========
# 按 severity 过滤
*.err;kern.*;authpriv,auth.none /var/log/critical.log

# 按程序名过滤
if $programname == 'sshd' then /var/log/sshd.log
& stop

if $programname == 'nginx' then /var/log/nginx/error.log
& stop

# 远程转发
*.* @@logserver.example.com:514    # TCP
*.* @logserver.example.com:514     # UDP

# 按来源转发
if $fromhost-ip == '192.168.1.100' then @@logserver.example.com:514
& stop

# 同时写入本地和远程
*.* /var/log/all.log
*.* @@logserver.example.com:514

# ========== 日志轮转 (logrotate) ==========
vi /etc/logrotate.d/custom

/var/log/custom/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root adm
    sharedscripts
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}

# 测试轮转
logrotate -d /etc/logrotate.d/custom

# ========== 重启服务 ==========
systemctl restart rsyslog
systemctl status rsyslog
```

#### 3.2 journald 高级配置

```bash
# 配置文件
vi /etc/systemd/journald.conf

# ========== 配置示例 ==========
[Journal]
# 存储方式: auto, volatile, persistent, none
Storage=persistent

# 压缩
Compress=yes

# 前向密封
Seal=yes

# 最大使用空间
SystemMaxUse=10G
SystemKeepFree=5G
SystemMaxFileSize=100M

# 运行时最大使用空间
RuntimeMaxUse=2G
RuntimeKeepFree=1G
RuntimeMaxFileSize=50M

# 保留时间
MaxRetentionSec=1month
MaxFileSec=1day

# 转发到其他日志服务
ForwardToSyslog=yes
ForwardToKMsg=no
ForwardToConsole=no
ForwardToWall=no

# ========== 应用配置 ==========
systemctl restart systemd-journald
systemctl status systemd-journald

# ========== journalctl 高级用法 ==========
# 查看指定服务的日志
journalctl -u nginx -u mysql

# 查看指定单元类型
journalctl -t systemd -u ssh.service

# 查看指定优先级
journalctl -p err..alert

# 按时间查询
journalctl --since today
journalctl --since "2026-03-13 09:00:00" --until "2026-03-13 17:00:00"
journalctl --since "-2h"

# 实时监控
journalctl -f
journalctl -u nginx -f

# 显示输出为 JSON
journalctl -u nginx -o json
journalctl -u nginx -o json-pretty

# 显示详细信息
journalctl -u nginx -o verbose

# 查看磁盘占用
journalctl --disk-usage

# 清理旧日志
journalctl --vacuum-time=1month
journalctl --vacuum-size=5G

# 查看引导日志
journalctl -b
journalctl -b -1  # 上一次引导
```

### 四、高可用与集群基础

#### 4.1 Keepalived 配置

```bash
# 安装 Keepalived
apt install keepalived
yum install keepalived

# 主配置文件
vi /etc/keepalived/keepalived.conf

# ========== 主节点配置 ==========
global_defs {
    router_id LVS_MASTER
    enable_script_security
    script_user root
}

# 健康检查脚本
vrrp_script check_nginx {
    script "/etc/keepalived/check_nginx.sh"
    interval 2
    weight -20
    fall 3
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.1.200/24 dev eth0 label eth0:0
    }
    track_script {
        check_nginx
    }
    notify_master "/etc/keepalived/notify.sh master"
    notify_backup "/etc/keepalived/notify.sh backup"
    notify_fault "/etc/keepalived/notify.sh fault"
}

# ========== 备用节点配置 ==========
global_defs {
    router_id LVS_BACKUP
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.1.200/24 dev eth0 label eth0:0
    }
    track_script {
        check_nginx
    }
}

# ========== 健康检查脚本 ==========
cat > /etc/keepalived/check_nginx.sh << 'EOF'
#!/bin/bash
if ! curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1/health | grep -q "200"; then
    exit 1
fi
exit 0
EOF
chmod +x /etc/keepalived/check_nginx.sh

# ========== 通知脚本 ==========
cat > /etc/keepalived/notify.sh << 'EOF'
#!/bin/bash
TYPE=$1
NAME=$2
STATE=$3
DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "$DATE - $TYPE - $NAME - $STATE" >> /var/log/keepalived-notify.log
EOF
chmod +x /etc/keepalived/notify.sh

# ========== 启动服务 ==========
systemctl enable keepalived
systemctl start keepalived
systemctl status keepalived

# 查看 VIP
ip addr show eth0

# 查看日志
journalctl -u keepalived -f
```

### 五、容器与 Kubernetes 基础

#### 5.1 Docker 常用命令 (生产级)

```bash
# 镜像管理
docker images
docker pull nginx:alpine
docker build -t myapp:v1 .
docker tag myapp:v1 registry.example.com/myapp:v1
docker push registry.example.com/myapp:v1
docker rmi nginx:alpine
docker image prune -a

# 容器管理
docker run -d --name nginx -p 80:80 --restart=always --memory=512m --cpus=0.5 nginx:alpine
docker ps
docker ps -a
docker logs nginx
docker logs -f --tail=100 nginx
docker inspect nginx
docker exec -it nginx sh
docker cp file.txt nginx:/path/
docker cp nginx:/path/file.txt .
docker stop nginx
docker start nginx
docker restart nginx
docker rm -f nginx
docker container prune

# 资源限制与健康检查
docker run -d \
    --name myapp \
    --memory=1g \
    --memory-reservation=800m \
    --cpus=1 \
    --ulimit nofile=65536:65536 \
    --health-cmd="curl -f http://localhost/health || exit 1" \
    --health-interval=10s \
    --health-timeout=5s \
    --health-retries=3 \
    myapp:v1

# 网络管理
docker network create --driver bridge mynet
docker network ls
docker network inspect mynet
docker network connect mynet nginx
docker network disconnect mynet nginx

# 存储管理
docker volume create myvol
docker volume ls
docker volume inspect myvol
docker run -v myvol:/data nginx
docker volume prune

# Docker Compose (生产配置示例)
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    image: nginx:alpine
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.25'
          memory: 128M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 40s
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
EOF

docker-compose up -d
docker-compose ps
docker-compose logs -f
docker-compose down
```

#### 5.2 Kubernetes 常用命令 (生产级)

```bash
# 集群信息
kubectl version --short
kubectl cluster-info
kubectl get nodes -o wide
kubectl top nodes
kubectl top pods

# 命名空间
kubectl get namespaces
kubectl create namespace production
kubectl config set-context --current --namespace=production

# Pod 管理
kubectl get pods -o wide
kubectl get pods --show-labels
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs -f --tail=100 <pod-name>
kubectl logs -f <pod-name> -c <container-name>
kubectl exec -it <pod-name> -- sh
kubectl port-forward <pod-name> 8080:80
kubectl cp file.txt <pod-name>:/path/
kubectl delete pod <pod-name>

# Deployment 管理
cat > deployment.yml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: production
  labels:
    app: nginx
    env: production
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
        ports:
        - containerPort: 80
          name: http
        livenessProbe:
          httpGet:
            path: /
            port: http
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /
            port: http
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 101
      volumes:
      - name: config
        configMap:
          name: nginx-config
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - nginx
              topologyKey: kubernetes.io/hostname
      tolerations:
      - key: "node-role.kubernetes.io/worker"
        operator: "Exists"
        effect: "NoSchedule"
EOF

kubectl apply -f deployment.yml
kubectl get deployments
kubectl rollout status deployment/nginx
kubectl rollout history deployment/nginx
kubectl set image deployment/nginx nginx=nginx:1.26-alpine
kubectl rollout undo deployment/nginx
kubectl scale deployment/nginx --replicas=5
kubectl autoscale deployment/nginx --min=3 --max=10 --cpu-percent=80

# Service 管理
kubectl get services
kubectl expose deployment nginx --port=80 --target-port=80 --type=ClusterIP
kubectl expose deployment nginx --port=80 --target-port=80 --type=NodePort
kubectl expose deployment nginx --port=80 --target-port=80 --type=LoadBalancer

# ConfigMap & Secret
kubectl create configmap nginx-config --from-file=nginx.conf
kubectl create secret generic db-secret --from-literal=username=admin --from-literal=password=secret
kubectl get configmaps
kubectl get secrets

# 事件与调试
kubectl get events --sort-by='.lastTimestamp'
kubectl api-resources
kubectl explain deployment.spec
kubectl debug -it <pod-name> --image=busybox --share-processes
kubectl cordon <node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
kubectl uncordon <node-name>
```

---

## 附录

### A. 常用快捷键

#### Bash/Shell 快捷键

- `Ctrl + A`: 移到行首
- `Ctrl + E`: 移到行尾
- `Ctrl + U`: 删除到行首
- `Ctrl + K`: 删除到行尾
- `Ctrl + W`: 删除前一个单词
- `Ctrl + L`: 清屏
- `Ctrl + R`: 搜索历史命令
- `Ctrl + C`: 终止当前命令
- `Ctrl + Z`: 暂停当前命令
- `Tab`: 自动补全

#### PowerShell 快捷键

- `Ctrl + A`: 全选
- `Ctrl + C`: 复制/终止
- `Ctrl + V`: 粘贴
- `Ctrl + Home`: 移到缓冲区顶部
- `Ctrl + End`: 移到缓冲区底部
- `F8`: 搜索历史命令
- `Tab`: 自动补全

### B. 参考资源

- PowerShell 文档: <https://learn.microsoft.com/powershell/>
- Linux 文档: <https://www.kernel.org/doc/html/latest/>
- Bash 手册: <https://www.gnu.org/software/bash/manual/>
- Linux 命令大全: <https://man7.org/linux/man-pages/>

---

## 手册结束
