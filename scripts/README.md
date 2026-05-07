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

## 退出码

| 退出码 | 含义 |
| --- | --- |
| `0` | 巡检正常完成且无告警 |
| `1` | 巡检完成但存在告警或部分模块异常 |
| `2` | 参数错误 |
| `3` | 脚本内部异常或关键输出写入失败 |

## 使用建议

- 生产环境执行前先阅读脚本内容。
- 需要管理员权限的命令请在受控环境执行。
- 输出报告里可能包含主机名、IP、进程名等信息，公开分享前请脱敏。
