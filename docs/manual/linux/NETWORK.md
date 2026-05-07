# Linux 网络排查

网络问题建议按顺序排查: 本机 IP、路由、DNS、端口监听、防火墙、远端连通性。

## 本机网络

```bash
# 查看 IP
ip addr
ip addr show
ip a

# 查看接口统计
ip -s link

# 查看路由
ip route
ip route show
ip r

# 查看 DNS
cat /etc/resolv.conf

# 启用/禁用接口
ip link set eth0 up
ip link set eth0 down
```

## 连通性测试

```bash
# 测试 IP 连通
ping 8.8.8.8

# 测试域名解析和连通
ping example.com

# 测试端口
nc -vz example.com 443

# HTTP 请求
curl -I https://example.com

# 路由跟踪
traceroute example.com

# 连通性和丢包分析
mtr example.com

# DNS 查询
nslookup example.com
dig example.com
dig example.com MX
```

## 端口与连接

```bash
# 查看监听端口
ss -tulnp
ss -tuln

# 查看 TCP 连接
ss -tan
ss -tupa
ss -tupn

# 查看指定端口
ss -tulnp | grep ':8080'

# 传统工具
netstat -tuln
```

## 文件传输

```bash
# 复制文件到远程服务器
scp local_file.txt user@remote:/path/to/dest/

# 从远程服务器复制文件
scp user@remote:/path/to/remote_file.txt /local/dest/

# 复制目录
scp -r local_dir user@remote:/path/to/dest/

# 交互式传输
sftp user@remote

# rsync 同步文件
rsync -avz local_file.txt user@remote:/path/to/dest/

# rsync 同步目录
rsync -avz local_dir/ user@remote:/path/to/dest/

# 显示进度
rsync -avz --progress local_dir/ user@remote:/path/to/dest/

# 删除目标中源位置没有的文件
rsync -avz --delete local_dir/ user@remote:/path/to/dest/
```

## SSH 远程登录

```bash
# 基本登录
ssh user@remote_host

# 使用非标准端口
ssh -p 2222 user@remote_host

# 使用私钥
ssh -i /path/to/private_key user@remote_host

# 生成密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 复制公钥
ssh-copy-id user@remote_host

# 本地端口转发
ssh -L 8080:localhost:80 user@remote_host

# 远程端口转发
ssh -R 9000:localhost:3000 user@remote_host

# 动态转发
ssh -D 1080 user@remote_host
```

`~/.ssh/config` 示例:

```text
Host myserver
    HostName 192.168.1.100
    User username
    Port 2222
    IdentityFile ~/.ssh/myserver_key
```

## 防火墙

```bash
# firewalld 状态
firewall-cmd --state
firewall-cmd --list-all

# ufw 状态
ufw status
```

## 延伸案例

- [端口被占用排查](../../cases/PORT-IN-USE.md)
- [SSH 连接失败排查](../../cases/SSH-CONNECTION-FAILED.md)
- [常见报错排查](../../troubleshooting/COMMON-ERRORS.md)
