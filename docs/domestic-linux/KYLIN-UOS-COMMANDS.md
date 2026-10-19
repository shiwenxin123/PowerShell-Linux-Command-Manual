# 银河麒麟与统信 UOS 常用命令

银河麒麟和统信 UOS 常见于政企办公、国产化替代和信创环境。实际命令会因版本、CPU 架构和软件源策略不同而变化，执行前建议先确认系统版本。

不同发行版/商业版本可能差异较大。桌面版、服务器版和 SP 小版本的包管理器、安全中心服务名、更新工具都可能不同。下文厂商命令只在对应组件已安装时可用。先按 [版本差异与排查要点](VERSION-DIFFERENCES.md) 识别现场，再用 `command -v` 或 `systemctl list-unit-files` 确认命令和服务存在。命令不存在，只说明当前镜像没有这个组件。

## 系统版本识别

```bash
# 通用方式
cat /etc/os-release

# 内核和架构
uname -a
uname -m

# systemd 版本
systemctl --version
```

### 银河麒麟

```bash
# 查看银河麒麟版本
cat /etc/kylin-release
cat /etc/.kyinfo

# 查看详细系统信息
nkvers

# 查看定制内核
uname -r

# 查看安全中心和审计服务
systemctl status kylin-security-center
systemctl status auditd
```

### 统信 UOS

```bash
# 查看统信 UOS 版本
cat /etc/uos-release
cat /etc/os-version

# 查看详细版本信息
uosvers

# 查看内核和激活状态
uname -r
uos-activation status

# 查看安全中心状态
systemctl status deepin-defender
```

## 软件包管理

### Debian/Ubuntu 系兼容场景

```bash
# 更新软件源
sudo apt update

# 安装软件
sudo apt install <package>

# 查询软件
apt search <keyword>

# 查看已安装包
dpkg -l | grep <package>
```

### RPM/YUM/DNF 兼容场景

```bash
# 查询仓库
yum repolist

# 安装软件
sudo yum install <package>

# 查询软件包
rpm -qa | grep <package>

# 查看文件属于哪个包
rpm -qf /path/to/file
```

### 银河麒麟专用场景

```bash
# 安装银河麒麟安全和系统管理工具
sudo apt install kylin-security-tool
sudo apt install kylin-system-manager

# 查看软件商店命令行工具
kylin-software-center --help

# 查看已安装的麒麟相关包
dpkg -l | grep kylin

# 如需兼容 UOS 应用，先确认厂商支持策略
apt search uos-compat
```

### 统信 UOS 专用场景

```bash
# 查看深度商店命令行工具
deepin-store-cli --help

# 安装统信安全中心和系统工具
sudo apt install uos-security-center
sudo apt install uos-system-tools

# 查看已安装的统信和 deepin 相关包
dpkg -l | grep uos
dpkg -l | grep deepin

# 查看统信软件源
cat /etc/apt/sources.list.d/uos.list

# 搜索内核更新包
apt search linux-image-uos
```

## 服务管理

```bash
# 查看服务
systemctl status <service>

# 启动服务
sudo systemctl start <service>

# 设置开机启动
sudo systemctl enable <service>

# 查看失败服务
systemctl --failed
```

### 厂商服务

```bash
# 银河麒麟更新、备份和远程协助
systemctl status kylin-update
systemctl status kylin-backup
systemctl status kylin-remote-assistance
systemctl status kylin-auth

# 统信 UOS 更新、备份和远程协助
systemctl status uos-update
systemctl status uos-backup
systemctl status uos-remote-assist
systemctl status uos-auth
```

## 安全中心与访问控制

### 银河麒麟

```bash
# 查看安全中心策略
kylin-security-cli status

# 启用或禁用安全中心，生产环境先确认影响范围
kylin-security-cli enable
kylin-security-cli disable

# AppArmor 和审计
aa-status
aa-enabled
ausearch -m avc -ts today

# 安全日志
tail -f /var/log/kylin-security.log
```

