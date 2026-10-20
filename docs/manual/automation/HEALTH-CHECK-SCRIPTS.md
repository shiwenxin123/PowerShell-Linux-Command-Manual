# 巡检脚本工具化

Linux 和 Windows 巡检脚本支持文本、Markdown 和 JSON 输出。JSON 输出使用统一结构，便于 CI、自动化平台或巡检系统消费。

## 支持格式

| 格式 | 用途 |
| --- | --- |
| `text` | 默认终端输出 |
| `markdown` | 生成可粘贴到工单或文档的报告 |
| `json` | 自动化消费和后续结构化处理 |

## 支持模块

| 模块 | 说明 |
| --- | --- |
| `all` | 默认，执行全部检查 |
| `system` | 系统版本、运行时间、内存等 |
| `disk` | 磁盘空间、inode 或驱动器信息 |
| `network` | 监听端口和网络路由 |
| `service` | 异常服务或未运行服务 |
| `process` | CPU 和内存占用较高的进程 |
| `package` | 包管理器、软件源、已安装包或仓库状态 |
| `security` | SSH、防火墙、SELinux/AppArmor、麒麟/UOS 安全中心、Defender 等基础安全状态 |
| `container` | Docker、containerd、Kubernetes 客户端或节点基础状态 |
| `log` | 系统错误日志、journal 占用、Windows 事件日志摘要 |

## Linux 示例

```bash
# 默认文本输出
bash scripts/linux-health-check.sh

# 只检查磁盘
bash scripts/linux-health-check.sh --module disk

# 只检查包管理器和软件源
bash scripts/linux-health-check.sh --module package

# 只检查系统日志
bash scripts/linux-health-check.sh --module log

# Markdown 报告
bash scripts/linux-health-check.sh --format markdown --output reports/linux-health-check.md

# JSON 报告
bash scripts/linux-health-check.sh --format json --output reports/linux-health-check.json
```

## Windows 示例

```powershell
# 默认文本输出
.\scripts\windows-health-check.ps1

# 只检查网络
.\scripts\windows-health-check.ps1 -Module network

# 只检查安全状态
.\scripts\windows-health-check.ps1 -Module security

# 只检查容器工具
.\scripts\windows-health-check.ps1 -Module container

# Markdown 报告
.\scripts\windows-health-check.ps1 -Format markdown -OutputFile reports\windows-health-check.md

# JSON 报告
.\scripts\windows-health-check.ps1 -Format json -OutputFile reports\windows-health-check.json
```

## JSON 结构

完整字段契约见 [Health Check Report JSON Schema](../../schema/health-check-report.schema.json)。

```json
{
  "metadata": {
    "os": "Linux",
    "hostname": "example-host",
    "timestamp": "2026-05-07T08:00:00Z",
    "module": "all",
    "format": "json",
    "script": "linux-health-check.sh"
  },
  "modules": {
    "system": {
      "status": "ok",
      "commands": [],
      "warnings": [],
      "errors": []
    },
    "package": {
      "status": "ok",
      "commands": [],
      "warnings": [],
      "errors": []
    }
  },
  "summary": {
    "status": "ok",
    "warnings_count": 0,
    "errors_count": 0
  },
  "errors": []
}
```

## 退出码

| 退出码 | 含义 |
| --- | --- |
| `0` | 巡检正常完成且无告警 |
| `1` | 巡检完成但存在告警或部分模块异常 |
| `2` | 参数错误 |
| `3` | 脚本内部异常或关键输出写入失败 |

## 示例报告

通用示例覆盖全部模块，字段名与脚本一致:

- [Linux JSON 示例](../../examples/linux-health-check.sample.json)
- [Windows JSON 示例](../../examples/windows-health-check.sample.json)
- [JSON Schema](../../schema/health-check-report.schema.json)

`package`、`security`、`container`、`log` 在不同系统上的输出不一样。下面的样例是脱敏后的完整报告，主机名和地址使用 `example-*` 与文档测试网段，不是生产环境。

