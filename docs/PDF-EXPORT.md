# 离线 PDF 发布流程

这个流程用于在发布版本时生成可离线分发的文档包。当前项目默认发布 GitHub Pages；PDF 可作为 Release 附件或内部知识库归档。

## 自动化方式

项目已提供手动触发的 GitHub Actions: `PDF Export`。

使用步骤:

1. 打开 GitHub 仓库的 Actions 页面。
2. 选择 `PDF Export` 工作流。
3. 点击 `Run workflow`。
4. 可选填写版本号，例如 `v2.16.0`。
5. 工作流完成后，在 Artifacts 中下载 `docs-pdf-<version>`。

当前自动导出页面:

- 文档站首页。
- 命令速查表。
- 运维值班路线。
- 巡检脚本工具化说明。
- 真实故障案例库。

## 手动方式

优先使用浏览器从 GitHub Pages 导出关键页面 PDF，适合手册类项目，避免引入额外构建依赖。

1. 打开文档站首页。
2. 进入需要归档的页面，例如路线页、命令速查表、巡检脚本文档或案例库。
3. 使用浏览器打印功能保存为 PDF。
4. 文件名使用版本号和页面名，例如 `v2.16.0-command-cheatsheet.pdf`。
5. 发布 Release 时将 PDF 作为附件上传。

## 建议导出页面

| 类型 | 页面 |
| --- | --- |
| 总入口 | [文档站首页](index.md)、[专题手册入口](manual/README.md) |
| 路线页 | [新手路线](routes/BEGINNER.md)、[运维值班路线](routes/OPS-ONCALL.md)、[国产 Linux 路线](routes/DOMESTIC-LINUX.md)、[Kubernetes 排障路线](routes/KUBERNETES-TROUBLESHOOTING.md) |
| 速查 | [命令速查表](COMMAND-CHEATSHEET.md)、[PowerShell/Bash 对照](POWERSHELL-BASH-COMPARISON.md) |
| 排障 | [Linux 应急排查清单](troubleshooting/LINUX-INCIDENT-CHECKLIST.md)、[真实故障案例库](cases/README.md) |
| 自动化 | [巡检脚本工具化](manual/automation/HEALTH-CHECK-SCRIPTS.md)、[JSON Schema](schema/health-check-report.schema.json) |

## Release 附件命名

```text
v2.16.0-index.pdf
v2.16.0-command-cheatsheet.pdf
v2.16.0-oncall-route.pdf
v2.16.0-health-check-scripts.pdf
```

## 发布前检查

- PDF 中不要包含本机路径、真实 IP、Token、密码或内网域名。
- 页面链接应优先指向 GitHub Pages 或仓库公开地址。
- 导出后抽查目录、代码块换行、表格宽度和中文字体显示。
- Release 说明中注明 PDF 生成版本和对应文档站地址。

## 后续可自动化方向

- 将 PDF 附件和 Release 检查清单联动。
- 增加按输入选择页面集合的导出参数。
- 增加完整离线 HTML 包 artifact。
