# 端口被占用排查

## 现象

- 服务启动失败。
- 日志出现 `Address already in use`。
- 本地调试端口无法绑定。

## 快速判断

Linux:

```bash
ss -tulnp | grep ':8080'
lsof -i :8080
```

PowerShell:

```powershell
Get-NetTCPConnection -LocalPort 8080
```

## 排查命令

Linux:

```bash
# 查看进程详情
ps -fp <PID>

# 查看服务状态
systemctl status <service>
```

PowerShell:

```powershell
# 根据 PID 查看进程
Get-Process -Id <PID>
```

## 处理建议

- 如果端口被同一个服务旧进程占用，优先用服务管理命令停止或重启。
- 如果端口被其他服务占用，修改当前服务端口或调整部署规划。
- 本地开发场景可以关闭占用进程，但生产环境要先确认进程用途。

## 高危提醒

- 不要只看到端口占用就直接强杀 PID。
- SSH、数据库、网关、注册中心等基础服务被误杀会造成更大故障。
