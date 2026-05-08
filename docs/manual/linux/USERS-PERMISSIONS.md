# Linux 用户、组与权限

这个专题从主手册迁移 Linux 用户管理、组管理和权限管理内容。

## 用户管理

```bash
whoami
id
su - username
sudo command
sudo su -
sudo -i

# 创建用户
useradd -m username
useradd -m -s /bin/bash username

# 设置密码
passwd username

# 删除用户
userdel username
userdel -r username

# 修改用户信息
usermod -c "Full Name" username
usermod -s /bin/zsh username

# 查看用户
cat /etc/passwd
who
last
```

## 组管理

```bash
groupadd groupname
groupdel groupname
usermod -aG groupname username
gpasswd -d username groupname
groups username
cat /etc/group
getent group groupname
```

## 权限查看

```bash
ls -l file.txt
```

权限含义:

```text
- rw- r-- r--
|  |   |   |
|  |   |   其他用户权限
|  |   组用户权限
|  所有者权限
文件类型: -=文件, d=目录, l=链接
```

权限值:

- `r = 4`
- `w = 2`
- `x = 1`

## chmod

```bash
# 符号模式
chmod u+x file.txt
chmod g-w file.txt
chmod o=r file.txt
chmod a+x file.txt

# 数字模式
chmod 755 file.txt
chmod 644 file.txt
chmod 600 file.txt
```

## chown/chgrp

```bash
chown user file.txt
chown user:group file.txt
chown -R user:group dir/
chgrp group file.txt
```

## 特殊权限

```bash
# SUID
chmod 4755 file.txt

# SGID
chmod 2755 file.txt

# Sticky Bit
chmod 1777 dir/
```

高危提醒: `chmod -R`、`chown -R` 会递归修改目录，执行前必须确认路径边界。

## 相关案例

- [Linux Permission denied 排查](../../cases/LINUX-PERMISSION-DENIED.md)
- [SSH 连接失败排查](../../cases/SSH-CONNECTION-FAILED.md)
- [systemd 服务启动失败排查](../../cases/SYSTEMD-SERVICE-FAILED.md)
