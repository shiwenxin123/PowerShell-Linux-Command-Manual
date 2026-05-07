# 国产 Linux 版本差异与排查要点

国产 Linux 环境常见差异来自发行版版本、CPU 架构、软件源、桌面/服务器形态和厂商安全组件。排查前先收集环境信息。

## 基础信息采集

```bash
cat /etc/os-release
uname -a
uname -m
lscpu
systemctl --version
```

## 银河麒麟常见关注点

```bash
# 系统版本
cat /etc/os-release

# 包管理器判断
command -v apt
command -v yum
command -v dnf

# 服务管理
systemctl status <service>
```

关注点:

- 不同镜像可能使用不同包管理体系。
- 服务器版和桌面版预装组件不同。
- ARM、龙芯等架构的软件包可用性不同。
- 安全中心或访问控制策略可能影响服务访问。

## 统信 UOS 常见关注点

```bash
# 系统版本
cat /etc/os-release

# APT 源
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d/

# 已安装包
dpkg -l | head
```

关注点:

- 桌面版和服务器版包集合不同。
- 内网环境常使用定制软件源。
- 图形界面组件和服务端组件排查方式不同。
- 某些安全策略可能通过图形安全中心配置。

## 架构差异

| 架构 | 排查重点 |
| --- | --- |
| `x86_64` | 通用软件兼容性较好 |
| `aarch64` | 注意 ARM 包、容器镜像架构 |
| `loongarch64` | 注意专用软件源和二进制兼容 |
| `mips64el` | 注意可用包范围和厂商适配 |

## 软件源差异

排查命令:

```bash
# APT
apt policy
sudo apt update

# YUM/DNF
yum repolist -v
dnf repolist -v
```

常见问题:

- 软件源版本与系统版本不匹配。
- 源地址内网不可达。
- GPG key 或证书异常。
- 架构目录缺失。

## 安全组件差异

排查顺序:

1. Linux 文件权限。
2. 防火墙。
3. SELinux/AppArmor。
4. 厂商安全中心或访问控制策略。
5. 等保/基线加固脚本带来的限制。

## 建议记录模板

```text
系统名称:
系统版本:
CPU 架构:
包管理器:
软件源地址:
安全组件:
部署环境: 物理机/虚拟机/云主机/容器
问题现象:
```

延伸阅读:

- [银河麒麟与统信 UOS 常用命令](KYLIN-UOS-COMMANDS.md)
- [国产 Linux 离线安装与软件源维护](OFFLINE-PACKAGE-GUIDE.md)
- [信创环境架构与兼容性检查](ARCHITECTURE-CHECKLIST.md)
