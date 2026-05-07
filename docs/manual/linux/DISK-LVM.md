# Linux 磁盘、挂载与 LVM

磁盘操作风险较高。涉及分区、格式化、挂载和扩容前，必须确认设备名、挂载点、文件系统类型和备份状态。

## 查看磁盘与文件系统

```bash
# 查看块设备
lsblk

# 查看文件系统和 UUID
blkid

# 查看磁盘空间
df -h

# 查看 inode
df -i

# 查看挂载
mount
findmnt
```

## 查看目录占用

```bash
# 查看一级目录占用
du -sh /* 2>/dev/null | sort -h

# 查找大文件
find / -type f -size +500M 2>/dev/null

# 查看被进程占用的已删除文件
lsof | grep deleted
```

## 挂载与卸载

```bash
# 创建挂载目录
sudo mkdir -p /data

# 临时挂载
sudo mount /dev/sdb1 /data

# 卸载
sudo umount /data

# 查看 fstab
cat /etc/fstab
```

建议使用 UUID 写入 `/etc/fstab`:

```text
UUID=<uuid> /data ext4 defaults 0 2
```

修改后先测试:

```bash
sudo mount -a
```

## LVM 查看

```bash
# 物理卷
pvs
pvdisplay

# 卷组
vgs
vgdisplay

# 逻辑卷
lvs
lvdisplay
```

## LVM 扩容示例

风险等级: 高

```bash
# 查看当前逻辑卷
lvs

# 扩展逻辑卷
sudo lvextend -L +10G /dev/vg0/lv_data

# ext4 文件系统扩容
sudo resize2fs /dev/vg0/lv_data

# xfs 文件系统扩容
sudo xfs_growfs /data
```

## 常见问题

| 现象 | 排查 |
| --- | --- |
| 磁盘满 | `df -h`、`du -sh`、`find` |
| inode 满 | `df -i` |
| 删除文件空间不释放 | `lsof \| grep deleted` |
| 开机挂载失败 | `/etc/fstab`、`mount -a` |
| 设备名变化 | 使用 UUID 挂载 |

## 高危提醒

- `mkfs.*` 会格式化文件系统，执行前必须确认设备。
- `fdisk`、`parted` 会修改分区表，生产环境需备份。
- 不要在不了解用途时删除数据库、容器 volume、业务上传目录。

延伸案例: [磁盘空间满排查](../../cases/DISK-FULL.md)。
