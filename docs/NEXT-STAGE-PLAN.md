# 下一阶段优化计划

当前项目已经具备完整的命令手册、专题文档、故障案例、巡检脚本、CI、文档站、Release 和运营资料。项目已进入“内容深度 + 工具增强 + 运营维护”阶段。

## 第一优先级: 主手册收口后的专题维护

目标: 根目录主手册只承担总导航和历史说明职责，新增内容按专题维护。

已完成:

- 补充 Kylin/UOS 厂商命令细节。
- 新增 Linux 性能调优专题，迁移内核参数、limits、I/O 调优和网络参数检查。
- 补充企业级日志管理配置样例。
- 补充跨平台工具推荐分类。
- 根目录主手册已压缩为总导航、历史说明和专题入口。
- README、FAQ、命令索引、命令速查表、迁移进度和专题入口已同步新状态。

建议继续:

1. 补充 Kylin/UOS 不同版本和授权组件差异案例。
2. 补充数据库、中间件和容器场景的性能调优对照。
3. 持续把新增案例反向链接到相关专题页。
4. 按需把历史附录中的快捷键、参考资源、排障入口整理到 FAQ 或路线页。

## 第二优先级: 增强巡检脚本

目标: 让脚本从示例变成可复用工具。

已完成:

- JSON 输出。
- 统一 Linux/Windows JSON 字段。
- 更明确的退出码。
- 示例报告。
- GitHub Actions 基础功能测试，覆盖 JSON 输出、输出文件和参数错误退出码。
- JSON Schema 文件，便于自动化平台对接和字段校验。
- `package`、`security`、`container`、`log` 模块。
- 新增模块已同步 JSON Schema、示例报告、文档说明和 GitHub Actions 基础测试。

建议继续补充:

- 更多发行版和 Windows Server 版本样例。
- containerd-only、无 systemd、最小化镜像等环境差异说明。
- 新模块字段稳定性和平台兼容测试。

## 第三优先级: 补真实生产案例

已完成:

- 新增 Kubernetes DNS 异常排查。
- 新增 Prometheus Target Down 排查。
- 新增 Grafana 无数据排查。
- 统一故障案例模板，补齐“常见原因”和“相关专题”结构。
- 新增 systemd 服务启动失败、Linux Permission denied、Docker 镜像拉取失败、Kubernetes Node NotReady、MySQL 连接数打满排查案例。
- 新增网关超时、负载均衡健康检查失败、消息队列连接失败、数据库连接池耗尽、Prometheus 告警规则误报案例。

建议新增:

- Kubernetes NetworkPolicy 拦截。
- Elasticsearch 磁盘水位。
- Loki 日志查询为空。

## 第四优先级: 文档站体验

已完成:

- 增加 FAQ 页面，集中说明查命令、使用巡检脚本、风险提示、贡献和发布流程。
- README 和文档站首页增加学习路线。
- 案例库增加按症状查找索引。
- 重点专题页增加相关案例入口。
- 新增案例和专题页之间的反向链接。
- 新增新手路线、运维值班路线、国产 Linux 路线和 Kubernetes 排障路线独立入口。
- 新增离线 PDF 发布流程。
- 新增 `PDF Export` 手动触发工作流，导出重点页面 PDF artifact。

建议优化:

- 继续检查导航在移动端和宽屏下的可读性。
- 让路线页持续沉淀“先看什么、再做什么、遇到问题去哪查”。

## 第五优先级: 开源运营

已完成:

- README 顶部增加 CI、文档站、脚本质量、敏感信息扫描和 License badges。
- 新增 `v2.16.0` Release 草案。
- 新增 Good First Issues 清单。
- 新增故障案例补充 Issue 模板。
- 发布 GitHub Release。
- 将文档站地址填入 GitHub About。
- 新增开源运营手册，沉淀 CSDN、微信公众号、Issue 和 Release 运营动作。
- 新增 v2.16.0 技术文章草稿，并更新 Good First Issues 候选池。

建议:

- 持续保持 3-5 条可领取的 `good first issue`。
- 每次新增专题或案例后同步发布技术文章或社区动态。
- 定期检查 GitHub Actions、Pages、Release、README badges 是否正常。
