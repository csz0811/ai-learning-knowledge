 ---
tags: [W7, LLM API, DeepSeek, 结构化输出, 复习清单]
创建: 2026-08-14
更新: 2026-08-16
关联: [[00-学习路线图]] [[06-Week6-结构化输出]] [[08-Week8-多轮Streamlit]]
---

# W7｜LLM API 调用开发

> 状态：✅ 已完成（2026-08-16 闭卷 78 分通过，75-89 为通过线）
> 模式：边做项目边学——项目「AI 内容生成器」顺带覆盖了周三~周六知识点

## 一、本周学会了什么
- 拿到 API Key 并安全存储（`.env` + python-dotenv，不入库）
- 用 OpenAI 兼容 SDK 调 DeepSeek，跑通单轮 + 多轮对话
- `temperature` / `max_tokens` 调参
- 结构化输出（JSON mode + schema）
- 错误码 429 / 401 / 400 与重试策略
- 做出多类型 AI 内容生成器（CLI 版）

## 二、API Key 与供应商
### 安全存储（高频考点）
- API Key = 调用大模型的"账号钥匙"，泄露=被盗刷
- ❌ 硬编码 `api_key="sk-xxx"` 再 push GitHub → 全网可见
- ✅ 存 `.env`（写进 `.gitignore`），用 `load_dotenv()` + `os.getenv("DEEPSEEK_API_KEY")` 读取

### DeepSeek vs OpenAI（本笔记用 DeepSeek 主路径）
- DeepSeek：国内友好、便宜、OpenAI 兼容，基本不用折腾网络
- 切 DeepSeek **只改三处**：`api_key=os.getenv("DEEPSEEK_API_KEY")` + `base_url="https://api.deepseek.com"`（**不带 /v1**）+ `model="deepseek-chat"`
- ⚠️ OpenAI SDK 默认只读 `OPENAI_API_KEY` 环境变量，即使 DeepSeek key 正确，不显式传也读不到

### 环境（Mac）
```bash
mkdir ai-assistant && cd ai-assistant
python3 -m venv venv
source venv/bin/activate
pip install openai python-dotenv
```
`.env` 内容：`DEEPSEEK_API_KEY=sk-你的key`（等号前后无空格、值无引号）

## 三、API 调用代码结构
```python
from openai import OpenAI
import os
from dotenv import load_dotenv
load_dotenv()
client = OpenAI(api_key=os.getenv("DEEPSEEK_API_KEY"), base_url="https://api.deepseek.com")
resp = client.chat.completions.create(
    model="deepseek-chat",
    messages=[{"role": "user", "content": "你好"}]
)
print(resp.choices[0].message.content)
```
- 解析：`response.choices[0].message.content` 取回复文本
- 防御：包 `try/except`（网络超时/认证/限流）+ `while` 重试 + 函数封装

## 四、多轮对话（messages 三角色）
- `system`（人设/立规矩）/ `user`（用户）/ `assistant`（AI 历史回复）
- 多轮本质：每轮把**整个历史**重新发给模型（不是 AI 真记得）
- tokens 随历史**线性增长** → 越聊越贵 → 生产截断 `messages[-10:]`
- DeepSeek = 标准 OpenAI 格式，`content` 是纯字符串（**不要加 type/text 对象**）

```python
messages.append({"role": "user", "content": user_input})  # 记用户的话
reply = chat(messages)                                     # 带全历史去问
messages.append({"role": "assistant", "content": reply})  # 记 AI 的回答
```

## 五、temperature / max_tokens
- `temperature`：0=最确定（代码/翻译/事实问答）｜高 0.8~1.2=更创意（文案/诗/脑暴）。口诀「**要准用低，要活用高**」
- `max_tokens`：限制单次回复长度 → 控成本/防超时/控长度（项目用 800）
- demo：`day3_demo.py`（0.2 vs 1.2 对比"咖啡"）

## 六、结构化输出（JSON）
- **L1 文字约束**：prompt 写「用 JSON 返回，字段：标题/正文/标签」→ 模型尽量遵守，不保证
- **L2 JSON mode**：`response_format={"type":"json_object"}` → 强制合法 JSON（配 `json.loads` 解析）
- **schema**：你定义的输出结构（字段名+格式）。字段名要固定，否则 `data["字段"]` 取不到→崩。schema 管结构不管内容对错
- ⚠️ JSON 不允许注释；解析务必 `try/except json.JSONDecodeError`

## 七、错误码 + 重试策略
| 码 | 含义 | 第一步排查 |
|----|------|-----------|
| 429 | 限速/配额满 | 降频、查余额、退避重试 |
| 401 | 认证失败 | 查 Key 是否正确/过期/变量名 |
| 400 | 请求无效 | 查参数/JSON/schema |

- ❌ `while` 死循环无间隔重试 → 雪崩更被限速
- ✅ 指数退避（1s→2s→4s）+ 最大次数 + 限流即停
- 项目现状：✅ 挡 429；⚠️ 挡不住 401 / 持久 400（应直接报错而非死循环）

## 八、实战项目：AI 内容生成器
- 文件：`~/ai-assistant/content_generator.py`
- 功能：4 种类型（小红书/短视频/朋友圈/**微博(你加的)**），双输出 JSON + Markdown
- 设计：配置驱动（`CONTENT_TYPES` 字典，加类型=加项不改逻辑）；`__file__` 定位输出目录（在哪运行都不丢）；双输出（机器读 .json / 人读 .md）
- 你亲手做的：加「微博」类型；修 `\n` 转义 bug（`replace("\\n", "\n")`）
- 用法：`python content_generator.py "咖啡" 1`（1=小红书 / 2=短视频 / 3=朋友圈 / 4=微博）

## 九、踩坑永久记忆
1. **Webchat 渲染 bug**：长字符串自动折叠成 `os.get…Y")`，复制即坏 → 代码在 PyCharm 手敲，不聊天贴长代码
2. **OpenAI SDK 默认认 `OPENAI_API_KEY`**：切 DeepSeek 必须显式传 api_key / base_url / model
3. **DeepSeek 格式误导**：曾误加 type/text 字段，错；标准 OpenAI 格式 content 即纯字符串
4. **openai SDK 本地 v3.0.0**：content 列表当多模态块解析，要求 type

## 📝 复习清单（自测）
- [x] API Key 安全存储：.env + python-dotenv，不硬编码不入库
- [x] 供应商切换三处：api_key / base_url(不带/v1) / model
- [x] 单轮调用：import→messages→create→解析 choices[0].message.content
- [x] 多轮：messages 三角色 + 历史重发 + tokens 增长截断
- [x] temp/max_tokens 口诀：要准用低，要活用高
- [x] 结构化 L2：response_format json_object + json.loads + try/except
- [x] 错误码：429 限速 / 401 认证 / 400 无效；指数退避重试

> TODO(你填)：用你自己的话写一句"为什么多轮对话越聊越贵"——能讲清就真懂了。

> 🔗 返回：[[00-学习路线图]]｜[[06-Week6-结构化输出]]｜[[08-Week8-多轮Streamlit]]
