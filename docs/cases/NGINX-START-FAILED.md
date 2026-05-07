# Nginx 启动失败排查

## 现象

- `systemctl start nginx` 失败。
- `systemctl status nginx` 显示 `failed`。
- 网站访问失败。
- 日志出现配置错误、端口占用或证书文件错误。

## 快速判断

```bash
systemctl status nginx
nginx -t
journalctl -u nginx -n 100 --no-pager
```

## 排查命令

```bash
# 检查端口占用
ss -tulnp | grep ':80\|:443'

# 查看 Nginx 配置路径
nginx -T | head

# 查看错误日志
tail -n 100 /var/log/nginx/error.log

# 检查证书文件是否存在
ls -l /path/to/cert.pem /path/to/key.pem
```

## 常见原因

- 配置文件语法错误。
- 80 或 443 端口被占用。
- 证书文件路径错误或权限不足。
- upstream 后端地址不可达。
- 配置 include 了不存在的文件。

## 处理建议

- 修改配置后先执行 `nginx -t`，通过后再 reload。
- 端口冲突时先确认占用进程，不要直接强杀。
- 证书问题先检查路径、权限和过期时间。

```bash
nginx -t
systemctl reload nginx
```

## 高危提醒

- 不要在配置未通过 `nginx -t` 时重启生产 Nginx。
- 修改 80/443 端口和证书配置前，确认回滚方案。
