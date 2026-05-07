# Linux 包管理

Linux 包管理要先判断发行版和包格式，再选择 `apt/dpkg` 或 `yum/dnf/rpm`。国产 Linux 环境还要额外确认系统版本、CPU 架构和软件源。

## 判断系统和架构

```bash
cat /etc/os-release
uname -m

# Debian/Ubuntu/UOS 兼容环境
dpkg --print-architecture 2>/dev/null

# RPM/YUM 兼容环境
rpm --eval '%{_arch}' 2>/dev/null
```

## APT 常用命令

```bash
# 更新软件源索引
sudo apt update

# 安装软件
sudo apt install <package>

# 升级软件
sudo apt upgrade

# 搜索软件
apt search <keyword>

# 查看软件包信息
apt show <package>

# 删除软件
sudo apt remove <package>

# 删除软件和配置
sudo apt purge <package>
```

## DPKG 常用命令

```bash
# 查看已安装包
dpkg -l | grep <package>

# 安装本地 deb 包
sudo dpkg -i package.deb

# 查看文件属于哪个包
dpkg -S /path/to/file

# 查看包安装了哪些文件
dpkg -L <package>
```

## YUM/DNF 常用命令

```bash
# 查看仓库
yum repolist
dnf repolist

# 安装软件
sudo yum install <package>
sudo dnf install <package>

# 搜索软件
yum search <keyword>
dnf search <keyword>

# 查看软件包信息
yum info <package>
dnf info <package>

# 删除软件
sudo yum remove <package>
sudo dnf remove <package>
```

## RPM 常用命令

```bash
# 查看已安装包
rpm -qa | grep <package>

# 安装 rpm 包
sudo rpm -ivh package.rpm

# 升级 rpm 包
sudo rpm -Uvh package.rpm

# 查看文件属于哪个包
rpm -qf /path/to/file

# 查看包安装了哪些文件
rpm -ql <package>
```

## 软件源排查

```bash
# APT 源
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d/

# YUM/DNF 源
ls /etc/yum.repos.d/
yum repolist -v
```

常见问题:

- 软件源不可达。
- 系统版本和软件源版本不匹配。
- CPU 架构不匹配。
- GPG key 或证书异常。
- 内网环境 DNS 或代理配置错误。

## 离线安装建议

- 同一系统版本、同一架构准备软件包。
- 复杂依赖优先建立内网软件源。
- 不建议长期手工拷贝单个包。

延伸阅读: [国产 Linux 离线安装与软件源维护](../../domestic-linux/OFFLINE-PACKAGE-GUIDE.md)。
