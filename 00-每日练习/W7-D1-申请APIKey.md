---
tags: [W7, 每日练习, API Key, 环境]
日期: 2026-08-15
关联: [[07-Week7-API调用]] [[06-Week6-结构化输出]]
---

# W7-D1 申请 API Key + 环境准备

## 今日目标
拿到一个可用的 LLM API Key，并安全存到 `.env` 文件，顺便把开发环境搭好。

## 一、本周总览（第7周：API Key 获取 + 单轮调用）

| 日期 | 学习内容 | 立即行动 |
|------|----------|----------|
| 周一 | API Key 获取 + SDK 安装 | 申请 Key，存到 `.env` |
| 周二 | OpenAI SDK 基础调用 | 运行 Hello World |
| 周三 | messages 结构（system/user/assistant） | 给 AI 设定"专业律师"角色 |
| 周四 | temperature + max_tokens 参数 | 对比不同参数效果 |
| 周五 | 结构化 Prompt 优化 API 输出 | Prompt 让 AI 输出 JSON |
| 周六 | 用 Prompt 工程优化 AI 输出 | 结合阶段2技巧 |
| 周日 | 复习 + API 错误码 | 故意输错 Key 看报错 |

> 本周目标：拿到 API Key，写出**第一个能真正收到 AI 回复**的程序。

## 二、核心概念：什么是 API Key
- API Key 是调用大模型服务的"账号钥匙"，服务端用它识别你是谁、从你账户扣费。
- 泄露 = 别人用你的钱、甚至被用来干坏事 → **必须保密**。

## 三、为什么不能硬编码 / 上传 GitHub（高频考点）
- 把 `api_key="sk-xxx"` 写死在代码里再 `push` 到 GitHub → 全网可见，盗刷机器人几分钟内就扫走。
- 正确做法：Key 存到本地 `.env` 文件（不入库），用 `python-dotenv` 读取；`.env` 写进 `.gitignore`。

## 四、OpenAI 还是 DeepSeek？（给你个建议）
- **DeepSeek（推荐，国内友好）**：同 OpenAI 兼容接口、超便宜、基本不用折腾网络，几块钱能玩很久。
- **OpenAI**：生态最全，但需绑卡、国内访问常要网络环境。
- 本笔记两种都给代码，二选一即可；下面的 Hello World 会以 DeepSeek 为主路径演示。

## 五、申请步骤
### 方案A：DeepSeek（推荐）
1. 打开 https://platform.deepseek.com
2. 注册登录 → 右上角「API Keys」→ 创建 Key → 复制保存
3. 充一点钱（很便宜，几块钱够玩很久）

### 方案B：OpenAI
1. https://platform.openai.com → API Keys → Create
2. 绑定信用卡；国内访问可能需要网络环境

## 六、环境准备（Mac / Linux）
> ⚠️ 教程原文是 Windows 的 `.\venv\Scripts\activate`，你是 Mac，要用下面这行。

```bash
mkdir ai-assistant && cd ai-assistant
python3 -m venv venv
source venv/bin/activate
pip install openai python-dotenv
```

`.env` 文件内容（放在 `ai-assistant/` 目录下，**不要**提交 GitHub）：
```
DEEPSEEK_API_KEY=sk-你的key
```
或 OpenAI：
```
OPENAI_API_KEY=sk-你的key
```

## 七、立即行动（周一）
- [ ] 申请到一个 API Key（DeepSeek 或 OpenAI）
- [ ] 创建 `ai-assistant` 项目目录 + venv
- [ ] 安装 `openai` + `python-dotenv`
- [ ] 新建 `.env` 写入 Key（确认不进 Git）

完成后告诉我，我们进入**周二：Hello World 调用**（那时会有能跑、能给我评分的代码）。

---

## ✅ W7-D1 完成记录（2026-08-15 凌晨）

### 跑通成果
- venv 激活 → `(venv)` 前缀出现
- `.env` 手敲：`DEEPSEEK_API_KEY=sk-f23186f3...14f6`（等号前后无空格、值无引号）
- `app.py` 手敲：8 行最小版跑通 → "你好呀！很高兴见到你！"
- 进阶版（try/except + while + 函数封装）跑通 → API 概念解释输出

### 踩坑血泪（永久记忆）
1. **Webchat 渲染 bug**：长字符串自动折叠成 `os.get…Y")` —— 代码复制即坏
2. **解法**：所有代码在 PyCharm 手敲，**不在聊天里贴长代码**
3. **OpenAI SDK 默认认 `OPENAI_API_KEY`**，切 DeepSeek 必须显式传 `api_key=os.getenv("DEEPSEEK_API_KEY")` + `base_url="https://api.deepseek.com"`

