# Linux Permission denied 排查

## 现象

- 执行命令时报 `Permission denied`。
- 应用无法读取配置、写日志、上传文件或访问挂载目录。
- 服务启动失败，日志提示没有权限访问文件、目录或 socket。
- 脚本文件存在，但无法执行。

## 快速判断

先确认当前用户、目标文件权限、属主属组和挂载参数。

```bash
whoami
id
ls -ld <path>
namei -l <path>
mount | grep " <mount-point> "
```

## 排查命令

```bash
# 查看文件和上级目录权限
ls -l <file>
namei -l <file>

# 查看 ACL
getfacl <path>

# 查看 SELinux 状态和上下文
getenforce
ls -Z <path>

# 查看 AppArmor 状态
aa-status 2>/dev/null

# 检查脚本是否有执行位
stat <script>
head -n 1 <script>

# 查看最近拒绝日志
journalctl -n 100 --no-pager | grep -i denied
```

## 常见原因

- 文件或目录属主属组不正确。
- 上级目录缺少执行权限，导致路径无法穿透。
- 脚本没有执行位，或解释器路径不存在。
- 文件系统以 `noexec`、`ro` 等参数挂载。
- SELinux 或 AppArmor 策略拒绝访问。
- 容器 volume 映射后的 UID/GID 与应用用户不一致。

## 处理建议

- 先用最小权限修复属主、属组或 ACL，不要直接全局放权。
- 脚本执行失败时优先检查 `chmod +x` 和 shebang。
- SELinux 场景先查看审计日志，再决定是否调整上下文或策略。
- 容器场景确认镜像内用户、宿主机目录 UID/GID 和 volume 权限一致。
- 生产目录变更权限前，确认应用、备份、日志轮转是否依赖原权限。

## 高危提醒

- 不要把生产目录递归改成 `chmod -R 777`。
- 不要随意关闭 SELinux 或 AppArmor 来掩盖权限问题。
- 对数据库、证书私钥、SSH key 修改权限时要特别谨慎。

## 相关专题

- [Linux 用户组与权限](../manual/linux/USERS-PERMISSIONS.md)
- [sudoers 与 AppArmor](../manual/security/SUDOERS-APPARMOR.md)
- [安全加固与基线检查](../manual/security/HARDENING.md)
