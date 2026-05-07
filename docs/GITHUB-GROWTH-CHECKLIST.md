# GitHub 热度优化清单

这个项目的优势是中文、跨平台、运维实用、覆盖国产 Linux。要获得更多 Star，核心不是堆更多命令，而是让用户在 10 秒内明白: 这个仓库能帮我快速解决命令查询和系统运维问题。

## 仓库基础设置

- 仓库名建议: `powershell-linux-command-manual` 或 `PowerShell-Linux-Command-Manual`
- Description 建议: `Windows PowerShell、Linux、银河麒麟、统信 UOS 常用命令中文速查手册`
- Topics 建议:
  - `powershell`
  - `linux`
  - `windows`
  - `kylin`
  - `uos`
  - `devops`
  - `sysadmin`
  - `command-line`
  - `cheatsheet`
  - `chinese`

## README 优化重点

- 第一屏说明项目解决什么问题。
- 给出“快速入口”，让用户不用翻 3000 行文档。
- 明确适合人群: 新手、运维、国产系统用户、跨平台开发者。
- 放出内容规划，让访问者知道项目还在维护。
- 鼓励 Issue 和 PR，降低贡献门槛。

## 内容继续扩展方向

优先补这些，因为它们更容易被搜索和收藏:

1. PowerShell 与 Bash 命令对照表
2. Linux 常见报错排查，比如端口占用、权限不足、服务启动失败
3. 国产 Linux 专区: 麒麟、UOS 的包管理、系统信息、服务管理
4. 运维应急场景: CPU 飙高、磁盘满、日志爆量、连接失败
5. 高危命令风险等级: 删除、权限、磁盘、用户、网络
6. 可复制脚本: 日志清理、端口检查、系统巡检

## 推荐目录结构

```text
.
├── README.md
├── Windows-PowerShell-Linux-Command-Manual.md
├── CONTRIBUTING.md
├── LICENSE
├── ROADMAP.md
├── CHANGELOG.md
├── SECURITY.md
├── mkdocs.yml
├── docs/
│   ├── index.md
│   ├── COMMAND-CHEATSHEET.md
│   ├── POWERSHELL-BASH-COMPARISON.md
│   ├── GITHUB-GROWTH-CHECKLIST.md
│   ├── domestic-linux/
│   └── troubleshooting/
├── scripts/
└── .github/
    ├── ISSUE_TEMPLATE/
    └── workflows/
```

后续内容变多以后，可以继续拆分:

```text
docs/
├── powershell/
├── linux/
├── kylin/
├── uos/
├── security/
└── troubleshooting/
```

## 发布节奏建议

- 第 1 周: 补齐 README、License、贡献指南、Issue 模板。
- 第 2 周: 拆出命令速查表和 PowerShell/Linux 对照表。
- 第 3 周: 增加“常见故障排查”专题。
- 第 4 周: 开启 GitHub Pages，做成在线文档站。

当前已完成:

- README 项目首页
- 命令速查表
- PowerShell 与 Bash 命令对照
- Linux 故障应急排查清单
- 银河麒麟与统信 UOS 专题
- 示例巡检脚本目录
- 贡献指南、License、Issue 模板、PR 模板
- MkDocs 文档站配置和 GitHub Pages 发布工作流

## 推广建议

- 在 README 顶部放一句明确定位，不要只写“命令手册”。
- 在掘金、CSDN、知乎、V2EX、开源中国发一篇介绍文章。
- 标题可以用: `我整理了一份 Windows PowerShell 与 Linux 中文命令速查手册`
- 每次新增一个专题就发 release，比如 `v2.1: 新增 Linux 故障排查命令`
- 将项目提交到中文开源项目集合或 awesome 列表。

## 衡量指标

- README 是否能让人 10 秒内知道项目价值
- 是否有稳定更新记录
- 是否有清晰目录和快速入口
- 是否有可复制的场景命令
- 是否方便别人提 Issue 和 PR

先让项目“看起来值得收藏”，再持续补真实场景，这是最稳的增长方式。
