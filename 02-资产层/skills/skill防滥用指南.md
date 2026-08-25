---
状态: ✅ 已确认
审核时间: 2026-08-19
来源: 知识点讨论
---

# Skill 防滥用指南

> 核心问题：skill 描述太模糊 → 任何相关话题都触发 → 被滥用
> 解决核心：描述写精准，触发条件写清楚

---

## 触发失控的典型症状

```
❌ skill 描述写："帮助写代码"（太宽，任何编程话题都触发）
❌ skill 描述写："处理 PDF 文件"（PDF 出现在任何地方都触发）
❌ skill 描述写："做图"（用户说"截图发我"都触发）
```

---

## 原则：描述 = 触发条件，不是功能介绍

**格式：**
```
Use this skill when [具体的触发场景]，not [它不应该触发的场景]
```

**对比：**

| ❌ 宽泛写法        | ✅ 精准写法                                        |
| ------------- | --------------------------------------------- |
| "帮助处理 PDF 文件" | "当用户明确要求上传/解析/总结 PDF 时使用，不包括聊天中附带提到 PDF"      |
| "协助写代码"       | "当用户说'帮我写一个 XX 功能'、'写个脚本来 XX'时使用，不包括问代码为什么报错" |
| "做图表"         | "当用户要求生成可视化图表、流程图时使用，不包括截图描述或排版"              |

---

## 让 skill 只在「主动调用」时才触发

**方法：在描述开头加「只在用户明确要求时才触发」**

```
Use this skill only when the user explicitly asks for [具体动作]。
Do NOT activate for general mentions, casual references, or unrelated requests.
```

**例子：**
```
Use this skill only when the user explicitly asks to create a Word document.
Do NOT activate when the user mentions "docx" in passing, in examples,
or in unrelated contexts.
```

---

## 目录命名也是防线

skill 目录名 = 隐性触发词。

| ❌ 模糊目录名 | ✅ 精准目录名 |
|-------------|-------------|
| `code/` | `pdf-reader/` |
| `doc/` | `word-doc-creator/` |
| `tool/` | `tencent-docs-manager/` |
| `image/` | `ai-image-generator/` |

越具体，越不会被误触发。

---

## Per-Tool 禁用清单

> 同步到不同工具时，告诉工具哪些 skill 不要自动加载。

| 工具              | 禁用方式                                       |
| --------------- | ------------------------------------------ |
| **OpenClaw**    | 不安装（留在知识库），需要时说"用这个 skill"                 |
| **Claude Code** | 在 skill 描述末尾加 `--DISABLED-FOR:claude-code` |
| **Codex**       | 在 skill 描述末尾加 `--DISABLED-FOR:codex`       |

**示例：**

```markdown
---
name: sliver-vibe-coding
description: ...
---

# Sliver Vibe Coding

...（正文）

---
DISABLED-FOR: openclaw, codex
REASON: 这个 skill 依赖 Codex/Claude Code 的上下文管理和工具集，OpenClaw 无法完整执行。
USE-INSTEAD: 资产层/AI编程全流程模板.md
---
```

---

## 你维护 skill 的 checklist

每次新增或同步 skill 之前，检查三项：

```
1. 描述够精准吗？
   → 能用一句话说清"什么时候用它"吗？不能就改。

2. 它不应该在什么情况下触发？
   → 想清楚反面，写进描述。

3. 这个工具真的能用这个 skill 吗？
   → Sliver 在 OpenClaw 里用不了，就要禁用。
   → PDF skill 在 Claude Code 里可能工作正常，就要保留。
```

---

## 实际例子

**skill：PDF 文档处理**

```markdown
---
name: pdf-reader
description: "Use this skill when the user explicitly asks to read, parse, 
extract text from, or summarize a PDF file. 
NOT for: casual mentions of PDF, attaching a PDF without asking to process it,
or general document discussions.
Trigger words: '帮我看这个PDF' / '上传了PDF' / '解析PDF' / '总结PDF'"
---

# PDF 处理 Skill

## ...
```

**这个描述：**
- ✅ 精准：只有在"要求处理 PDF"时才触发
- ✅ 有反面：聊天中附带 PDF 不会触发
- ✅ 有触发词：明确列出关键词

---

## 关联

- 资产层/skills/sync-skills.sh（同步脚本）
- 资产层/skills/skill防滥用指南.md（本文件）
