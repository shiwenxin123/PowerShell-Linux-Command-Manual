# Kubernetes DNS 异常排查

## 现象

- Pod 内访问 Service 名称失败。
- 应用日志出现 `no such host`、`Name or service not known`。
- 通过 ClusterIP 可以访问，但通过服务名或域名无法访问。
- 集群中部分命名空间或部分节点 DNS 异常。

## 快速判断

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl get svc -n kube-system kube-dns
kubectl get endpoints -n kube-system kube-dns
```

进入临时 Pod 测试:

```bash
kubectl run dns-test --rm -it --image=busybox:1.36 --restart=Never -- nslookup kubernetes.default
```

## 排查命令

```bash
# 查看 CoreDNS 日志
kubectl logs -n kube-system deploy/coredns

# 查看 CoreDNS 配置
kubectl get configmap coredns -n kube-system -o yaml

# 查看 kube-dns Service
kubectl describe svc kube-dns -n kube-system

# 查看 Pod DNS 配置
kubectl exec -n <namespace> <pod> -- cat /etc/resolv.conf

# 测试同命名空间 Service
kubectl exec -n <namespace> <pod> -- nslookup <service>

# 测试完整域名
kubectl exec -n <namespace> <pod> -- nslookup <service>.<namespace>.svc.cluster.local

# 查看事件
kubectl get events -A --sort-by=.lastTimestamp
```

## 常见原因

- CoreDNS Pod 未运行或反复重启。
- CoreDNS ConfigMap 配置错误。
- kube-dns Service 或 Endpoints 异常。
- 节点网络、CNI、NetworkPolicy 阻断到 DNS 服务的访问。
- Pod 的 `dnsPolicy` 或 `dnsConfig` 配置不正确。
- 上游 DNS 不可达，导致外部域名解析失败。

## 处理建议

- 先确认 CoreDNS Pod、副本数、Service 和 Endpoints 是否正常。
- 如果只有外部域名失败，重点检查 CoreDNS 上游 DNS 和节点 `/etc/resolv.conf`。
- 如果只有某个命名空间失败，检查 NetworkPolicy 和应用 Pod 的 DNS 配置。
- 修改 CoreDNS 配置前先备份 ConfigMap。

```bash
kubectl get configmap coredns -n kube-system -o yaml > coredns.backup.yaml
kubectl rollout restart deploy/coredns -n kube-system
kubectl rollout status deploy/coredns -n kube-system
```

## 高危提醒

- 不要直接删除 kube-system 中的 DNS 资源。
- 修改 CoreDNS 配置会影响整个集群解析，生产环境应先在测试集群验证。
- 重启 CoreDNS 前确认副本数和 PodDisruptionBudget，避免短时间内解析不可用。

## 相关专题

- [Kubernetes 进阶排查](../manual/kubernetes/ADVANCED-TROUBLESHOOTING.md)
- [Docker/Kubernetes 生产命令](../manual/kubernetes/DOCKER-K8S-PRODUCTION.md)
- [Linux 网络排查](../manual/linux/NETWORK.md)