### Day2 预习
- 多轮对话：`messages=[{role, content}, ...]`
- 三种角色：`system`（人设）/ `user`（用户）/ `assistant`（AI 历史回复）

---

## ✅ W7-D2 完成记录（2026-08-15 凌晨）

### 主题：多轮对话 + messages 数组

### 跑通成果
- 交互式循环聊天跑通（`while True` + `input()` + 持续 append）
- 输出证明 DeepSeek 多轮记忆正常（"再翻译"能关联到前文"早上好"）

### 核心代码逻辑（四行精华）
```python
messages.append({"role": "user", "content": user_input})   # 1. 记用户的话
reply = chat(messages)                                      # 2. 带全历史去问
messages.append({"role": "assistant", "content": reply})    # 3. 记AI的回答
print("AI:", reply)                                         # 4. 显示
```

### 关键知识点（必背）
1. **messages 三角色**：`system`(立规矩/人设) / `user`(用户) / `assistant`(AI历史回复)
2. **多轮记忆本质**：不是 AI 真记得，是每轮都把整个历史重新发给模型
3. **tokens 随历史线性增长** → 越聊越贵 → 生产需截断(`messages[-10:]`)或设上限
4. **DeepSeek = 标准 OpenAI 格式**：`content` 是纯字符串，不需要 `type`/`text` 对象

### 踩坑血泪（永久记忆）
1. **我误导加了 type/text 字段** → 错！Day1 的 `content:"你好"` 纯字符串已成功，DeepSeek 就是标准格式
2. **真 bug**：`def chat(user_msg)` 只收字符串，却 `chat(messages)` 传了整个列表 → content 变列表 → SDK(v3)当多模态块要 type → 报 `missing field 'type'`。修复：函数改收 `messages` 数组直接透传
3. **openai SDK 版本 = v3.0.0**（本地），v3 把 content 列表当多模态内容块解析

### Day3 预习
- `temperature`：创造力/随机度（低=稳，高=跳）
- `max_tokens`：回答最大长度

---

## ✅ W7-D3 + 项目启动（2026-08-15 凌晨）

### Day3 调参实测
- `temperature` 0.2(稳) vs 1.2(跳)：同 prompt 输出明显不同
- `max_tokens`：限制回答长度，生产必设防烧钱
- demo 文件：`day3_demo.py`（已写入 ~/ai-assistant/）

### 🚀 项目「AI 内容生成器」启动并跑通
- 主程序：`~/ai-assistant/content_generator.py`
- 运行：`python content_generator.py "夏季防晒"` 或交互输入
- 输出：`outputs/<话题>.json`（结构化：标题/钩子开头/正文/标签）

### 关键技术点（项目必备）
1. **DeepSeek 实测支持 `response_format={"type":"json_object"}`**（JSON模式，已跑通验证）
2. **结构化输出三件套**：SYSTEM_PROMPT 定 schema + json mode + `json.loads()` 解析
3. **健壮解析**：`json.JSONDecodeError` 单独捕获→重试；通用 Exception 也重试
4. **参数**：文案类用 `temperature=0.8`（创意）、`max_tokens=800`（控长）
5. **CLI 用法**：`sys.argv[1]` 取话题，无参则 `input()` 交互

### 加速成果
- 用一个项目覆盖了 W7 周三~周六：temp/max_tokens、JSON结构化输出、Prompt工程、错误码处理
- 剩余：W7 周日总复习（错误码 429/401/400 对照表）+ 申请API Key 流程回顾

---

## 项目增强：多类型菜单（接上条）
- `content_generator.py` 升级为 `CONTENT_TYPES` 字典：3 种类型各一套 system prompt + JSON schema
- 用法：`python content_generator.py "话题"`（交互选）/ `"话题" 1`(小红书) / `2`(短视频) / `3`(朋友圈)
- 文件命名：`outputs/{类型名}_{话题}.json`
- 设计点：**配置驱动**（加类型=加字典项，不改逻辑）；**Prompt工程=不同场景不同schema**
- 实测：短视频脚本"减肥"跑通，存到 `ai-assistant/outputs/短视频脚本_减肥.json`

---

## 项目增强：Markdown 导出（接上条，A 选项）
- `content_generator.py` 新增 `render_markdown()`：台词→有序列表、标签→`#话题`、其他字段→`## 标题`分段
- 输出双文件：`outputs/{类型}_{话题}.json` + 同名 `.md`
- 实测：小红书文案"咖啡" → `小红书文案_咖啡.md` 排版正常（标题/正文/标签可读）
- 项目现已"可交付"：结构化数据 + 人类可读文案双产出
