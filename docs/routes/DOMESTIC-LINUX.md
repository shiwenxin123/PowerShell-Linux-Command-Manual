# 国产 Linux 路线

这条路线适合银河麒麟、统信 UOS、ARM、鲲鹏、龙芯等信创环境的命令查找、离线安装和差异排查。

## 学习顺序

| 阶段 | 目标 | 推荐文档 |
| --- | --- | --- |
| 1. 识别系统与版本 | 确认发行版、架构、内核和包管理器 | [Kylin/UOS 常用命令](../domestic-linux/KYLIN-UOS-COMMANDS.md) |
| 2. 处理软件源 | 掌握离线源、内网源和包依赖排查 | [离线安装与软件源](../domestic-linux/OFFLINE-PACKAGE-GUIDE.md) |
| 3. 判断架构兼容性 | 区分 x86_64、aarch64、loongarch64 等差异 | [架构与兼容性检查](../domestic-linux/ARCHITECTURE-CHECKLIST.md) |
| 4. 处理版本差异 | 避免把厂商命令写成绝对通用命令 | [版本差异与排查要点](../domestic-linux/VERSION-DIFFERENCES.md) |
| 5. 回到通用专题 | 网络、磁盘、日志、安全等仍优先用 Linux 专题 | [专题手册入口](../manual/README.md) |

## 常用确认命令

```bash
cat /etc/os-release
uname -a
arch
hostnamectl
lsblk
ip addr
```

包管理器确认:

```bash
command -v apt
command -v yum
command -v dnf
command -v rpm
dpkg --print-architecture 2>/dev/null
rpm --eval '%{_arch}' 2>/dev/null
```

## 常见场景

| 场景 | 推荐入口 |
| --- | --- |
| 离线环境装包 | [离线安装与软件源](../domestic-linux/OFFLINE-PACKAGE-GUIDE.md) |
| ARM/龙芯/鲲鹏兼容 | [架构与兼容性检查](../domestic-linux/ARCHITECTURE-CHECKLIST.md) |
| 厂商版本命令差异 | [版本差异与排查要点](../domestic-linux/VERSION-DIFFERENCES.md) |
| SSH/网络问题 | [Linux 网络排查](../manual/linux/NETWORK.md)、[SSH 连接失败](../cases/SSH-CONNECTION-FAILED.md) |
| 权限问题 | [Linux 用户组与权限](../manual/linux/USERS-PERMISSIONS.md)、[Permission denied 排查](../cases/LINUX-PERMISSION-DENIED.md) |

## 风险提醒

- 国产 Linux 不同版本和授权组件差异较大，执行厂商工具命令前先确认版本。
- 离线源变更前备份原有 repo/source 配置。
- ARM、龙芯、鲲鹏环境不要直接套用 x86 软件包。

## 下一步

- [Linux 包管理](../manual/linux/PACKAGE-MANAGEMENT.md)
- [Linux 性能调优](../manual/linux/PERFORMANCE-TUNING.md)
- [真实故障案例库](../cases/README.md)
