# Docker 与 Kubernetes 生产级命令

这个专题从主手册迁移容器与 Kubernetes 生产级命令，覆盖镜像、容器、资源限制、健康检查、Compose、Deployment、Service、ConfigMap、Secret 和节点维护。

## Docker 镜像管理

```bash
docker images
docker pull nginx:alpine
docker build -t myapp:v1 .
docker tag myapp:v1 registry.example.com/myapp:v1
docker push registry.example.com/myapp:v1
docker rmi nginx:alpine
docker image prune -a
```

## Docker 容器管理

```bash
docker run -d --name nginx -p 80:80 --restart=always --memory=512m --cpus=0.5 nginx:alpine
docker ps
docker ps -a
docker logs nginx
docker logs -f --tail=100 nginx
docker inspect nginx
docker exec -it nginx sh
docker cp file.txt nginx:/path/
docker cp nginx:/path/file.txt .
docker stop nginx
docker start nginx
docker restart nginx
docker rm -f nginx
docker container prune
```

## Docker 资源限制与健康检查

```bash
docker run -d \
    --name myapp \
    --memory=1g \
    --memory-reservation=800m \
    --cpus=1 \
    --ulimit nofile=65536:65536 \
    --health-cmd="curl -f http://localhost/health || exit 1" \
    --health-interval=10s \
    --health-timeout=5s \
    --health-retries=3 \
    myapp:v1
```

## Docker 网络与存储

```bash
# 网络
docker network create --driver bridge mynet
docker network ls
docker network inspect mynet
docker network connect mynet nginx
docker network disconnect mynet nginx

# 存储
docker volume create myvol
docker volume ls
docker volume inspect myvol
docker run -v myvol:/data nginx
docker volume prune
```

## Docker Compose

```bash
docker compose up -d
docker compose ps
docker compose logs -f
docker compose config
docker compose down
```

高危提醒: `docker compose down -v` 会删除 volume，生产环境谨慎执行。

## Kubernetes 集群信息

```bash
kubectl version --short
kubectl cluster-info
kubectl get nodes -o wide
kubectl top nodes
kubectl top pods
```

## Namespace

```bash
kubectl get namespaces
kubectl create namespace production
kubectl config set-context --current --namespace=production
```

## Pod 管理

```bash
kubectl get pods -o wide
kubectl get pods --show-labels
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs -f --tail=100 <pod-name>
kubectl logs -f <pod-name> -c <container-name>
kubectl exec -it <pod-name> -- sh
kubectl port-forward <pod-name> 8080:80
kubectl cp file.txt <pod-name>:/path/
kubectl delete pod <pod-name>
```

## Deployment 发布与回滚

```bash
kubectl apply -f deployment.yml
kubectl get deployments
kubectl rollout status deployment/nginx
kubectl rollout history deployment/nginx
kubectl set image deployment/nginx nginx=nginx:1.26-alpine
kubectl rollout undo deployment/nginx
kubectl scale deployment/nginx --replicas=5
kubectl autoscale deployment/nginx --min=3 --max=10 --cpu-percent=80
```

## Service

```bash
kubectl get services
kubectl expose deployment nginx --port=80 --target-port=80 --type=ClusterIP
kubectl expose deployment nginx --port=80 --target-port=80 --type=NodePort
kubectl expose deployment nginx --port=80 --target-port=80 --type=LoadBalancer
```

## ConfigMap 与 Secret

```bash
kubectl create configmap nginx-config --from-file=nginx.conf
kubectl create secret generic db-secret --from-literal=username=admin --from-literal=password=secret
kubectl get configmaps
kubectl get secrets
```

安全提醒: Secret 示例只适合演示。生产环境不要在命令历史或明文 YAML 中暴露真实密码。

## 事件、调试与节点维护

```bash
kubectl get events --sort-by='.lastTimestamp'
kubectl api-resources
kubectl explain deployment.spec
kubectl debug -it <pod-name> --image=busybox --share-processes
kubectl cordon <node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
kubectl uncordon <node-name>
```

延伸阅读:

- [Docker 与 Kubernetes 运维速查](../../containers/DOCKER-KUBERNETES-CHEATSHEET.md)
- [Kubernetes 进阶排查](ADVANCED-TROUBLESHOOTING.md)
- [Docker Compose 启动失败排查](../../cases/DOCKER-COMPOSE-FAILED.md)
