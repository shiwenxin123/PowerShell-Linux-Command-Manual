# Docker 容器反复重启排查

## 现象

- `docker ps` 中容器反复 Restarting。
- 应用访问失败。
- 容器日志持续输出错误。

## 快速判断

```bash
docker ps -a
docker logs --tail 100 <container>
docker inspect <container>
```

## 排查命令

```bash
# 查看退出码
docker inspect <container> --format '{{.State.ExitCode}}'

# 查看重启次数
docker inspect <container> --format '{{.RestartCount}}'

# 查看挂载
docker inspect <container> --format '{{json .Mounts}}'

# 查看资源
docker stats
```

## 常见原因

- 启动命令错误。
- 配置文件缺失或格式错误。
- 环境变量缺失。
- 端口冲突。
- 挂载目录权限不足。
- 应用依赖的数据库、Redis、消息队列不可达。

## 处理建议

- 先看容器日志，确认应用自身报错。
- 检查镜像版本、环境变量、挂载路径和网络。
- 临时排查可用 `docker run --rm -it image sh` 进入同镜像环境验证。

## 高危提醒

- 不要随意删除 volume，可能丢失持久化数据。
- `docker system prune -a` 会清理大量缓存和镜像，生产环境谨慎执行。
