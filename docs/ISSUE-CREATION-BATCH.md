# Good First Issue 创建批次

这份清单用于维护者在 GitHub Issues 页面快速创建 3-5 条适合新贡献者领取的任务。每条任务都保持边界清晰、验收标准明确，避免一次 Issue 过大。

## 使用方式

1. 打开 GitHub 仓库 Issues 页面。
2. 点击 `New issue`。
3. 复制下面某条任务的标题和正文。
4. 添加建议标签。
5. 创建后确认任务数量保持在 3-5 条左右。

## Issue 1

标题:

```text
补充 Kylin/UOS 不同版本命令差异
```

标签:

```text
documentation, kylin, uos, good first issue
```

正文:

```markdown
## 背景

当前项目已有 Kylin/UOS 常用命令、离线安装和版本差异专题，但真实版本之间的命令差异还可以继续补充。

## 建议修改

- 更新 `docs/domestic-linux/KYLIN-UOS-COMMANDS.md` 或 `docs/domestic-linux/VERSION-DIFFERENCES.md`
- 补充至少 2 个版本差异点，例如包管理器、系统信息命令、安全中心、图形化工具或服务名称差异
- 说明命令适用的系统版本，避免写成绝对通用命令

## 验收标准

- 示例不包含真实主机名、内网 IP、账号或 Token
- 命令有适用版本说明
- 文档链接没有断链
- `scripts/check-docs.ps1` 通过
```

## Issue 2

标题:

```text
为巡检脚本新增模块补更多平台样例
```

标签:

```text
documentation, script, good first issue
```

正文:

```markdown
## 背景

巡检脚本已经支持 `package`、`security`、`container`、`log` 模块，但示例报告还可以补充更多平台差异，方便用户理解输出。

## 建议修改

- 更新 `docs/examples/` 下的示例报告，或新增脱敏示例片段
- 更新 `docs/manual/automation/HEALTH-CHECK-SCRIPTS.md`
- 可选择一个平台补充说明，例如 Ubuntu、CentOS/Rocky、Kylin/UOS、Windows Server

## 验收标准

- JSON 示例可以被 `ConvertFrom-Json` 或 `python -m json.tool` 解析
- 示例内容脱敏
- 文档说明与脚本模块名称一致
- `scripts/check-docs.ps1` 通过
```

## Issue 3

标题:

```text
补充 Kubernetes NetworkPolicy 拦截案例
```

标签:

```text
documentation, kubernetes, help wanted
```

正文:

```markdown
## 背景

案例库已有 Kubernetes DNS、Node NotReady、ImagePullBackOff 等案例，但还缺少 NetworkPolicy 导致服务不可达的排查路径。

## 建议修改

- 新增 `docs/cases/K8S-NETWORKPOLICY-BLOCKED.md`
- 更新 `docs/cases/README.md`
- 如有必要，更新 `mkdocs.yml`

建议结构:

- 现象
- 快速判断
- 排查命令
- 常见原因
- 处理建议
- 高危提醒
- 相关专题

## 验收标准

- 命令以只读排查为主
- 包含 `kubectl get networkpolicy`、`kubectl describe networkpolicy`、Service/Endpoints/Pod 标签检查
- 不包含真实集群名、命名空间或业务域名
- `scripts/check-docs.ps1` 通过
```

## Issue 4

标题:

```text
补充 Elasticsearch 磁盘水位案例
```

标签:

```text
documentation, middleware, help wanted
```

正文:

```markdown
## 背景

中间件专题已有数据库和 Elasticsearch 命令，但案例库还缺少 Elasticsearch 磁盘水位导致索引只读、分片异常或写入失败的案例。

## 建议修改

- 新增 `docs/cases/ELASTICSEARCH-DISK-WATERMARK.md`
- 更新 `docs/cases/README.md`
- 关联 `docs/manual/middleware/POSTGRES-MONGO-ELASTIC.md`

建议覆盖:

- flood stage watermark
- read_only_allow_delete
- shard allocation
- 磁盘清理和扩容风险

## 验收标准

- 包含只读查询命令和风险提醒
- 不建议直接删除索引作为默认处理方案
- 示例索引名和节点名脱敏
- `scripts/check-docs.ps1` 通过
```

## Issue 5

标题:

```text
补充 Loki 日志查询为空案例
```

标签:

```text
documentation, observability, good first issue
```

正文:

```markdown
## 背景

项目已有 Prometheus Target Down、Grafana 无数据、Prometheus 告警误报案例。Loki 查询为空也是常见可观测性问题，适合补成独立案例。

## 建议修改

- 新增 `docs/cases/LOKI-NO-LOGS.md`
- 更新 `docs/cases/README.md`
- 关联 `docs/manual/observability/LOGGING-MONITORING.md`

建议排查点:

- Promtail/Agent 是否运行
- 标签选择器是否正确
- 时间范围是否正确
- Loki ingestion 是否报错
- Grafana datasource 是否配置正确

## 验收标准

- 包含 LogQL 示例
- 包含日志采集端、Loki 服务端、Grafana 查询端三层排查
- 示例标签和业务名脱敏
- `scripts/check-docs.ps1` 通过
```
