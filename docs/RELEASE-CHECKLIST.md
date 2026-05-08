# Release 检查清单

发布新版本前，建议按这个清单检查。

## 内容检查

- [ ] README 快速入口已更新
- [ ] `docs/index.md` 文档站首页已更新
- [ ] `mkdocs.yml` 导航已更新
- [ ] `CHANGELOG.md` 已记录变更
- [ ] 高危命令已标注风险
- [ ] 示例命令不包含敏感信息

## 文件检查

- [ ] Markdown 代码块已闭合
- [ ] 链接路径正确
- [ ] 脚本语法已检查
- [ ] 新增文件已加入 Git
- [ ] `requirements.txt` 版本范围仍可正常构建文档站

## 本地验证

- [ ] `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-docs.ps1` 通过
- [ ] `python -m mkdocs build --strict` 通过
- [ ] 如更新 JSON 示例或 Schema，`python -m json.tool` 校验通过

## GitHub 设置检查

- [ ] About Description 已填写
- [ ] Topics 已填写
- [ ] GitHub Pages 已启用
- [ ] Issue 模板可用
- [ ] PR 模板可用
- [ ] GitHub Actions 主要工作流已通过

## Release 准备

- [ ] 已基于 [v2.16.0 Release 草案](RELEASE-2.16-DRAFT.md) 更新发布文案
- [ ] 已确认 tag 名称和 Changelog 版本一致
- [ ] 已确认 README badges 在 GitHub 页面正常显示
- [ ] 已确认文档站首页和 FAQ 可访问
- [ ] 如发布离线 PDF，已按 [离线 PDF 发布流程](PDF-EXPORT.md) 检查附件

## 发布文案模板

```markdown
## 本次更新

- 新增 ...
- 修复 ...
- 优化 ...

## 推荐阅读

- [命令索引](COMMAND-INDEX.md)
- [常见报错排查](troubleshooting/COMMON-ERRORS.md)

欢迎 Star、Issue 和 PR。
```
