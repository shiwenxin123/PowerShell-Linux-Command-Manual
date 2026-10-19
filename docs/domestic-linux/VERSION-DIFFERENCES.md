# 国产 Linux 版本差异与排查要点

国产 Linux 环境的差异来自发行版、商业版本、SP 小版本、CPU 架构、桌面/服务器形态和厂商安全组件。银河麒麟与统信 UOS 不能共用一套命令。不同发行版/商业版本可能差异较大，下文命令都要先识别现场再执行，不要写成绝对通用。

## 先识别，再选命令

先收集只读信息。某一条命令不存在，只说明当前镜像没有这个文件或组件，不要据此判断系统损坏。

```bash
cat /etc/os-release
uname -a
uname -m
command -v systemctl && systemctl --version
```

版本文件和厂商命令按“文件或命令存在才执行”处理:

```bash
# 银河麒麟常见，桌面和服务器镜像不一定都有
[ -r /etc/kylin-release ] && cat /etc/kylin-release
[ -r /etc/.kyinfo ] && cat /etc/.kyinfo
command -v nkvers && nkvers

# 中标麒麟等旧镜像可能仍使用这个文件
[ -r /etc/neokylin-release ] && cat /etc/neokylin-release

# 统信 UOS 常见。os-version 字段名以现场文件为准
[ -r /etc/uos-release ] && cat /etc/uos-release
[ -r /etc/os-version ] && cat /etc/os-version
command -v uosvers && uosvers
```

`/etc/.kyinfo` 在部分镜像上权限较紧或内容不是纯文本。读不到时改看 `/etc/os-release` 和 `nkvers`。

包管理器同时探测，不要看到发行版名字就假设只有 apt 或只有 dnf:

```bash
command -v apt
command -v apt-cache
command -v dpkg
command -v dnf
command -v yum
command -v rpm
```

## 常见发行形态

下表是现场常见对应关系，用来缩小排查范围。商业镜像、SP 和架构组合可能打破这张表，以本机探测结果为准。

| 常见形态 | 版本识别上常见什么 | 包管理常见情况 | 安全组件常见情况 | 不要默认假设 |
| --- | --- | --- | --- | --- |
| 银河麒麟桌面 V10 / V10 SP1 | `ID=kylin`，`/etc/kylin-release`，部分镜像有 `nkvers` | apt / dpkg | 图形安全中心；AppArmor 比 SELinux 更常见 | 不要默认有 `firewall-cmd` 或 `kylin-security-cli` |
| 银河麒麟高级服务器 V10 的 RPM 系镜像 | `kylin-release` 或 `os-release` 中带服务器版本；部分构建标注 openEuler 兼容 | dnf 或 yum，rpm | firewalld、SELinux 或厂商加固脚本更常见 | 不要把桌面版 apt 命令套到这台机器 |
| 中标麒麟 / 旧服务器镜像，常见 V7 | `/etc/neokylin-release` 可能仍在 | yum / rpm，接近 EL7 | firewalld、SELinux 更常见 | 不要使用只存在于 V10 桌面的麒麟命令 |
| 统信 UOS 桌面版 20 | `/etc/os-version`、`/etc/uos-release`，部分镜像有 `uosvers` | apt / dpkg | 安全中心常见为 deepin-defender 图形组件 | 不要默认有 `uos-firewall` 子命令 |
| 统信 UOS 服务器版 20 的 Debian 系镜像 | `os-version` 中常见服务器或对应 Edition 字段 | apt / dpkg | 可能没有图形安全中心；防火墙可能是 ufw、firewalld 或未启用 | 不要因为桌面命令不存在就重装系统 |
| 标注 openEuler 兼容的统信或麒麟商业服务器镜像 | `os-release` 同时出现厂商 ID 和 openEuler 兼容信息 | dnf / rpm | SELinux、firewalld 更常见 | 不要执行 `apt update` |

同一产品名下的 “V10” 或 “V20” 只表示产品代际。SP、授权组件和 CPU 架构仍会改变包名、服务名和命令是否存在。

## 版本识别怎么读

### 银河麒麟

```bash
# os-release 里优先看 ID、VERSION_ID、PRETTY_NAME
. /etc/os-release
printf '%s\n' "$ID" "$VERSION_ID" "$PRETTY_NAME"

# 有 nkvers 时，它通常比 os-release 多内核和授权相关信息
command -v nkvers && nkvers
```

关注点:

- 桌面版 `PRETTY_NAME` 常带桌面或 V10 字样，并可能有 UKUI 会话。
- 服务器版通常没有图形会话。用 `echo "$XDG_CURRENT_DESKTOP"` 为空，不能说明命令缺失。
- `nkvers` 不在 `PATH` 中时，先 `command -v nkvers`，不要把 “command not found” 写成版本损坏。

