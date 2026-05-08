# systemd 服务启动失败排查

## 现象

- 执行 `systemctl start <service>` 后服务启动失败。
- `systemctl status` 显示 `failed`、`activating` 后退出或反复重启。
- 应用端口未监听，业务请求失败。
- 日志中出现配置错误、权限错误、依赖缺失或退出码异常。

## 快速判断

先确认服务状态、最近日志和单元文件是否被正确加载。

```bash
systemctl status <service> --no-pager
journalctl -u <service> -n 100 --no-pager
systemctl cat <service>
```

## 排查命令

```bash
# 查看服务是否启用和最近失败原因
systemctl is-enabled <service>
systemctl show <service> -p ExecMainStatus -p ExecMainCode -p Result

# 查看完整日志
journalctl -u <service> --since "30 minutes ago" --no-pager

# 检查单元文件语法和加载状态
systemd-analyze verify /etc/systemd/system/<service>.service
systemctl daemon-reload

# 查看服务用户、工作目录和环境变量
systemctl show <service> -p User -p Group -p WorkingDirectory -p Environment

# 检查端口占用
ss -tulnp | grep ':<port>'
```

## 常见原因

- 服务配置文件语法错误或路径写错。
- `ExecStart` 指向的二进制、脚本或参数不存在。
- 服务运行用户没有读取配置、写日志或访问目录的权限。
- 依赖服务未启动，例如数据库、Redis、消息队列。
- 端口被其他进程占用。
- 修改 unit 文件后没有执行 `systemctl daemon-reload`。

## 处理建议

- 先保存 `systemctl status` 和 `journalctl` 输出，确认首个报错点。
- 如果修改了 unit 文件，执行 `systemd-analyze verify` 后再 reload。
- 路径、权限、环境变量问题优先修正配置，不要直接放宽到 `777`。
- 端口冲突时先确认占用进程用途，再调整端口或停止旧服务。
- 依赖服务未就绪时，补充健康检查、启动顺序或重试机制。

## 高危提醒

- 不要在生产环境盲目执行 `systemctl restart`，先确认影响范围。
- 不要为了启动成功直接改成 root 运行，可能扩大安全风险。
- 修改服务文件后保留备份，便于回滚。

## 相关专题

- [Linux 基础](../manual/linux/BASIC.md)
- [Linux 监控与日志](../manual/linux/MONITORING-LOGS.md)
- [端口被占用排查](PORT-IN-USE.md)
