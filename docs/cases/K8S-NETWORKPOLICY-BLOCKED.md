# Kubernetes NetworkPolicy 拦截排查

## 现象

- 部分 Pod 访问 Service 超时，`connect timed out` 或 `i/o timeout`。同命名空间或集群外另一条路径仍然正常。
- `connection refused` 不是本案例的典型现象。拒绝连接通常表示端口上没有进程，先查 Pod 是否在监听。
- Service 有 ClusterIP，Endpoints 或 EndpointSlice 里也有 Pod 地址，但从指定客户端仍然不通。
- 发布或收紧 NetworkPolicy 之后开始失败。失败前没有应用重启。
- 只有跨命名空间访问失败，或者应用能解析 Service 名称，但业务端口不通。DNS 超时要同时看 [Kubernetes DNS 异常排查](K8S-DNS-FAILED.md)，因为出站策略经常把 53 端口一起丢掉。

NetworkPolicy 丢包通常没有 Kubernetes Event。`kubectl describe pod` 里看不到 “blocked by network policy”。

## 快速判断

把命名空间、Service 和发起访问的 Pod 换成现场名称。下面用 `example`、`example-api`、`example-web` 表示被访问的服务和客户端，地址使用文档测试网段。

```bash
# 后端是否真的存在。空 Endpoints 时先查 Service selector 和 Pod 标签，不要先改策略
kubectl get svc,endpoints,endpointslice -n example
kubectl get pods -n example -o wide --show-labels

# 这个命名空间里有没有策略。没有任何策略时，Kubernetes 默认放行，拦截原因在别的层
kubectl get networkpolicy -n example
kubectl get networkpolicy -A
```

先看三件事:

1. Endpoints 里有 Pod IP，并且 Pod 是 Running。
2. `example` 命名空间存在 NetworkPolicy，且 `podSelector` 能选中被访问的 Pod。
3. 客户端所在命名空间、Pod 标签和端口，出现在策略的 `from` 或 `to` 里。

策略对象存在，不等于集群会执行它。Flannel 默认、部分云厂商 CNI 或未开启策略的网络插件会忽略 NetworkPolicy。此时删策略也不会改变连通性。先确认 CNI 是否实现 NetworkPolicy，再把它当成原因。

## 排查命令

### Service、Endpoints 和 Pod 标签

```bash
kubectl get svc example-api -n example -o wide
kubectl describe svc example-api -n example
kubectl get endpoints example-api -n example
kubectl get endpointslice -n example -l kubernetes.io/service-name=example-api

# 用 Service 的 selector 反查 Pod。查不到说明 Endpoints 为空的原因是标签，不是策略
kubectl get pods -n example -l app=example-api -o wide --show-labels
```

期望:

- Endpoints 的 Addresses 是 Pod IP，不是空。
- Pod IP 与 `kubectl get pods -o wide` 一致。
- 目标端口和 Pod `containerPort` 一致。端口写错时，策略即使放行也会失败。

### 策略选中了谁

```bash
kubectl get networkpolicy -n example
kubectl describe networkpolicy -n example
kubectl get networkpolicy -n example -o yaml
```

对每一条选中业务 Pod 的策略核对:

- `PodSelector` 是否为空。空选择器表示命名空间内全部 Pod。
- `Policy Types` 是否包含 Ingress、Egress，或两者都有。
- Ingress 的 `From`、Egress 的 `To` 是否包含客户端命名空间和 Pod 标签。
- `Ports` 是否包含实际访问的协议和端口。只放行 TCP 80 时，访问 8080 会超时。

```bash
# 策略写的标签，现场 Pod 是否真的有
kubectl get pods -n example --show-labels
kubectl get ns --show-labels
```

很多 1.22 及更新的集群会自动给命名空间打上 `kubernetes.io/metadata.name=<namespace>`。更早版本，或关闭了这个行为的集群，没有该标签。`namespaceSelector` 使用它之前，先执行 `kubectl get ns example-web --show-labels`。

只读查看不能代替一次真实连接。优先从已经存在的客户端 Pod 里测，不要先创建新工作负载:

```bash
# 容器里不一定有 wget、curl 或 nc。先看有哪个命令
kubectl exec -n example-web deploy/example-web -- command -v wget
kubectl exec -n example-web deploy/example-web -- command -v nc

# 有 wget 时。超时约 3 秒仍无输出，才继续看策略
kubectl exec -n example-web deploy/example-web -- wget -qO- --timeout=3 http://example-api.example.svc:8080/
```

没有现成客户端，并且允许在集群里创建一个调试 Pod 时再用下面的命令。它会新建 Pod，结束后删除的是这个调试 Pod:

```bash
# 内网集群可能拉不到 busybox。改成现场已有的调试镜像
# 没有交互终端时不要加 -it，结束后确认只删 netpol-debug
kubectl delete pod netpol-debug -n example-web --ignore-not-found
kubectl run netpol-debug -n example-web --restart=Never --image=busybox:1.36 --command -- wget -qO- --timeout=3 http://example-api.example.svc:8080/
kubectl logs -n example-web netpol-debug
kubectl delete pod netpol-debug -n example-web --wait=true
```

### 插件自己的策略对象