| 平台 | 样例 | 这几份报告里值得看的差异 |
| --- | --- | --- |
| Ubuntu 22.04 | [Ubuntu 样例](../../examples/health-check-ubuntu.sample.json) | `package` 走 `apt_policy`；`security` 走 `ufw` 和 `apparmor`；装了 Docker，没有 kubectl |
| Rocky Linux 9 | [Rocky 样例](../../examples/health-check-rocky.sample.json) | `package` 走 `dnf_repolist`；`security` 走 `firewall-cmd` 和 `selinux`；只有 containerd |
| CentOS 7 | [CentOS 7 样例](../../examples/health-check-centos7.sample.json) | 没有 dnf 时 `package` 的仓库命令名是 `yum_repolist` |
| 银河麒麟桌面 V10 SP1 | [麒麟样例](../../examples/health-check-kylin.sample.json) | Debian 系命令；本机没有 firewalld/ufw 时出现 `firewall-cmd` 告警 |
| 统信 UOS 服务器 20 | [UOS 样例](../../examples/health-check-uos.sample.json) | 同样可能是 `apt_policy`；`ufw status` 为 inactive 时脚本仍记为成功 |
| Windows Server 2022 | [Windows Server 样例](../../examples/windows-health-check.sample.json) | `package` 看 `Get-Package` 和 `Get-PSRepository`；没有 winget 时告警 |

样例是说明输出形状，不是“每台同类系统都会得到同样告警”。SP、架构和预装组件不同，命令有无就会变。

校验 JSON 能被解析:

```bash
python -m json.tool docs/examples/health-check-ubuntu.sample.json >/dev/null
```

```powershell
Get-Content docs/examples/health-check-windows-server.sample.json -Raw | ConvertFrom-Json
```

## 新增模块在各平台上怎么读

脚本只执行本机存在的命令。`warnings` 里的 `Command not available` 表示命令不在 `PATH` 中，不表示防火墙关闭或主机不合规。

### package

Linux 先列出本机存在的包管理器，再按下面顺序只选一个仓库查询:

1. 有 `apt-cache` 时执行 `apt-cache policy`，命令名为 `apt_policy`。
2. 否则有 `dnf` 时执行 `dnf repolist`，命令名为 `dnf_repolist`。
3. 否则有 `yum` 时执行 `yum repolist`，命令名为 `yum_repolist`。
4. 否则有 `zypper` 时执行 `zypper repos`。
5. 都没有时，模块告警 `package-manager`。

因此同一台同时装有 `dnf` 和 `yum` 的 Rocky/CentOS 8+，仓库结果只会有 `dnf_repolist`。CentOS 7 通常没有 `dnf`，才会出现 `yum_repolist`。银河麒麟桌面 V10 和多数统信 UOS 20 会走 `apt_policy`。麒麟高级服务器里的 RPM 系镜像会走 `dnf_repolist` 或 `yum_repolist`，不要拿桌面样例否定服务器结果。

Windows 的 `package` 模块执行:

- `installed_packages`: `Get-Package` 的前 30 条。
- `powershell_repositories`: `Get-PSRepository`。
- 有 `winget` 时增加 `winget_version`；没有则告警 `winget`。Windows Server 默认经常没有 winget，这是样例里的预期告警。

### security

Linux 按存在与否收集，不是每项都有:

| 检查 | 命令名 | 选择规则 |
| --- | --- | --- |
| SSH 守护配置 | `sshd_config` | 只读 `/etc/ssh/sshd_config` 里未注释的 `PermitRootLogin`、`PasswordAuthentication`、`PubkeyAuthentication`、`Port`。文件不可读则告警 |
| sudo | `sudo_version` | 本机有 `sudo` 才执行 `sudo -V` |
| 防火墙 | `firewall_state` | 优先 `firewall-cmd --state`，否则 `ufw status`。两个都不存在时告警 `firewall-cmd` |
| SELinux 或 AppArmor | `selinux` 或 `apparmor` | 优先 `getenforce`，否则 `aa-status`。两个都没有时不额外告警 |
| 麒麟 / UOS 安全中心 | `domestic_security_center` | 只读探测常见安全中心包、systemd 单元、已知路径。命令存在时只执行 `status`。工具不存在时写入 `not-found` / `not-installed` / `absent`，不因此告警 |

