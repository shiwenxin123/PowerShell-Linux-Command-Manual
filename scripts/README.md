# 示例脚本

这个目录用于存放可复制、可改造的运维脚本。脚本默认偏保守，只做信息收集或生成报告，不直接删除文件、不修改系统配置。

## 当前脚本

| 脚本 | 说明 |
| --- | --- |
| `linux-health-check.sh` | Linux 基础巡检，支持模块化检查、Markdown 和 JSON 报告 |
| `windows-health-check.ps1` | Windows PowerShell 基础巡检，支持模块化检查、Markdown 和 JSON 报告 |
| `check-docs.ps1` | 文档质量检查，检查代码块、相对链接和 MkDocs 导航 |

## 使用示例

Linux:

```bash
# 直接输出到终端
bash scripts/linux-health-check.sh

# 同时保存报告
bash scripts/linux-health-check.sh reports/linux-health-check.txt

# 只检查磁盘
bash scripts/linux-health-check.sh --module disk

# 生成 Markdown 报告
bash scripts/linux-health-check.sh --format markdown --output reports/linux-health-check.md

# 生成 JSON 报告
bash scripts/linux-health-check.sh --format json --output reports/linux-health-check.json

# 安全模块，包含麒麟/UOS 安全中心只读探测和本地 TLS 证书到期检查
bash scripts/linux-health-check.sh --module security
bash scripts/linux-health-check.sh --module security --format json
bash scripts/linux-health-check.sh --module security --cert-warn-days 14 --cert-path /path/to/certs
```

Windows PowerShell:

```powershell
# 直接输出到终端
.\scripts\windows-health-check.ps1

# 保存报告
.\scripts\windows-health-check.ps1 -OutputFile reports\windows-health-check.txt

# 只检查网络
.\scripts\windows-health-check.ps1 -Module network

# 生成 Markdown 报告
.\scripts\windows-health-check.ps1 -Format markdown -OutputFile reports\windows-health-check.md

# 生成 JSON 报告
.\scripts\windows-health-check.ps1 -Format json -OutputFile reports\windows-health-check.json
```

## 支持模块

| 模块 | 说明 |
| --- | --- |
| `all` | 默认，执行全部检查 |
| `system` | 系统版本、运行时间、内存等 |
| `disk` | 磁盘空间、inode 或驱动器信息 |
| `network` | 监听端口和网络路由 |
| `service` | 异常服务或未运行服务 |
| `process` | CPU 和内存占用较高的进程 |
| `security` | SSH、防火墙、SELinux/AppArmor、麒麟/UOS 安全中心只读探测；Linux 另含本地 TLS 证书到期检查 |

`security` 模块在防火墙和 SELinux/AppArmor 之外，会探测本机是否存在麒麟或统信安全中心。只查询软件包、systemd 单元和已知路径；命令存在时只执行 `status`。这些工具不存在时输出 `not-found`、`not-installed` 或 `absent`，不因此让脚本失败，也不执行 `enable`、`disable`、`set`、`allow`。

同一模块还会只读检查本地 TLS 证书是否过期。默认扫描 `/etc/nginx`、`/etc/httpd`、`/etc/pki/tls/certs`、`/etc/ssl/certs` 和 `/etc/letsencrypt/live`，并用 `--cert-path` 追加文件或目录。`--cert-warn-days` 默认 30。有 `openssl` 时报告使用者 CN、颁发者、`notAfter` 和剩余天数；没有 `openssl` 时输出 `openssl: not-found`，不因此失败。私钥文件会跳过，不打印内容，也不修改证书。

## 退出码

| 退出码 | 含义 |
| --- | --- |
| `0` | 巡检正常完成且无告警 |
| `1` | 巡检完成但存在告警或部分模块异常 |
| `2` | 参数错误 |
| `3` | 脚本内部异常或关键输出写入失败 |

## 本地检查

```powershell
# 文档检查
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-docs.ps1

# Windows 脚本语法检查
$parseErrors = $null
[System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw 'scripts/windows-health-check.ps1'), [ref]$parseErrors) | Out-Null
$parseErrors
```

Linux 脚本语法检查需要本机有 Bash:

```bash
bash -n scripts/linux-health-check.sh
```

如果 Windows 本机没有 Bash，可以以 GitHub Actions 中 Ubuntu 环境的 `bash -n` 检查结果为准。

## 使用建议

- 生产环境执行前先阅读脚本内容。
- 需要管理员权限的命令请在受控环境执行。
- 输出报告里可能包含主机名、IP、进程名等信息，公开分享前请脱敏。
