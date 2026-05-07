# Kubernetes Pod CrashLoopBackOff 排查

## 现象

- `kubectl get pods` 显示 `CrashLoopBackOff`。
- Pod 不断重启。
- 服务不可用或只有部分副本可用。

## 快速判断

```bash
kubectl get pods -n <namespace>
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace>
```

多容器 Pod:

```bash
kubectl logs <pod> -c <container> -n <namespace>
```

## 排查命令

```bash
# 查看上一次崩溃日志
kubectl logs <pod> -n <namespace> --previous

# 查看事件
kubectl get events -n <namespace> --sort-by=.lastTimestamp

# 查看部署配置
kubectl get deploy <deployment> -n <namespace> -o yaml
```

## 常见原因

- 应用启动失败。
- 配置文件、环境变量或 Secret 缺失。
- 镜像版本错误。
- 探针配置不合理。
- 依赖服务不可达。
- 容器内文件权限不正确。

## 处理建议

- 优先查看 `--previous` 日志。
- 检查 ConfigMap、Secret、启动命令和探针。
- 如果新版本发布后出现，查看 rollout 历史并考虑回滚。

```bash
kubectl rollout history deploy/<deployment> -n <namespace>
kubectl rollout undo deploy/<deployment> -n <namespace>
```

## 高危提醒

- 回滚前确认影响范围和当前流量。
- 不要直接删除生产命名空间资源。
