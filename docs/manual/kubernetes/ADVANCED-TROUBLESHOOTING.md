# Kubernetes 进阶排查

Kubernetes 排查建议按资源链路推进: Pod -> Service -> Endpoints -> Ingress -> Node -> Storage -> Helm Release。

## 上下文与命名空间

```bash
# 当前上下文
kubectl config current-context

# 所有上下文
kubectl config get-contexts

# 查看命名空间
kubectl get ns
```

## Pod 与事件

```bash
# 查看 Pod
kubectl get pods -n <namespace> -o wide

# 查看详情
kubectl describe pod <pod> -n <namespace>

# 查看事件
kubectl get events -n <namespace> --sort-by=.lastTimestamp

# 查看日志
kubectl logs <pod> -n <namespace>
kubectl logs <pod> -c <container> -n <namespace>
```

## Service 与 Endpoints

```bash
# 查看 Service
kubectl get svc -n <namespace>

# 查看 Endpoints
kubectl get endpoints -n <namespace>

# 查看 EndpointSlice
kubectl get endpointslice -n <namespace>

# 查看 Service 详情
kubectl describe svc <service> -n <namespace>
```

排查重点:

- Service selector 是否匹配 Pod labels。
- targetPort 是否和容器监听端口一致。
- Endpoints 是否为空。

## Ingress

```bash
# 查看 Ingress
kubectl get ingress -n <namespace>

# 查看 Ingress 详情
kubectl describe ingress <ingress> -n <namespace>

# 查看 Ingress Controller Pod
kubectl get pods -A | grep -i ingress
```

排查重点:

- Host、Path、ServiceName、ServicePort 是否正确。
- TLS Secret 是否存在。
- Ingress Controller 是否正常运行。

## 存储 PVC/PV

```bash
# 查看 PVC
kubectl get pvc -n <namespace>

# 查看 PV
kubectl get pv

# 查看 StorageClass
kubectl get storageclass

# 查看 PVC 详情
kubectl describe pvc <pvc> -n <namespace>
```

常见问题:

- PVC Pending。
- StorageClass 不存在。
- 动态供给失败。
- 节点无法挂载卷。

## Node 排查

```bash
# 查看节点
kubectl get nodes -o wide

# 查看节点详情
kubectl describe node <node>

# 查看节点资源
kubectl top node

# 查看 Pod 资源
kubectl top pod -A
```

## Helm

```bash
# 查看 Release
helm list -A

# 查看状态
helm status <release> -n <namespace>

# 查看历史
helm history <release> -n <namespace>

# 回滚
helm rollback <release> <revision> -n <namespace>
```

## 常见现象对应入口

| 现象 | 优先排查 |
| --- | --- |
| Pod 无法启动 | `describe pod`、`logs`、`events` |
| Service 不通 | `svc`、`endpoints`、labels、targetPort |
| Ingress 404/502 | Ingress 规则、Service、Controller 日志 |
| PVC Pending | PVC、PV、StorageClass、存储插件 |
| 发布失败 | Helm status、history、values |

延伸案例:

- [Pod CrashLoopBackOff 排查](../../cases/K8S-CRASHLOOPBACKOFF.md)
- [ImagePullBackOff 排查](../../cases/K8S-IMAGEPULLBACKOFF.md)