Ubuntu 样例因此是 ufw + AppArmor。Rocky 和 CentOS 7 样例是 firewalld + SELinux。麒麟桌面样例没有这两种防火墙命令，所以 `security.status` 为 `warning`，同时仍可能有 `apparmor`。UOS 样例里 `ufw status` 输出 `inactive`，命令成功，模块状态仍是 `ok`。

`domestic_security_center` 每次都会出现在文本和 JSON 里。它查询 `ksc-defender`、`kylin-security-center`、`kylin-security-tool`、`uos-security-center`、`deepin-defender` 是否安装，查看 `ksc-defender.service`、`ksc-defender-daemon.service`、`kylin-security-center.service`、`deepin-defender.service` 的 `LoadState` / `ActiveState` / `UnitFileState`，并只检查这些路径在不在: `/etc/kylin-security-center.conf`、`/var/log/kylin-security.log`、`/var/log/uos/security.log`。路径只看是否存在，不读取内容。

命令存在时只执行 `kylin-security-cli status`、`uos-firewall status`、`deepin-defender status`，并且最多等 5 秒。`kylin-security-level`、`uos-security-level`、`kysec_set`、`kysec_stat` 只报告是否在 `PATH` 中，不执行。`enable`、`disable`、`set`、`allow`、`start` 不会被调用。某个已存在命令的 `status` 返回非 0 时，这条命令记为告警；工具本身不存在不是告警。通用 Ubuntu 或 CentOS 上通常整段都是 `not-found` / `not-installed` / `absent`，脚本继续完成。

样例 JSON 仍符合 schema。它们生成于这次探测加入之前，所以里面还没有 `domestic_security_center`。以实机 `--format json` 的输出为准。

Windows 的 `security` 模块执行 `Get-NetFirewallProfile`。有 `Get-MpComputerStatus` 时记录 Defender 状态，没有则告警。Server Core 或精简镜像上 Defender cmdlet 缺失是告警，不是脚本失败。

### container

Linux:

- 有 `docker` 时记录 `docker_version` 和 `docker_ps`，否则告警 `docker`。
- 有 `ctr` 时额外记录 `containerd_version`。没有 `ctr` 不单独告警。
- 有 `kubectl` 时记录 `kubectl_nodes`，否则告警 `kubectl`。

没有安装 Docker 的桌面麒麟、只有 containerd 的 Rocky 节点，都会出现 docker 告警。这不代表容器运行时损坏。`kubectl get nodes` 需要当前 kubeconfig 有权限；命令不存在和权限失败不是同一种结果，后者会体现在命令 `exit_code`。

Windows 只检查 `docker` 和 `kubectl version --client=true`。没有 Linux 上的 `ctr` 检查。

### log

Linux 有 `journalctl` 时记录:

- `journal_errors`: `journalctl -p 3 -n 50 --no-pager`
- `journal_disk_usage`: `journalctl --disk-usage`

有 `dmesg` 时增加 `kernel_warnings`。`/var/log` 存在时增加 `var_log_usage`。没有 `journalctl` 才告警。样例里的 `-- No entries --` 只表示最近没有 priority 3 日志，不表示系统从未报错。

Windows 记录 System 和 Application 两个日志里 Level 为 2 的最近 20 条，命令名是 `system_errors` 和 `application_errors`。空表表示当前过滤条件下没有错误事件。

## 和国产系统命令手册的关系

巡检脚本的 `package` / `security` 结果只能说明通用 Linux 命令是否存在。银河麒麟、统信 UOS 的版本识别、软件源和安全中心还要按 [版本差异与排查要点](../../domestic-linux/VERSION-DIFFERENCES.md) 继续看。脚本不会因为发行版名字改变模块名。
