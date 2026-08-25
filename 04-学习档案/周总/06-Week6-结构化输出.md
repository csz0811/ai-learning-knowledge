---
tags: [W6, AI基础, 复习清单]
创建: 2026-08-14
关联: [[00-学习路线图]]
---

# Week 6 · 结构化 Prompt + JSON 输出

tags: #W6 #阶段2 #工具

## 学习目标
- Markdown 分模块输出（给人看）
- JSON Schema 输出（给程序读）
- 综合运用角色/Few-shot/CoT

## 核心知识点
- Markdown：直接在 Prompt 说"用 ## 分模块 / 表格 / 列表"；表格分隔线 `---` 非 `#`
- JSON：`response_format={"type":"json_schema","json_schema":{"name":"x","schema":schema}}` + `json.loads()`
- Schema 字段 = 模型【输出】的结果，不是输入
- JSON 不允许注释

## 我的易错点（来自测评，贯穿根因）
- **Schema 字段写成输入信息**（非详情页/分析结果输出）→ 反复栽，周四才通
- JSON 里带 `←` 注释 → 非法 JSON
- 表格分隔线记成 `#`
- Markdown 与 JSON 混用自相矛盾
- `response_format` 只写一层 schema，漏 json_schema 两层

## 测评记录
- 周一 55🔧 / 周二 55🔧 / 周三 85✅(补透) / 周四 90🌟 / 周五 77✅(模板库)
- 优化版模板库已上传腾讯文档 + 本地 [[02-资产层/模板库/Prompt模板库]]

## 链接
- 返回 [[00-学习路线图]]
- 模板 [[02-资产层/模板库/Prompt模板库]]

---

## 🧠 知识整合（结构化输出体系）

### 本周在 AI 学习路线图中的位置
- **阶段2 (W5-6)**：Prompt 工程 ← 当前 W6
- 承前：W5 基础 Prompt；启后：W7 API 调用（JSON 作为数据格式）

### 核心概念深层理解

#### 两种输出场景对比
| 输出目标 | 格式 | 工具 |
|:---|:---|:---|
| 给人看 | Markdown 分模块 | 直接 Prompt 约束 |
| 程序读 | JSON Schema | `response_format` |
| 两者都要 | 先 JSON，后文字说明 | 结合使用 |

#### Markdown 分模块（给人读）
```python
prompt = f"""
请为「{{product}}」写一篇产品介绍，用以下格式：

## 产品名称
{{product}}

## 核心卖点
（3个要点，用 • 分隔）

## 适用人群
（1-2句话描述）

---
（分隔线是3个减号，不是#）
"""
```
**分隔线必须是 `---`**，不是 `#`，不是 `***`

#### JSON Schema（给程序读，W6 核心）
```python
schema = {
    "type": "object",
    "properties": {
        "sentiment": {
            "type": "string",
            "enum": ["positive", "negative", "neutral"]
        },
        "reason": {
            "type": "string"
        }
    },
    "required": ["sentiment", "reason"],
    "additionalProperties": False
}

response_format = {
    "type": "json_schema",
    "json_schema": {
        "name": "sentiment_analysis",
        "schema": schema
    }
}
```

#### JSON Schema 五大铁律
| 规则 | 含义 | 示例 |
|:---|:---|:---|
| `type` | 字段数据类型 | `"type": "string"` |
| `enum` | 限定可选值 | `"enum": ["pos","neg","neu"]` |
| `required` | 输出必须包含的字段 | `"required": ["sentiment"]` |
| `additionalProperties: false` | 禁止额外字段 | 严格校验 |
| 字段=输出描述 | Schema 描述的是模型**输出**，不是用户输入 | `"reason": 模型给出的理由` |

#### 格式选择决策树
```
输出给谁看？
├── 人类 → Markdown（直接 Prompt 约束）
└── 程序 → JSON Schema（response_format）
```

### W6 知识在 RAG/Agent 体系中的潜在应用
| W6 知识 | RAG/Agent 应用 |
|:---|:---|
| JSON Schema | RAG 检索结果的结构化摘要（用 JSON 返回命中片段+距离） |
| Markdown 分模块 | Agent 输出行动计划、决策理由的结构化呈现 |
| 双重输出 | RAG 回答既要有程序读的 JSON 摘要，也要有给人看的总结 |

