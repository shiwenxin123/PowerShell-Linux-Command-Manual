# v2.16.0 Release 草案

这份草案用于发布 GitHub Release 时快速整理文案。正式发布前请先完成 [Release 检查清单](RELEASE-CHECKLIST.md)。

## 本次更新

- 主手册收口第 1 批，补充 Kylin/UOS 厂商命令、Linux 性能调优、企业日志配置和跨平台工具分类。
- 巡检脚本工具化，支持统一 JSON 输出、明确退出码、示例报告和 JSON Schema。
- 增加巡检脚本 GitHub Actions 功能测试，覆盖 Linux/Windows JSON 输出、输出文件和参数错误退出码。
- 新增 FAQ、README 学习路线、案例库按症状查找索引。
- 新增 Kubernetes DNS 异常、Prometheus Target Down、Grafana 无数据排查案例。
- README 增加 CI、文档站、脚本质量、敏感信息扫描和 License badges。
- `requirements.txt` 增加 MkDocs 相关依赖版本范围。

## 推荐阅读

- [FAQ](FAQ.md)
- [学习路线](index.md)
- [巡检脚本工具化](manual/automation/HEALTH-CHECK-SCRIPTS.md)
- [真实故障案例库](cases/README.md)
- [Linux 性能调优](manual/linux/PERFORMANCE-TUNING.md)
- [主手册迁移进度](MANUAL-MIGRATION.md)
- [Good First Issues 清单](GOOD-FIRST-ISSUES.md)

## 发布前确认

- `scripts/check-docs.ps1` 通过。
- `python -m mkdocs build --strict` 通过。
- GitHub Actions 主要工作流通过。
- GitHub About 已填写 Description、Topics 和 Website。
- 新增文件已加入 Git。

## GitHub About 建议

Description:

```text
Windows PowerShell、Linux、银河麒麟、统信 UOS 常用命令中文速查手册
```

Topics:

```text
powershell, linux, windows, kylin, uos, devops, sysadmin, command-line, cheatsheet, chinese, kubernetes, docker
```

Website:

```text
https://shiwenxin123.github.io/PowerShell-Linux-/
```
