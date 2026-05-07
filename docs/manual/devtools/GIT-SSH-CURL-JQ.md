# Git、SSH、curl 与 jq

这些工具常用于开发协作、接口排查、远程登录、自动化脚本和日志分析。它们不是系统命令的边角料，而是日常排障的主力工具。

## Git 常用命令

```bash
# 查看状态
git status

# 查看分支
git branch

# 查看远程
git remote -v

# 拉取更新
git pull

# 提交
git add .
git commit -m "docs: update commands"

# 查看历史
git log --oneline --decorate -n 10

# 查看差异
git diff
git diff --staged
```

## Git 排查

```bash
# 查看当前配置
git config --list

# 查看某个文件历史
git log -- path/to/file

# 查看某次提交
git show <commit>

# 查看远程分支
git branch -r
```

常见问题:

- 没有权限 push。
- 远程地址错误。
- 本地分支落后远程。
- 冲突未解决。

## SSH key

```bash
# 生成密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 查看公钥
cat ~/.ssh/id_ed25519.pub

# 测试 GitHub SSH
ssh -T git@github.com

# 指定密钥连接
ssh -i ~/.ssh/id_ed25519 user@host
```

安全提醒:

- 不要提交私钥。
- 不要把私钥粘贴到 Issue 或聊天窗口。
- 公钥可以公开，私钥必须保密。

## curl

```bash
# 查看响应头
curl -I https://example.com

# GET 请求
curl https://example.com/api

# POST JSON
curl -X POST https://example.com/api \
  -H "Content-Type: application/json" \
  -d '{"name":"demo"}'

# 显示详细连接过程
curl -v https://example.com

# 跟随重定向
curl -L https://example.com
```

排查建议:

- 连接失败看 DNS、网络、防火墙。
- 证书失败看证书链和系统时间。
- 502/504 看代理和后端服务。

## jq

```bash
# 格式化 JSON
cat data.json | jq .

# 取字段
cat data.json | jq '.name'

# 取数组
cat data.json | jq '.items[]'

# 过滤
cat data.json | jq '.items[] | select(.status=="running")'
```

结合 curl:

```bash
curl -s https://example.com/api | jq .
```

## tar/zip

```bash
# 打包
tar -czf logs.tar.gz /var/log/app

# 解包
tar -xzf logs.tar.gz

# zip 压缩
zip -r logs.zip logs/

# unzip 解压
unzip logs.zip
```

## 常用组合

```bash
# 拉取接口 JSON 并过滤字段
curl -s https://example.com/api | jq '.data[] | {id,name,status}'

# 打包日志用于排查
tar -czf app-logs.tar.gz /var/log/app

# 查看最近提交修改了哪些文件
git show --name-only --oneline <commit>
```
