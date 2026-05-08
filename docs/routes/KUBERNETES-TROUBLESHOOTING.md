# Kubernetes 排障路线

这条路线适合 Kubernetes、Docker、containerd、Ingress、Service、Node 和监控链路排查。建议按资源链路从 Pod 往外查，不要一开始就重启节点或删除资源。

## 排查顺序

| 阶段 | 目标 | 推荐文档 |
| --- | --- | --- |
| 1. 先看集群和命名空间 | 确认上下文、命名空间和资源范围 | [Kubernetes 进阶排查](../manual/kubernetes/ADVANCED-TROUBLESHOOTING.md) |
| 2. 查 Pod 与事件 | 看状态、事件、日志和上一次崩溃日志 | [Pod CrashLoopBackOff](../cases/K8S-CRASHLOOPBACKOFF.md) |
| 3. 查镜像拉取 | 判断仓库、认证、网络和架构问题 | [ImagePullBackOff](../cases/K8S-IMAGEPULLBACKOFF.md)、[Docker 镜像拉取失败](../cases/DOCKER-IMAGE-PULL-FAILED.md) |
| 4. 查网络和 DNS | 检查 Service、Endpoints、CoreDNS、NetworkPolicy | [Kubernetes DNS 异常](../cases/K8S-DNS-FAILED.md) |
| 5. 查 Node | 看 kubelet、运行时、磁盘压力和网络 | [Kubernetes Node NotReady](../cases/K8S-NODE-NOTREADY.md) |
| 6. 查监控链路 | 确认 Prometheus target、Grafana 数据源和查询 | [Prometheus Target Down](../cases/PROMETHEUS-TARGET-DOWN.md)、[Grafana 无数据](../cases/GRAFANA-NO-DATA.md) |

## 高频命令

```bash
kubectl config current-context
kubectl get ns
kubectl get pod -A -o wide
kubectl get events -A --sort-by=.lastTimestamp
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace> --previous
kubectl get svc,endpoints,endpointslice -n <namespace>
kubectl get nodes -o wide
kubectl describe node <node>
```

## 按现象进入

| 现象 | 推荐入口 |
| --- | --- |
| Pod 反复重启 | [Pod CrashLoopBackOff 排查](../cases/K8S-CRASHLOOPBACKOFF.md) |
| 镜像拉不下来 | [Kubernetes ImagePullBackOff 排查](../cases/K8S-IMAGEPULLBACKOFF.md) |
| 节点 NotReady | [Kubernetes Node NotReady 排查](../cases/K8S-NODE-NOTREADY.md) |
| 集群内 DNS 失败 | [Kubernetes DNS 异常排查](../cases/K8S-DNS-FAILED.md) |
| 容器反复重启 | [Docker 容器反复重启排查](../cases/DOCKER-RESTARTING.md) |
| 监控 target down | [Prometheus Target Down 排查](../cases/PROMETHEUS-TARGET-DOWN.md) |

## 高危提醒

- 不要直接删除生产命名空间资源。
- `kubectl drain` 前确认副本数、PDB 和维护窗口。
- 修改 CoreDNS、Ingress、CNI、节点运行时前先备份配置。

## 下一步

- [Docker/Kubernetes 生产命令](../manual/kubernetes/DOCKER-K8S-PRODUCTION.md)
- [Docker 与 Kubernetes 运维速查](../containers/DOCKER-KUBERNETES-CHEATSHEET.md)
- [日志与监控体系](../manual/observability/LOGGING-MONITORING.md)
