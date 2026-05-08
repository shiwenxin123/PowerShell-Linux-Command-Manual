# 证书过期排查

## 现象

- 浏览器提示证书过期。
- `curl` 提示 certificate has expired。
- HTTPS 接口调用失败。
- Nginx、网关或 Ingress 日志出现 TLS 相关错误。

## 快速判断

```bash
# 查看站点证书时间
echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -dates
```

## 排查命令

```bash
# 查看本地证书文件
openssl x509 -in /path/to/cert.pem -noout -subject -issuer -dates

# 查看 Nginx 配置中的证书路径
nginx -T | grep -E "ssl_certificate|ssl_certificate_key"

# 检查系统时间
date
timedatectl
```

Kubernetes:

```bash
# 查看 TLS Secret
kubectl get secret <secret> -n <namespace> -o yaml

# 查看 Ingress
kubectl describe ingress <ingress> -n <namespace>
```

## 常见原因

- 证书确实过期。
- 新证书已签发但服务未 reload。
- Nginx/Ingress 配置仍指向旧证书。
- 系统时间错误。
- 中间证书链不完整。

## 处理建议

- 先确认线上正在使用的证书，而不是只看本地文件。
- 更新证书后执行配置检查。
- Nginx 场景先 `nginx -t`，再 `systemctl reload nginx`。
- Kubernetes 场景更新 Secret 后确认 Ingress 控制器是否重新加载。

## 高危提醒

- 不要删除旧证书后再排查，先备份。
- 不要在配置未验证时直接重启网关或 Ingress 控制器。

## 相关专题

- [安全加固与基线检查](../manual/security/HARDENING.md)
- [云网络与负载均衡排查](../manual/cloud/CLOUD-LB-TROUBLESHOOTING.md)
- [TLS 证书链不完整排查](TLS-CHAIN-INCOMPLETE.md)
