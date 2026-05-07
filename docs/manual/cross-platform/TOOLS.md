# 跨平台脚本与工具

跨平台运维建议优先选择在 Windows、Linux 和 CI 环境都容易运行的工具，例如 PowerShell 7、Python、Node.js、Git、curl、Docker。

## 常用工具

| 工具 | 适用场景 | Windows | Linux | macOS |
| --- | --- | --- | --- | --- |
| PowerShell 7 | 跨平台脚本和系统管理 | 支持 | 支持 | 支持 |
| Python | 自动化、文本处理、接口调用 | 支持 | 支持 | 支持 |
| Node.js | 前端工具链、轻量脚本 | 支持 | 支持 | 支持 |
| Git | 版本控制和协作 | 支持 | 支持 | 支持 |
| Docker | 环境封装和一致性运行 | 支持 | 支持 | 支持 |
| curl | HTTP 请求测试 | 支持 | 支持 | 支持 |
| wget | 下载和镜像同步 | 支持 | 支持 | 支持 |
| jq | JSON 处理 | 支持 | 支持 | 支持 |
| fzf | 交互式模糊查找 | 支持 | 支持 | 支持 |
| ripgrep | 快速文本搜索 | 支持 | 支持 | 支持 |
| fd | 快速文件查找 | 支持 | 支持 | 支持 |
| bat | 带语法高亮的 cat 替代 | 支持 | 支持 | 支持 |
| exa/eza | 现代 ls 替代 | 支持 | 支持 | 支持 |
| starship | 跨平台 Shell 提示符 | 支持 | 支持 | 支持 |

## 按场景选择

| 场景 | 推荐工具 |
| --- | --- |
| 文件同步 | `rsync`、`scp`、`sftp`、Git |
| 远程连接 | OpenSSH、PowerShell Remoting、Windows Terminal |
| 压缩解压 | `tar`、`zip`、`7z` |
| 文本处理 | `rg`、`jq`、`awk`、PowerShell pipeline |
| 网络诊断 | `curl`、`wget`、`ping`、`traceroute`、`mtr` |
| 自动化脚本 | PowerShell 7、Python、Node.js、Bash |

## PowerShell 跨平台建议

```powershell
# 查看 PowerShell 版本
$PSVersionTable

# 使用 Join-Path 处理路径
Join-Path $HOME "logs"
```

## Python 跨平台建议

```python
from pathlib import Path

log_dir = Path.home() / "logs"
print(log_dir)
```

## 路径处理建议

- 不要在脚本里硬编码 `/` 或 `\`。
- PowerShell 使用 `Join-Path`。
- Python 使用 `pathlib`。
- Node.js 使用 `path.join`。

## 文件同步

```bash
# Linux/macOS 常用
rsync -avz ./dist/ user@server:/opt/app/
scp file.txt user@server:/tmp/
sftp user@server
```

```powershell
# PowerShell 跨平台复制
Copy-Item .\dist\* \\server\share\dist -Recurse
```

## 文本和 JSON 处理

```bash
# 快速搜索
rg "error|failed" logs/

# JSON 提取
curl -s https://example.com/api | jq '.items[] | {name, status}'

# 查找文件
fd "\.log$" /var/log
```

```powershell
# PowerShell 对象管道
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

# JSON 转对象
Get-Content report.json -Raw | ConvertFrom-Json
```

## 压缩解压

```bash
# tar
tar -czf logs.tar.gz logs/
tar -xzf logs.tar.gz

# zip
zip -r archive.zip folder/
unzip archive.zip
```

```powershell
Compress-Archive -Path .\logs -DestinationPath logs.zip
Expand-Archive -Path logs.zip -DestinationPath .\logs-out
```

## 网络诊断

```bash
# HTTP 调试
curl -I https://example.com
curl -v https://example.com

# 下载
wget https://example.com/file.tar.gz

# 路由和链路
ping example.com
traceroute example.com
mtr example.com
```

## 推荐原则

- 能用结构化对象就不要只解析纯文本，例如 PowerShell 对象、JSON、CSV。
- 团队脚本优先选择依赖少、安装简单、Windows/Linux 都可运行的工具。
- 在 CI 中固定工具版本，避免不同机器行为不一致。
- 面向新同事的脚本要写清楚依赖、输入、输出和失败处理。

## 延伸阅读

- [示例脚本](https://github.com/shiwenxin123/PowerShell-Linux-/tree/main/scripts)
- [PowerShell 与 Bash 命令对照](../../POWERSHELL-BASH-COMPARISON.md)
