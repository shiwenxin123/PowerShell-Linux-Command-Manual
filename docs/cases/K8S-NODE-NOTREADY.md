# Kubernetes Node NotReady 排查

## 现象

- `kubectl get nodes` 显示节点状态为 `NotReady`。
- 节点上的 Pod 无法正常调度或大量驱逐。
- 监控告警提示 kubelet down、节点磁盘压力或网络不可达。
- 节点重启后长时间无法恢复 Ready。

## 快速判断

先确认节点条件、kubelet 状态和最近事件。

```bash
kubectl get nodes -o wide
kubectl describe node <node-name>
kubectl get events -A --sort-by=.lastTimestamp | tail -n 50
```

## 排查命令

```bash
# 在异常节点上检查 kubelet
systemctl status kubelet --no-pager
journalctl -u kubelet -n 200 --no-pager

# 检查容器运行时
systemctl status containerd --no-pager
crictl ps 2>/dev/null

# 检查磁盘、内存和 inode
df -h
df -i
free -m

# 检查节点网络
ip addr
ip route
ss -tulnp | grep -E '10250|10255'

# 查看 CNI 相关 Pod
kubectl get pod -A -o wide | grep <node-name>
kubectl get pod -n kube-system -o wide
```

## 常见原因

- kubelet 未运行或证书、配置异常。
- containerd、Docker 等容器运行时异常。
- 节点磁盘空间、inode 或内存不足。
- CNI 插件异常导致节点网络不可用。
- 节点到 apiserver 网络不通或时间不同步。
- 节点被手动 cordon、污点或云主机故障影响。

## 处理建议

- 先从 `kubectl describe node` 的 Conditions 判断压力类型。
- kubelet 或运行时异常时，先保存日志再尝试重启服务。
- 磁盘压力优先清理明确可删除的镜像、日志和临时文件。
- 网络异常时检查 CNI Pod、路由、防火墙和安全组。
- 节点恢复后观察 Pod 是否自动拉起，并确认业务副本健康。

## 高危提醒

- 不要在未确认副本和业务影响前直接重启生产节点。
- 清理镜像和日志前确认不会删除业务数据卷。
- 执行 `kubectl drain` 前确认 PodDisruptionBudget 和可用副本。

## 相关专题

- [Kubernetes 进阶排查](../manual/kubernetes/ADVANCED-TROUBLESHOOTING.md)
- [Docker/Kubernetes 生产命令](../manual/kubernetes/DOCKER-K8S-PRODUCTION.md)
- [磁盘空间满排查](DISK-FULL.md)
