# Docker Compose 启动失败排查

## 现象

- `docker compose up -d` 失败。
- 容器启动后立即退出。
- 多服务依赖启动顺序异常。
- 日志中出现端口冲突、环境变量缺失或挂载失败。

## 快速判断

```bash
docker compose ps
docker compose logs --tail 100
docker compose config
```

## 排查命令

```bash
# 查看指定服务日志
docker compose logs -f <service>

# 检查端口占用
ss -tulnp | grep ':8080'

# 查看容器退出原因
docker compose ps -a

# 重新创建服务
docker compose up -d --force-recreate
```

## 常见原因

- `compose.yml` 语法错误。
- `.env` 缺失或变量名不一致。
- 主机端口被占用。
- 挂载目录不存在或权限不足。
- 服务依赖的数据库、Redis、消息队列未就绪。
- 镜像拉取失败或架构不匹配。

## 处理建议

- 先执行 `docker compose config` 检查配置渲染结果。
- 再看具体服务日志，不要只看 compose 总输出。
- 对依赖服务增加健康检查，而不是只依赖启动顺序。
- 端口冲突时先确认占用进程用途。

## 高危提醒

- `docker compose down -v` 会删除 volume，可能造成数据丢失。
- 生产环境执行重建前确认数据卷和备份。
