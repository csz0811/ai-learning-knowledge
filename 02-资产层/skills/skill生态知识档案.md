# Skill 生态知识档案（B 类：不装本体，记知识）

> 来源：Vibe Coding 雷达（https://radar.lyihub.com/）必装 Skill 栏，数据截至 2026-08-21 更新
> 评估人：小舟 | 日期：2026-08-27 | 录入拍板：用户（2026-08-27 三件事拍板）
> 原则：**本体装工具链，知识进知识库**——skill 可能被删/换工具，知识档案永久可查
> 配套：`02-资产层/skills/_skill登记表.md`（全量登记）· `skill防滥用指南.md`（写 skill 描述规则）

---

## 为什么建这份档案

从 Vibe Coding 雷达站筛出的 5 项「值得记知识但不装本体」的资源。它们不是「要装的 skill」，而是**skill 生态的知识源**：教我们 skill 机制怎么运作、项目怎么规划、到哪里找好 skill。装 skill 是需求驱动的，但这些知识是长期资产。

---

## 一、OpenAI Skills Catalog（openai/skills）

| 项 | 内容 |
|---|---|
| 是什么 | OpenAI 官方的 skills 机制与示例集合，Codex 的 skill 生态源 |
| 来源 | GitHub: openai/skills |
| 记什么 | Codex 官方 skill 机制：skill 怎么装、怎么触发、怎么组合、目录结构约定 |
| 怎么用 | 以后给 Codex 配 skill 时，先查官方目录看有没有现成范式，不自己造轮子 |
| 与我们关系 | 我们的工具链里 Codex 是写码执行者（2026-08-25 进场），它的 skill 规范以官方为准 |

## 二、Anthropic Skills（anthropics/skills）

| 项 | 内容 |
|---|---|
| 是什么 | Anthropic 官方的 skills 机制与示例（Claude 系），skill 写法的另一官方范式 |
| 来源 | GitHub: anthropics/skills |
| 记什么 | Skill 标准写法（frontmatter 格式、触发条件、NOT-for 反例）、跨工具复用思路 |
| 怎么用 | 两份官方目录对照读，提炼「skill 怎么写才规范」的通用标准，用于我们自己写 skill |
| 与我们关系 | 知识库结构说明第六节的「触发条件写法」就源自这类官方范式（Use when / NOT for） |

## 三、Superpowers（obra/superpowers）

| 项 | 内容 |
|---|---|
| 是什么 | 给 AI 的「规划-执行-复盘」方法论增强包（网站标称 275k⭐），把项目推进方法做成 skill |
| 来源 | GitHub: obra/superpowers |
| 记什么 | 它的核心思路：让 AI 不只「回答问题」，而是按「先规划 → 再执行 → 后复盘」推进复杂任务 |
| 怎么用 | 与我们已有的三步 gate / 变更记录四问 / 脚手架练法是同一家族的方法论，可对照学习、互补 |
| 与我们关系 | 不装本体（避免方法论打架）；我们的项目流程已经落地在个人工作台项目的文档里 |

## 四、vibe-coding-cn 教程仓（tukuaiai）

| 项 | 内容 |
|---|---|
| 是什么 | 中文 Vibe Coding 系统教程仓库：Prompt / Skill / 上下文 / 质量门禁四件套 |
| 来源 | GitHub: tukuaiai/vibe-coding-cn |
| 记什么 | Vibe Coding 的系统化方法论，尤其「质量门禁」与我们「验收标准」「审码」同频 |
| 怎么用 | 作为信源评估候选；做项目时若需要 Vibe Coding 方法论参考，先读此仓 |
| 与我们关系 | 知识库 `03-方法论/VibeCoding工作流.md` 可与此仓对照补充 |

## 五、Vibe Coding 雷达站（radar.lyihub.com）

| 项 | 内容 |
|---|---|
| 是什么 | 每周五更新的项目 + skill 榜单网站（新手向，分必装 Skill/好用/热门等栏目） |
| 来源 | https://radar.lyihub.com/（注意：动态页可能被反爬，部分内容抓不到，需人工辅助确认） |
| 记什么 | 作为「每周信源评估」的候选信源之一：每周扫一眼榜单，把新 skill/项目筛一遍 |
| 怎么用 | 每周日信源评估时访问；评估结果记入小舟周报，拍板后按需入库 |
| 与我们关系 | 本档案的母源；2026-08-27 已完成首次评估（见 skill评估登记表） |

---

## 命名防混淆（重要）

「个人 AI 工作台」目前有三个同名不同义的东西，任何人读到相关词先确认指哪个：

| 名称 | 是什么 | 在哪 |
|---|---|---|
| 个人 AI 工作台（规划） | OpenClaw 系的 AI 能力控制中心规划（2026-08-19） | 知识库 `01-项目库/个人AI工作台/` |
| 个人 AI 工作台（雷达站产品） | 「聊天+文件问答+网页总结」的 AI 对话中枢产品（好用栏 #1） | radar.lyihub.com，仅参考不照搬 |
| 个人工作台（练手项目） | 三抽屉效率工具：收件箱/任务板/素材库 | `D:\workbody\2026-08-19-13-35-10\personal-workbench\` |

## 维护说明

- 新增 skill 生态知识源：先过知识库结构说明第五节「新增知识入库治理规则」（讨论辨析 → 用户拍板 → 归类确认 → 蒸馏入库）
- 装 skill 本体前：必须先过 SkillSpector 扫描（见 `_skill登记表.md` 中 SkillSpector 条目）
