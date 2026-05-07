# 开源运营手册

这份手册用于维护项目发布后的运营动作，目标是让项目更容易被搜索、收藏、引用和参与贡献。

## 当前项目入口

| 类型 | 地址 |
| --- | --- |
| GitHub 仓库 | <https://github.com/shiwenxin123/PowerShell-Linux-> |
| 在线文档 | <https://shiwenxin123.github.io/PowerShell-Linux-/> |
| 最新 Release | <https://github.com/shiwenxin123/PowerShell-Linux-/releases/tag/v2.16.0> |
| Good First Issues | <https://github.com/shiwenxin123/PowerShell-Linux-/issues?q=is%3Aissue%20is%3Aopen%20label%3A%22good%20first%20issue%22> |

## 每次发布后的检查清单

- GitHub Actions 主要工作流通过。
- GitHub Pages 可以打开。
- Release 页面包含版本亮点、推荐阅读和升级说明。
- README 顶部版本号和文档站入口有效。
- 至少保留 3 条 `good first issue`。
- CSDN、微信公众号文章中包含 GitHub、文档站和 Release 反链。

## 内容推广节奏

| 周期 | 动作 |
| --- | --- |
| 每周 | 补充 1-2 个真实故障案例，更新 `docs/cases/README.md` 索引 |
| 每两周 | 扩展 1 个巡检脚本模块或 1 个专题页 |
| 每月 | 发布 1 篇技术文章，回链 GitHub 和文档站 |
| 每个版本 | 发布 GitHub Release，并同步更新 README 与文档站首页 |

## 技术文章发布模板

建议每篇文章都包含:

- 项目解决的问题。
- 本次新增内容或案例。
- 3-5 个可复制命令片段。
- 在线文档地址。
- GitHub 仓库地址。
- Good First Issues 贡献入口。

推荐标题:

- `我整理了一份 Windows PowerShell 与 Linux 中文命令速查手册`
- `从命令速查到自动化巡检: 一个中文运维知识库的开源化实践`
- `PowerShell、Linux、Kylin、UOS 常用命令和排障案例整理`

## CSDN 发布建议

- 标题包含关键词: `PowerShell`、`Linux`、`命令手册`、`运维排障`。
- 正文前 200 字说明适合人群和项目地址。
- 代码块使用明确语言标识，比如 `bash`、`powershell`、`json`。
- 文章末尾加入:

```text
GitHub: https://github.com/shiwenxin123/PowerShell-Linux-
在线文档: https://shiwenxin123.github.io/PowerShell-Linux-/
Release: https://github.com/shiwenxin123/PowerShell-Linux-/releases/tag/v2.16.0
```

## 微信公众号发布建议

- 开头先讲“为什么整理这个项目”，避免直接堆目录。
- 中间用 4-6 个小标题讲清楚项目能力。
- 文章末尾放项目地址和在线文档。
- 如果公众号不方便放裸链接，可以放 GitHub 仓库名和文档站域名。

## Issue 运营

保持 Issue 小而清晰，适合新贡献者完成。

| 类型 | 建议规模 |
| --- | --- |
| 文档错别字/链接修复 | 10-20 分钟 |
| 新增一个排障案例 | 30-60 分钟 |
| 补充命令差异说明 | 30-60 分钟 |
| 新增脚本模块 | 1-2 小时，必要时拆成多个 Issue |

Issue 标题建议:

- `补充网关超时排查案例`
- `补充 Kylin/UOS 不同版本命令差异`
- `为巡检脚本增加 package 模块`
- `补充数据库连接池耗尽排查案例`

## SEO 与搜索曝光

- README 首屏保留项目关键词。
- 每个专题页开头用 1 段话说明适用场景。
- 文章、Release、README、文档站之间互相回链。
- 避免只写命令，尽量补充“适用系统、风险、常见错误、排查路径”。
- 标题使用用户会搜索的词，比如 `Linux 磁盘满`、`PowerShell 服务管理`、`Kubernetes DNS 异常`。

## 下一步运营重点

1. 补充网关超时、数据库连接池耗尽、消息队列连接失败案例。
2. 扩展巡检脚本 `package`、`security`、`log`、`container` 模块。
3. 将主手册附录继续迁移到专题页。
4. 给重点专题页增加“相关案例”区域。
5. 每个版本发布后同步写一篇简短技术文章。
