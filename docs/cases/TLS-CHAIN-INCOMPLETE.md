# TLS 证书链不完整排查

## 现象

- 浏览器或客户端提示证书不受信任。
- `curl` 提示 `unable to get local issuer certificate`。
- 部分客户端正常，部分客户端失败。
- 移动端或老系统访问 HTTPS 失败。

## 快速判断

```bash
echo | openssl s_client -servername example.com -connect example.com:443 -showcerts 2>/dev/null
```

## 排查命令

```bash
# 查看线上证书链
echo | openssl s_client -servername example.com -connect example.com:443 -showcerts 2>/dev/null | openssl x509 -noout -subject -issuer

# 查看本地证书
openssl x509 -in /path/to/cert.pem -noout -subject -issuer -dates

# 查看 Nginx 证书配置
nginx -T | grep -E "ssl_certificate|ssl_certificate_key"
```

## 常见原因

- 服务端只配置了站点证书，没有配置中间证书。
- 证书文件顺序错误。
- 使用了错误的 CA bundle。
- 负载均衡、Ingress、网关仍在使用旧证书。
- 客户端信任库过旧。

## 处理建议

- 使用包含站点证书和中间证书的 fullchain 文件。
- Nginx 通常应将 `ssl_certificate` 指向 fullchain。
- 更新证书后 reload 服务，并确认线上实际证书链。
- 多层代理环境逐层确认 TLS 终止位置。

## 高危提醒

- 不要覆盖旧证书文件后直接重启，先备份。
- 不要把私钥提交到 Git 仓库或粘贴到 Issue。

## 相关专题

- [安全加固与基线检查](../manual/security/HARDENING.md)
- [云网络与负载均衡排查](../manual/cloud/CLOUD-LB-TROUBLESHOOTING.md)
- [证书过期排查](CERTIFICATE-EXPIRED.md)
