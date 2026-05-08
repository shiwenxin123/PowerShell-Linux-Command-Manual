# Docker 镜像拉取失败排查

## 现象

- `docker pull` 报 `connection refused`、`timeout` 或 `no route to host`。
- 报 `manifest not found`、`pull access denied` 或认证失败。
- Docker Compose 启动卡在拉取镜像阶段。
- Kubernetes 中表现为 `ImagePullBackOff` 或 `ErrImagePull`。

## 快速判断

先判断是网络问题、认证问题、镜像名问题还是仓库证书问题。

```bash
docker pull <image>:<tag>
docker info
docker login <registry>
curl -I https://<registry>/v2/
```

## 排查命令

```bash
# 检查 DNS 和路由
nslookup <registry>
curl -v https://<registry>/v2/

# 查看 Docker daemon 日志
journalctl -u docker -n 100 --no-pager

# 检查代理配置
systemctl show docker -p Environment
cat /etc/systemd/system/docker.service.d/*.conf 2>/dev/null

# 查看镜像架构
docker manifest inspect <image>:<tag>

# 检查私有仓库证书
openssl s_client -connect <registry>:443 -servername <registry> </dev/null
```

## 常见原因

- 镜像名称、tag、仓库地址写错。
- 私有仓库需要登录或 token 已过期。
- 服务器无法访问外网或仓库域名解析失败。
- Docker daemon 代理未配置或配置错误。
- 私有仓库 TLS 证书不被节点信任。
- 节点架构与镜像架构不匹配。

## 处理建议

- 先确认镜像名、tag 和 registry 地址是否存在。
- 私有仓库优先修复认证和权限，不要使用明文密码写入脚本。
- 内网环境确认 DNS、代理、镜像加速器或离线镜像仓库配置。
- 证书问题应安装可信 CA 或使用正确证书链。
- 多架构环境固定合适架构的镜像 tag 或 manifest。

## 高危提醒

- 不要把生产镜像临时改成 `latest`。
- 不要把 registry 用户名密码提交到 Git 仓库。
- 不要在生产 Docker daemon 中长期配置不可信 registry。

## 相关专题

- [Docker 与 Kubernetes 运维速查](../containers/DOCKER-KUBERNETES-CHEATSHEET.md)
- [Docker/Kubernetes 生产命令](../manual/kubernetes/DOCKER-K8S-PRODUCTION.md)
- [Kubernetes ImagePullBackOff 排查](K8S-IMAGEPULLBACKOFF.md)
