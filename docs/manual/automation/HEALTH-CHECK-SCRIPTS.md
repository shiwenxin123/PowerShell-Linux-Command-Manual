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
| `security` | SSH、防火墙、SELinux/AppArmor、Defender 等基础安全状态 |
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

- [Linux JSON 示例](../../examples/linux-health-check.sample.json)
- [Windows JSON 示例](../../examples/windows-health-check.sample.json)
- [JSON Schema](../../schema/health-check-report.schema.json)
