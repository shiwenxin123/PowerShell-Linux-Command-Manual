# Docker 与 Kubernetes 运维速查

这个页面覆盖容器和 Kubernetes 的高频查看、排障和发布命令。生产环境执行变更命令前，请先确认命名空间、上下文和目标资源。

## Docker 常用命令

```bash
# 查看容器
docker ps
docker ps -a

# 查看镜像
docker images

# 查看日志
docker logs <container>
docker logs -f --tail 100 <container>

# 进入容器
docker exec -it <container> sh

# 查看容器资源
docker stats

# 查看容器详情
docker inspect <container>
```

## Docker 排障

```bash
# 查看容器退出原因
docker ps -a
docker logs <container>

# 查看端口映射
docker port <container>

# 查看容器内进程
docker top <container>
```

高危提醒:

- `docker system prune -a` 会删除未使用镜像、容器和缓存，执行前要确认。
- 不建议在生产环境随意删除 volume。

## Kubernetes 上下文

```bash
# 查看当前上下文
kubectl config current-context

# 查看所有上下文
kubectl config get-contexts

# 切换上下文
kubectl config use-context <context>

# 查看命名空间
kubectl get ns
```

## Kubernetes 查看资源

```bash
# 查看 Pod
kubectl get pods -A
kubectl get pods -n <namespace>

# 查看服务
kubectl get svc -n <namespace>

# 查看部署
kubectl get deploy -n <namespace>

# 查看事件
kubectl get events -n <namespace> --sort-by=.lastTimestamp
```

## Kubernetes 日志与排障

```bash
# 查看日志
kubectl logs <pod> -n <namespace>
kubectl logs -f <pod> -n <namespace>

# 多容器 Pod 指定容器
kubectl logs <pod> -c <container> -n <namespace>

# 查看资源详情
kubectl describe pod <pod> -n <namespace>

# 进入容器
kubectl exec -it <pod> -n <namespace> -- sh
```

## 发布与回滚

```bash
# 查看发布状态
kubectl rollout status deploy/<deployment> -n <namespace>

# 查看历史版本
kubectl rollout history deploy/<deployment> -n <namespace>

# 回滚上一个版本
kubectl rollout undo deploy/<deployment> -n <namespace>
```

## 常见问题

| 现象 | 优先排查 |
| --- | --- |
| `CrashLoopBackOff` | `kubectl logs`、`kubectl describe pod` |
| `ImagePullBackOff` | 镜像地址、镜像仓库权限、网络 |
| `Pending` | 节点资源、调度约束、PVC |
| `Service` 不通 | Endpoints、Pod 标签、端口映射 |
| 配置不生效 | ConfigMap/Secret 挂载方式、Pod 是否重启 |

## 相关案例

- [Docker 容器反复重启排查](../cases/DOCKER-RESTARTING.md)
- [Docker 镜像拉取失败排查](../cases/DOCKER-IMAGE-PULL-FAILED.md)
- [Docker Compose 启动失败排查](../cases/DOCKER-COMPOSE-FAILED.md)
- [Kubernetes Pod CrashLoopBackOff 排查](../cases/K8S-CRASHLOOPBACKOFF.md)
- [Kubernetes ImagePullBackOff 排查](../cases/K8S-IMAGEPULLBACKOFF.md)
- [Kubernetes Node NotReady 排查](../cases/K8S-NODE-NOTREADY.md)
