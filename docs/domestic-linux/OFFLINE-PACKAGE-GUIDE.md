# 国产 Linux 离线安装与软件源维护

信创和内网环境经常无法直接访问公网软件源。银河麒麟、统信 UOS 等系统在离线安装时，建议优先建立内部软件源，而不是长期手工拷贝单个安装包。

## 先确认系统信息

```bash
cat /etc/os-release
uname -m
dpkg --print-architecture 2>/dev/null || rpm --eval '%{_arch}' 2>/dev/null
```

需要记录:

- 发行版和版本号
- CPU 架构: `x86_64`、`aarch64`、`loongarch64` 等
- 包管理器: `apt`、`yum`、`dnf`
- 是否有厂商专用源或内网源

## Debian/Ubuntu/UOS 兼容环境

### 下载软件包及依赖

联网机器:

```bash
mkdir -p packages
cd packages
apt download <package>
```

如果需要递归下载依赖，建议使用受控工具或在干净环境中模拟安装，避免漏包。

### 离线安装

目标机器:

```bash
sudo dpkg -i *.deb
sudo apt -f install
```

如果完全离线，`apt -f install` 仍可能失败，需要把缺失依赖一起准备好。

## RPM/YUM/DNF 兼容环境

### 下载软件包及依赖

联网机器:

```bash
mkdir -p packages
yum install --downloadonly --downloaddir=packages <package>
```

或:

```bash
dnf download --resolve --destdir packages <package>
```

### 离线安装

目标机器:

```bash
sudo rpm -Uvh *.rpm
```

如果依赖复杂，建议建立本地 yum 仓库。

## 本地软件源建议

适合团队或多台服务器:

- 统一维护内网仓库。
- 按系统版本和架构分目录。
- 保留软件包来源和更新时间。
- 上线前在测试机验证依赖完整性。

## 常见问题

| 问题 | 排查 |
| --- | --- |
| 架构不匹配 | `uname -m`、包名中的架构后缀 |
| 依赖缺失 | 查看 `dpkg -i` 或 `rpm -Uvh` 报错 |
| 软件源不可用 | 检查 `/etc/apt/sources.list` 或 `/etc/yum.repos.d/` |
| 证书或签名失败 | 检查仓库 GPG key 和系统时间 |

## 安全建议

- 不从不可信来源下载系统包。
- 内网仓库要有访问控制和变更记录。
- 生产系统安装前先在同版本测试环境验证。
