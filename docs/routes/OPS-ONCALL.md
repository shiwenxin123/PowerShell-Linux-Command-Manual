# 运维值班路线

这条路线适合值班、应急响应和线上故障初查。核心原则是先保留现场，再做低风险判断，最后按影响面执行修复。

## 排查顺序

| 阶段 | 目标 | 推荐文档 |
| --- | --- | --- |
| 1. 快速确认影响面 | 判断是主机、网络、应用、数据库还是集群问题 | [Linux 应急排查清单](../troubleshooting/LINUX-INCIDENT-CHECKLIST.md) |
| 2. 按错误信息定位 | 根据报错快速进入对应案例 | [常见报错排查](../troubleshooting/COMMON-ERRORS.md) |
| 3. 查真实案例 | 按现象复用排查路径 | [真实故障案例库](../cases/README.md) |
| 4. 看专题命令 | 对照网络、磁盘、日志、安全专题深入排查 | [专题手册入口](../manual/README.md) |
| 5. 控制变更风险 | 执行删除、重启、权限变更前确认风险 | [命令风险等级](../security/RISK-LEVELS.md) |

## 值班常用入口

| 现象 | 优先文档 |
| --- | --- |
| 机器变慢、CPU 高 | [CPU 飙高排查](../cases/CPU-HIGH.md)、[Linux 性能调优](../manual/linux/PERFORMANCE-TUNING.md) |
| 磁盘写入失败 | [磁盘空间满排查](../cases/DISK-FULL.md)、[Linux 磁盘与 LVM](../manual/linux/DISK-LVM.md) |
| 服务起不来 | [systemd 服务启动失败](../cases/SYSTEMD-SERVICE-FAILED.md)、[端口被占用](../cases/PORT-IN-USE.md) |
| 页面 502/504 | [Nginx 502/504 排查](../cases/NGINX-502-504.md)、[云负载均衡排查](../manual/cloud/CLOUD-LB-TROUBLESHOOTING.md) |
| SSH 登录失败 | [SSH 连接失败排查](../cases/SSH-CONNECTION-FAILED.md)、[Linux 网络排查](../manual/linux/NETWORK.md) |
| 监控无数据 | [Prometheus Target Down](../cases/PROMETHEUS-TARGET-DOWN.md)、[Grafana 无数据](../cases/GRAFANA-NO-DATA.md) |

## 值班前检查

```bash
hostname
uptime
date
df -h
free -h
ss -tulnp
journalctl -p err -n 50 --no-pager
```

## 安全边界

- 不要直接执行批量删除、递归权限修改、数据库修复、节点重启。
- 先截图或保存日志，再做变更。
- 对生产环境先确认备份、回滚方式、维护窗口和通知范围。

## 下一步

- [真实故障案例库](../cases/README.md)
- [巡检脚本工具化](../manual/automation/HEALTH-CHECK-SCRIPTS.md)
- [开源运营手册](../OPEN-SOURCE-OPERATIONS.md)