### 最重要的踩坑教训
1. **Schema 字段 = 模型输出，不是用户输入**：把 `comment`（用户输入）当成 Schema 字段是 W6 最常见错误，反复出现
2. **JSON 不能写注释**：`//` 或 `/* */` 都会导致非法 JSON，模型输出的 JSON 必须是纯数据

---

---

# 🧾 W6 复习清单｜结构化 Prompt 与 JSON 输出

> 📚 考试形式：口头/默写，10 分钟自检
> ⏱️ 推荐时长：20 分钟

---

## 一、结构化 Prompt（Markdown 分模块输出）

- [ ] Markdown 分隔线用 `---`（不是 `#`，不是 `***`，至少 3 个减号）
- [ ] 分模块场景：**给人读**的报告/摘要/详情页
- [ ] 能写出完整的 Markdown 分模块 Prompt
- [ ] 模块之间互斥，不重复（如「卖点」和「核心卖点」不能重叠）

---

## 二、JSON Schema 输出（⚠️ W6 核心，期末必考）

### 基础概念
- [ ] JSON Schema 是一种**描述 JSON 数据结构**的语言
- [ ] 场景：**程序读取 / API 返回 / 结构化数据提取**

### 五大铁律（必须背熟）
- [ ] ① `type`：定义字段数据类型（`string` / `number` / `boolean` / `array` / `object`）
- [ ] ② `enum`：限定可选值（如 `["positive","negative","neutral"]`）
- [ ] ③ `required`：表示输出时**必须包含**的字段（数组形式）
- [ ] ④ `additionalProperties: false`：**禁止**额外字段（严格校验）
- [ ] ⑤ 每字段必须写 `type`，用 `enum` 限定可选值

### ⚠️ 最核心的一条
- [ ] **Schema 字段 = 模型输出，不是用户输入**
  - 好例子：`"sentiment": {"type": "string", "enum": ["positive","negative","neutral"]}`
  - 错例子：`"comment": {"type": "string"}`（comment 是用户输入，不是模型输出）

---

## 三、调用 LLM 的两层结构

- [ ] 第一层：`messages`（对话内容：`role` + `content`）
- [ ] 第二层：`response_format`（输出格式控制）
- [ ] 完整调用结构：`response_format={"type":"json_schema","json_schema":{"name":"x","schema":schema}}`
- [ ] API Key 是认证参数，**不是**调用结构的一部分

---

## 四、格式选择决策树

- [ ] **给人看** → Markdown 分模块输出
- [ ] **程序处理** → JSON Schema 输出
- [ ] **两者都要** → 先 JSON（或 Markdown），再追加说明文字

---

## 五、常见坑点

- [ ] JSON **不能写注释**（`//` 或 `/* */` 都会导致非法 JSON）
- [ ] 字段之间缺逗号 → 非法 JSON
- [ ] Schema 写成输入字段（不是输出字段）→ 本周最常见错误
- [ ] `response_format` 写错两层结构 → 模型不按 JSON 输出

---

## 六、模板库速查

| 模板 | 触发句/结构 |
|---|---|
| 角色设定 | 角色 + 任务 + 约束 |
| Few-shot | 任务说明 + 示例(输入→输出) + **新输入放最后** |
| CoT | `"Let's think step by step"` 或 `"请一步一步思考："` |
| Markdown | `---` 分隔线，多个文字模块 |
| JSON Schema | `response_format` 两层 + `type`/`enum`/`required`/`additionalProperties:false` |

---

## 📝 自测小测（口头答）

1. JSON Schema 的 `required` 数组表示什么？
2. `"additionalProperties": false` 的作用是什么？
3. `response_format` 中 `schema` 是输入还是输出描述？
4. Markdown 分隔线用什么？JSON 里能写注释吗？
5. 什么时候选 Markdown，什么时候选 JSON Schema？

**答案**：① 输出时必须包含的字段 ② 禁止额外字段，严格校验 ③ 输出格式描述（模型应该输出的形状） ④ `---`；不能 ⑤ 人读→Markdown，程序读→JSON Schema

---

> 🔗 返回：[[00-学习路线图]]｜[[05-Week5-Prompt基础]]｜[[07-Week7-API调用]]