### 统信 UOS

```bash
# 桌面和服务器都优先读这两个文件
cat /etc/os-version
cat /etc/os-release
```

`/etc/os-version` 里常见 `MajorVersion`、`MinorVersion`、`OsBuild`、`EditionName`、`ProductType` 一类字段，小版本之间字段名可能增减。记录原始文件，不要只抄一个 “V20”。

```bash
# 有对应命令才查看授权。退出码非 0 可能是没装组件，不等于授权失效
command -v uosvers && uosvers
command -v uos-activator
command -v uos-activator-cmd
command -v uos-license-ctl
```

激活和授权工具名随桌面版、服务器版和补丁变化。上面几个名字只是现场常见候选，以 `command -v` 结果为准。

## 包管理命令差异

先看上一节的探测结果，再选下面其中一组。生产排查使用查询命令。`apt update` / `dnf makecache` 会访问软件源，一般不升级已安装包，但内网源不通时会报错。`upgrade`、`dist-upgrade`、`dnf update` 会真正变更软件包，不要当作排查命令。

### Debian 系

常见于麒麟桌面 V10、UOS 桌面 20，以及不少 UOS 服务器 20 镜像。

```bash
# 已安装包和架构
dpkg --print-architecture
dpkg -l | awk 'NR<=5 || /kylin|uos|deepin/'

# 软件源优先级。先看输出，不必先 apt update
apt-cache policy

# 源文件位置。文件名因镜像而异，不要写死成某一个 list
ls /etc/apt/sources.list /etc/apt/sources.list.d/
```

搜索包:

```bash
apt-cache search <keyword>
apt-cache policy <package>
```

### RPM 系

常见于麒麟高级服务器的部分 V10 镜像、中标麒麟 V7，以及标注 openEuler 兼容的商业镜像。

```bash
# EL8 / 麒麟或 openEuler 兼容的新镜像通常有 dnf
command -v dnf && dnf --version
dnf repolist

# 中标麒麟 V7 一类旧镜像可能只有 yum
command -v yum && yum --version
yum repolist

rpm --eval '%{_arch}'
rpm -qa | grep -E 'kylin|uos|kernel' | head
ls /etc/yum.repos.d/
```

`dnf` 和 `yum` 不要混用在同一条排查结论里。巡检脚本在同时存在多个包管理器时有固定优先级，见 [巡检脚本工具化](../manual/automation/HEALTH-CHECK-SCRIPTS.md)。

### 选错命令时的现象

| 现场 | 错误做法 | 常见结果 |
| --- | --- | --- |
| 只有 dnf/yum | `sudo apt update` | `apt: command not found`，不是软件源故障 |
| 只有 apt | `dnf repolist` | `dnf: command not found`，不是仓库损坏 |
| 内网源地址与系统版本不一致 | 直接 `apt upgrade` 或 `dnf update` | 可能装上不匹配依赖。先停在 `policy` / `repolist` |
| ARM、龙芯镜像 | 使用 x86_64 离线包 | 依赖或架构不匹配。先核对 `dpkg --print-architecture` 或 `rpm --eval '%{_arch}'` |

离线源目录和同步方式见 [离线安装与软件源维护](OFFLINE-PACKAGE-GUIDE.md)。

## 安全中心与访问控制差异

厂商安全中心、firewalld、ufw、SELinux、AppArmor 可能只存在其中一部分。排查顺序仍然是: 文件权限、防火墙、SELinux/AppArmor、厂商安全中心、等保或基线脚本。

先发现本机实际有什么:

```bash
systemctl list-unit-files --type=service --no-pager | grep -Ei 'kylin|uos|deepin|firewall|apparmor'
command -v firewall-cmd && firewall-cmd --state
command -v ufw && ufw status
command -v getenforce && getenforce
command -v aa-status && aa-status
```

| 组件 | 更常见的环境 | 查看方式 | 限制 |
| --- | --- | --- | --- |
| 麒麟图形安全中心 | 银河麒麟桌面 | `systemctl list-unit-files` 中名称含 `kylin` 的服务；桌面菜单 | 服务名随 SP 变化。服务器镜像经常根本没有这个服务 |
| `kylin-security-cli` | 安装了对应命令行组件的麒麟镜像 | `command -v kylin-security-cli` | 不是 V10 通用命令。不存在时不要执行 enable/disable |
| firewalld | 多数 RPM 系服务器 | `firewall-cmd --state`、`firewall-cmd --list-all` | 桌面 Debian 系镜像上经常没有 |
| ufw | 部分 Debian 系桌面或服务器 | `ufw status` | 状态是 inactive 只说明 ufw 没启用，不说明没有其他防火墙 |
| SELinux | RPM 系服务器更常见 | `getenforce`、`ausearch -m avc -ts recent` | Debian 系桌面经常没有 `getenforce` |
| AppArmor | Debian 系桌面更常见 | `aa-status` | RPM 系服务器经常没有 `aa-status` |
| deepin-defender | 统信桌面 / deepin 血统镜像 | `command -v deepin-defender`，或图形安全中心 | UOS 服务器经常未安装 |
| `uos-firewall` | 安装了统信防火墙封装的镜像 | `command -v uos-firewall` | 不能替代 `firewall-cmd` / `ufw` 的判断 |

