# Keepalived 高可用

Keepalived 常用于通过 VRRP 提供虚拟 IP，实现主备切换。生产环境配置前要确认网卡名、VIP、路由、安全组和健康检查脚本。

## 安装

```bash
# Debian/Ubuntu/UOS 兼容环境
sudo apt install keepalived

# RPM/YUM 兼容环境
sudo yum install keepalived
```

## 主配置文件

```bash
sudo vi /etc/keepalived/keepalived.conf
```

## 主节点示例

```text
global_defs {
    router_id LVS_MASTER
    enable_script_security
    script_user root
}

vrrp_script check_nginx {
    script "/etc/keepalived/check_nginx.sh"
    interval 2
    weight -20
    fall 3
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.1.200/24 dev eth0 label eth0:0
    }
    track_script {
        check_nginx
    }
    notify_master "/etc/keepalived/notify.sh master"
    notify_backup "/etc/keepalived/notify.sh backup"
    notify_fault "/etc/keepalived/notify.sh fault"
}
```

## 备用节点示例

```text
global_defs {
    router_id LVS_BACKUP
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.1.200/24 dev eth0 label eth0:0
    }
    track_script {
        check_nginx
    }
}
```

## 健康检查脚本

```bash
sudo tee /etc/keepalived/check_nginx.sh >/dev/null <<'EOF'
#!/bin/bash
if ! curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1/health | grep -q "200"; then
    exit 1
fi
exit 0
EOF

sudo chmod +x /etc/keepalived/check_nginx.sh
```

## 通知脚本

```bash
sudo tee /etc/keepalived/notify.sh >/dev/null <<'EOF'
#!/bin/bash
TYPE=$1
NAME=$2
STATE=$3
DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "$DATE - $TYPE - $NAME - $STATE" >> /var/log/keepalived-notify.log
EOF

sudo chmod +x /etc/keepalived/notify.sh
```

## 服务管理

```bash
sudo systemctl enable keepalived
sudo systemctl start keepalived
systemctl status keepalived

# 查看 VIP
ip addr show eth0

# 查看日志
journalctl -u keepalived -f
```

## 排查要点

- 主备节点 `virtual_router_id` 必须一致。
- 主备节点优先级应不同。
- VIP 不能与现有 IP 冲突。
- 网卡名必须和实际环境一致。
- 云环境可能需要在控制台允许 VIP 或配置高可用虚拟 IP。
- 健康检查脚本必须可执行，且退出码正确。

## 高危提醒

- 切换 VIP 会影响业务入口，建议在维护窗口测试。
- 修改 VRRP 配置前备份 `/etc/keepalived/keepalived.conf`。
- 不要在未确认云平台支持的情况下直接使用传统 VIP 漂移方案。