`kubectl get networkpolicy` 看不到 Calico、Cilium 等插件的集群级策略。CRD 不存在时，下面的命令会报错，这表示当前集群没有这种对象，不是故障本身。

```bash
# Calico。CRD 名称随版本变化，报错就换 kubectl api-resources 里实际的名字
kubectl get globalnetworkpolicies.crd.projectcalico.org -A
kubectl get networkpolicies.crd.projectcalico.org -A

# Cilium
kubectl get ciliumnetworkpolicies,ciliumclusterwidenetworkpolicies -A

kubectl api-resources | grep -Ei 'networkpolicy|cilium|calico'
```

集群级默认拒绝会作用到多个命名空间。只改业务命名空间里的 NetworkPolicy 可能不够。

### 和 DNS、kubelet 故障分开

```bash
kubectl exec -n example-web deploy/example-web -- getent hosts example-api.example.svc
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

名称能解析、ClusterIP 超时: 优先继续查业务端口上的 NetworkPolicy。名称也不能解析: 同时查 CoreDNS 和到 `kube-system` UDP/TCP 53 的 Egress。

## 常见原因

- 命名空间里有一条 `podSelector` 命中业务 Pod、`policyTypes` 含 Ingress，但 `ingress` 为空或没有客户端来源。这是只拒绝入站的默认拒绝。
- 策略允许了命名空间，但 `podSelector` 还要求 `app=example-web`，客户端 Pod 没有这个标签。
- 端口或协议不一致。Service 端口 80 转到 Pod 8080 时，NetworkPolicy 限制的是 Pod 端口。
- Egress 只放行了业务网段，没有放行 DNS。现象会变成解析失败，而不是 HTTP 500。
- 客户端在另一个命名空间，策略却只写了同一命名空间的 `podSelector`。
- 集群还存在 Calico GlobalNetworkPolicy 或 CiliumClusterwideNetworkPolicy。
- CNI 不执行 NetworkPolicy。策略 YAML 看起来像原因，连通性却不受它控制。
- `hostNetwork: true` 的 Pod 不按普通 Pod 网络被同一条策略处理。不能用它的连通性证明策略没有生效。

## 处理建议

1. 先导出当前策略。后面的修改都以这份文件为回滚依据。

    ```bash
    kubectl get networkpolicy -n example -o yaml > networkpolicy-example.backup.yaml
    ```

2. 只给确认过的客户端补入口，不要删除命名空间里的全部策略。下面是一条入站示例，标签和端口必须改成上一步看到的真实值。`kubectl apply` 会改变集群:

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: example-api-allow-web
      namespace: example
    spec:
      podSelector:
        matchLabels:
          app: example-api
      policyTypes:
        - Ingress
      ingress:
        - from:
            - namespaceSelector:
                matchLabels:
                  kubernetes.io/metadata.name: example-web
              podSelector:
                matchLabels:
                  app: example-web
          ports:
            - protocol: TCP
              port: 8080
    ```

    ```bash
    kubectl apply -f example-api-allow-web.yaml
    kubectl describe networkpolicy example-api-allow-web -n example
    ```

3. 如果应用自己也要访问外部或 DNS，原策略含 Egress 时单独补出站。先确认 `kube-system` 的标签:

    ```bash
    kubectl get ns kube-system --show-labels
    ```

    DNS 放行只作为缺口补齐，不要改成放行全部出站。补完后从客户端再执行一次带超时的访问。

4. 恢复确认:

    - 同一条 `wget` 或业务健康检查返回响应，而不是超时。
    - 不应被允许的来源仍然超时。用一个不匹配标签的 Pod 复测，避免把策略放成全开。
    - `kubectl get endpoints example-api -n example` 仍然有地址。

5. 需要回滚时，用备份文件覆盖，不要手工清空目录里不相关的对象:

    ```bash
    kubectl apply -f networkpolicy-example.backup.yaml
    ```

    Kubernetes 1.19 之前的 NetworkPolicy API 可能不是 `networking.k8s.io/v1`。写文件前执行 `kubectl explain networkpolicy`，按集群实际版本写 `apiVersion`。

## 高危提醒

- 不要执行 `kubectl delete networkpolicy --all` 或删除整个命名空间。删除策略会取消这层隔离，生产集群上等于把原来拒绝的流量放开。
- 不要用 `0.0.0.0/0`、空 `namespaceSelector` 加空 `podSelector` 当临时放行。那会允许所有来源。
- 不要为了验证去改 `kube-system` 里的网络策略。DNS 中断会影响整个集群。
- `kubectl delete pod netpol-debug` 只用于删掉自己创建的调试 Pod。不要按标签批量删除业务 Pod。
- 备份文件可能含内部命名空间和标签，不要把未脱敏的 YAML 贴到公开工单。

## 相关专题

- [Kubernetes 进阶排查](../manual/kubernetes/ADVANCED-TROUBLESHOOTING.md)
- [Docker/Kubernetes 生产命令](../manual/kubernetes/DOCKER-K8S-PRODUCTION.md)
- [Kubernetes DNS 异常排查](K8S-DNS-FAILED.md)
- [Kubernetes 排障路线](../routes/KUBERNETES-TROUBLESHOOTING.md)
