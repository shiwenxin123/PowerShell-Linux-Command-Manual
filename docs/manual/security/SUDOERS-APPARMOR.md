# sudoers 与 AppArmor

权限问题不要一上来使用 `chmod 777`。更好的方式是确认用户、组、sudo 权限、安全策略和应用访问路径。

## sudo 权限查看

```bash
# 查看当前用户
whoami
id

# 查看当前用户 sudo 权限
sudo -l

# 查看用户所属组
groups
```

## 编辑 sudoers

风险等级: 高

```bash
# 安全编辑 sudoers
sudo visudo

# 编辑扩展配置
sudo visudo -f /etc/sudoers.d/<name>
```

示例:

```text
# 允许 deploy 用户免密重启 nginx
deploy ALL=(root) NOPASSWD: /bin/systemctl restart nginx
```

建议:

- 使用 `visudo`，不要直接用普通编辑器改 `/etc/sudoers`。
- 命令授权尽量精确到具体命令。
- 不建议随意配置 `NOPASSWD: ALL`。

## AppArmor 状态

```bash
# 查看状态
sudo aa-status

# 查看 profile
ls /etc/apparmor.d/

# 投诉模式
sudo aa-complain <profile>

# 强制模式
sudo aa-enforce <profile>
```

## AppArmor 日志

```bash
# 查看内核日志
dmesg | grep -i apparmor

# 查看系统日志
journalctl | grep -i apparmor
```

## 常见问题

| 现象 | 排查 |
| --- | --- |
| sudo 提示无权限 | `sudo -l`、用户组、sudoers |
| 修改 sudoers 后 sudo 不可用 | 使用恢复会话修复语法 |
| 应用无法读取文件 | AppArmor/SELinux、安全中心、文件权限 |
| 容器访问挂载目录失败 | 文件权限、AppArmor profile、SELinux label |

## 高危提醒

- sudoers 语法错误可能导致管理员无法使用 sudo。
- 修改 sudoers 前保留 root 会话或准备恢复方式。
- 不要长期把安全策略切到宽松模式，只用于临时定位问题。
