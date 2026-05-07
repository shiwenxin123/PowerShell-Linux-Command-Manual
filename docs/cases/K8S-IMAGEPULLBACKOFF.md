# Kubernetes ImagePullBackOff 排查

## 现象

- Pod 状态显示 `ImagePullBackOff` 或 `ErrImagePull`。
- 新版本发布后 Pod 无法启动。
- `kubectl describe pod` 事件中出现镜像拉取失败。

## 快速判断

```bash
kubectl get pods -n <namespace>
kubectl describe pod <pod> -n <namespace>
```

重点查看 Events 中的错误信息。

## 排查命令

```bash
# 查看 Pod 使用的镜像
kubectl get pod <pod> -n <namespace> -o jsonpath='{.spec.containers[*].image}'

# 查看镜像拉取密钥
kubectl get secret -n <namespace>

# 查看 ServiceAccount
kubectl get serviceaccount -n <namespace>

# 查看节点是否能访问镜像仓库
kubectl get nodes -o wide
```

## 常见原因

- 镜像名称或 tag 写错。
- 镜像仓库需要认证，但没有配置 `imagePullSecrets`。
- 节点无法访问镜像仓库。
- 镜像架构与节点架构不匹配。
- 私有仓库证书不被节点信任。
- 镜像被删除或 tag 被覆盖。

## 处理建议

- 先确认镜像名称、tag 和仓库地址。
- 私有仓库检查 `imagePullSecrets` 是否在同一 namespace。
- 多架构环境检查节点架构和镜像架构。
- 内网环境确认节点到仓库的 DNS、路由、防火墙和证书。

## 高危提醒

- 不要随意把生产镜像 tag 改成 `latest`。
- 修复镜像仓库认证时不要把账号密码写进明文 YAML。