### 统信 UOS

```bash
# 安全中心
deepin-defender status
deepin-defender start

# 病毒扫描
deepin-defender scan /path/to/scan

# 防火墙
uos-firewall status
uos-firewall enable
uos-firewall allow 80/tcp
uos-firewall allow 443/tcp

# 审计与白名单
cat /var/log/uos/security.log
uos-app-whitelist list
uos-app-whitelist add /path/to/app
uos-security-level
```

## 网络排查

```bash
# 查看 IP
ip addr

# 查看路由
ip route

# 查看监听端口
ss -tulnp

# 测试连通
ping <host>
```

## 桌面与图形环境

```bash
# 查看当前桌面会话
echo $XDG_CURRENT_DESKTOP

# 查看显示服务
loginctl show-session "$XDG_SESSION_ID" -p Type
```

## 备份、诊断与高级功能

### 银河麒麟

```bash
# 检查更新
kylin-update-check

# 备份与恢复
kylin-backup create --full
kylin-backup restore /path/to/backup

# 安全级别和完整性
kylin-security-level
kylin-security-level set 2
kylin-integrity-check

# 诊断报告
kylin-diagnose
kylin-diagnose --report /path/to/report.html

# 查看定制参数
sysctl -a | grep kylin
```

### 统信 UOS

```bash
# 更新
uos-update check
uos-update upgrade

# 备份与恢复
uos-backup create --name "system-backup"
uos-backup list
uos-backup restore <backup-id>

# 完整性和诊断
uos-verify
uos-diagnose
uos-diagnose --report /path/to/report.pdf

# 定制内核和应用容器
sysctl -a | grep uos
lsmod | grep uos
uos-app-container list
uos-app-container run <app-name>

# 文件保护
uos-file-protection status
uos-file-protection enable
uos-file-protection add /path/to/protect
```

## 版本边界

常用命令页不能代替版本核对。现场至少先分清下面几类差异，再回来执行具体命令。

| 差异 | 先做什么 | 详细说明 |
| --- | --- | --- |
| 版本识别 | 读 `os-release`，再按存在与否查看 `kylin-release`、`os-version`、`nkvers`、`uosvers` | [版本识别](VERSION-DIFFERENCES.md#先识别再选命令) |
| 包管理 | `command -v apt dnf yum`，只使用本机存在的那一组查询命令 | [包管理命令差异](VERSION-DIFFERENCES.md#包管理命令差异) |
| 安全中心 | 列出本机防火墙、SELinux/AppArmor 和厂商服务，不默认存在某个 CLI | [安全中心与访问控制差异](VERSION-DIFFERENCES.md#安全中心与访问控制差异) |
| 系统管理 | 用 `systemctl` 查实际单元名，更新和备份先看状态 | [系统管理命令差异](VERSION-DIFFERENCES.md#系统管理命令差异) |

启用、关闭安全中心，以及备份恢复、升级、修改安全级别，都会改变系统行为。排查时停在 `status`、`policy`、`repolist` 这类只读输出。

## 信创环境建议

- 记录系统版本、CPU 架构、软件源地址和补丁策略。
- 不同厂商镜像的包名可能不一致，先搜索再安装。
- 内网环境建议维护离线软件包仓库。
- 修改安全中心、防火墙、访问控制策略前先保存当前配置。
- 厂商命令随版本和授权组件变化较大，找不到命令时先用 `dpkg -l`、`rpm -qa` 或软件商店确认组件是否安装。
- 更新、备份、恢复和安全级别调整都应先在测试机验证。

## 延伸阅读

- [国产 Linux 离线安装与软件源维护](OFFLINE-PACKAGE-GUIDE.md)
- [信创环境架构与兼容性检查](ARCHITECTURE-CHECKLIST.md)
- [国产 Linux 版本差异与排查要点](VERSION-DIFFERENCES.md)
