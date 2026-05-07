# 信创环境架构与兼容性检查

国产化环境中，同一个命令或软件包可能因为 CPU 架构、系统版本、厂商补丁而表现不同。排查问题前，先收集基础信息。

## 基础信息采集

```bash
cat /etc/os-release
uname -a
uname -m
lscpu
```

## 包管理与软件源

```bash
# APT 系
apt policy 2>/dev/null
apt list --installed 2>/dev/null | head

# RPM 系
yum repolist 2>/dev/null
rpm -qa | head
```

## 常见架构

| 架构 | 常见场景 | 注意事项 |
| --- | --- | --- |
| `x86_64` | 通用服务器和桌面 | 软件兼容性最好 |
| `aarch64` | ARM 服务器、终端 | 注意软件包架构和镜像架构 |
| `loongarch64` | 龙芯环境 | 需要确认软件生态和专用源 |
| `mips64el` | 部分国产平台 | 通用二进制兼容性有限 |

## 容器镜像检查

```bash
# 查看本机架构
uname -m

# 查看镜像信息
docker image inspect <image>
```

建议:

- ARM 环境优先使用多架构镜像。
- 不确定镜像架构时，先在测试环境启动。
- CI 构建时明确目标架构。

## 排查清单

- 系统版本是否与文档一致。
- CPU 架构是否与软件包一致。
- 软件源是否匹配系统版本。
- 内核版本是否满足驱动或软件要求。
- 安全中心、防火墙、访问控制是否限制服务。