`kylin-security-cli enable`、`kylin-security-cli disable`、`uos-firewall enable` 会改访问控制。只有在 `command -v` 确认命令存在、并且变更窗口允许时才使用。排查阶段停在 `status`。

审计日志路径也不统一。先确认文件存在再看尾部:

```bash
ls -l /var/log/kylin-security.log /var/log/uos/security.log /var/log/audit/audit.log 2>/dev/null
```

## 系统管理命令差异

这些版本的常规服务管理多数是 systemd，但单元名不是通用的。

```bash
systemctl --version
systemctl --failed --no-pager
systemctl list-units --type=service --state=running --no-pager | grep -Ei 'kylin|uos|deepin' || true
```

| 事项 | 桌面版常见入口 | 服务器版常见入口 | 注意 |
| --- | --- | --- | --- |
| 查看版本 | `nkvers`、`uosvers`、图形关于 | `/etc/os-release`、release 文件 | 服务器没有图形关于页面 |
| 安装软件 | apt，或厂商软件商店 | apt 或 dnf/yum | 商店命令只存在于安装了商店的镜像 |
| 系统更新 | 厂商更新器或 `apt` | `apt` 或 `dnf`，有时还有厂商更新服务 | 先查服务是否安装，再决定能不能用厂商更新器 |
| 防火墙 | 图形安全中心，或 ufw | firewalld、ufw，或基线脚本 | 可能同时存在“服务没装”和“规则在上层安全设备” |
| 授权 | 桌面激活工具 | 服务器授权命令或合同约定的工具 | 命令名不固定，先 `command -v` |
| 时间与主机名 | `timedatectl`、`hostnamectl` | 同样可用，前提是 systemd | 容器里这些命令可能被裁剪 |

更新相关命令先探测，不要直接升级:

```bash
command -v kylin-update
command -v uos-update
systemctl list-unit-files --type=service --no-pager | grep -Ei 'update|upgrade|backup' || true
```

看到更新或备份服务后，只查看状态:

```bash
systemctl status <unit> --no-pager
```

备份恢复、安全级别调整和完整性修复会改系统。放到变更窗口，并先在同版本测试机验证。命令示例仍以 [麒麟与 UOS 常用命令](KYLIN-UOS-COMMANDS.md) 里“命令存在才执行”为准。

## 架构差异

| 架构 | 排查重点 |
| --- | --- |
| `x86_64` | 通用软件包相对多，仍要核对商业源里的版本 |
| `aarch64` | 核对 ARM 包和容器镜像架构，不要装 x86_64 包 |
| `loongarch64` | 使用厂商针对龙芯的软件源，二进制通常不能混用 |
| `mips64el` | 可用包范围更依赖厂商适配 |

架构检查细节见 [架构与兼容性检查](ARCHITECTURE-CHECKLIST.md)。

## 软件源差异

确认包管理器之后再看源。

```bash
# APT。policy 失败时再考虑 apt update，它会访问网络
apt-cache policy

# DNF / YUM
dnf repolist -v
yum repolist -v
```

常见问题:

- 软件源版本与系统 SP 不匹配。
- 源地址在内网不可达，或证书与源域名不一致。
- GPG key 未导入。先看报错，不要关掉签名检查。
- 架构目录在源里不存在，例如源只有 `x86_64` 而机器是 `aarch64`。

## 建议记录模板

```text
系统名称:
产品形态: 桌面 / 服务器
系统版本和 SP:
CPU 架构:
包管理器: apt / dnf / yum
软件源地址:
防火墙: firewalld / ufw / 未安装 / 未确认
MAC 或安全模块: SELinux / AppArmor / 未安装
厂商安全中心: 已安装组件名 / 未安装
部署环境: 物理机 / 虚拟机 / 云主机 / 容器
问题现象:
```

## 延伸阅读

- [银河麒麟与统信 UOS 常用命令](KYLIN-UOS-COMMANDS.md)
- [国产 Linux 离线安装与软件源维护](OFFLINE-PACKAGE-GUIDE.md)
- [信创环境架构与兼容性检查](ARCHITECTURE-CHECKLIST.md)
