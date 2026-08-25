# W11-D5 完整 RAG 闭环（2026-08-22）

> 前置：W11-D1（Loader）、D2（bge）、D3（建库）、D4（检索）。今日：拼成能答题的 RAG 应用 = RAG 问答核心。

---

## ⚠️ 环境关键结论（动手前必看）

- **DeepSeek key 可用**（`.env` 的 `DEEPSEEK_API_KEY`），`langchain_openai.ChatOpenAI` 调通。
- **LCEL 管道跑通**：`{"context": retriever|format_docs, "question": RunnablePassthrough()} | prompt | llm | StrOutputParser()`（替代已删 `RetrievalQA`）。
- `tokenizers` 并行警告**无害**，可设 `TOKENIZERS_PARALLELISM=false` 消除。
- **运行时输入**：`rag_chain.invoke(input("提示"))` 可让问题运行时自定义（替代写死问题）。

---

## 本课四件套

### ① retriever：库转检索器
`retriever = vs.as_retriever(search_kwargs={"k": 1})` 把 D3 建的 Chroma 库接进管道。

### ② llm：DeepSeek（OpenAI 格式）
`ChatOpenAI(model="deepseek-chat", api_key=os.getenv("DEEPSEEK_API_KEY"), base_url="https://api.deepseek.com", temperature=0)`。**base_url 不带 /v1**（W7 Day2 经验），**temperature=0**（稳定可复现），**key 从 .env 拿不硬编码**。

### ③ LCEL 管道（1.x 新写法）
`{"context": retriever | format_docs, "question": RunnablePassthrough()} | prompt | llm | StrOutputParser()` 串起"检索→格式化→prompt→LLM→解析"。已删的 `RetrievalQA` 不可用。

### ④ prompt 约束防幻觉
"只根据上下文回答，上下文没有就回答不知道。"——软约束，LLM 对常识有时忽略。

---

## 立即行动

### 步骤 A：手敲骨架（已落盘 `~/ai-assistant/W11_D5_skeleton.py`）
PyCharm 打开 → 改 TODO（raw_docs / k）→ 底部 Terminal 跑（消耗少量 DeepSeek token）
### 步骤 B：验两问（文档内基于文档答 / 文档外答不知道）

---

## 学员作业（已跑通 ✅）

用户手敲 D5 骨架，运行输出：
```
=== 问: 猫喜欢抓什么 ===
老鼠                          ← 基于文档答，正确
=== 问: 今天天气如何 (文档没有) ===
不知道                        ← 防幻觉正确
=== 问: 利群是什么 ===
利群是一个香烟品牌。           ← 用户自己把"利群"加进文档，基于文档正确回答
```

判定：
- 基础闭环通 ✅（退出码 0，文档内"老鼠"基于文档、文档外"不知道"防幻觉）
- **更正**：初判"利群泄漏"误判——用户手敲时改了 `raw_docs` 加了利群文档，答"香烟品牌"是基于文档的正确回答，非 RAG 问题。我之前默认 raw_docs 还是演示数据误判，已更正。

---

## 🧠 知识整合（W11-D5 核心）

1. **D5 = RAG 完整闭环**：检索（D4）+ LLM 生成 = "喂文档→基于文档答题"。
2. **retriever** = `vs.as_retriever(search_kwargs={"k": 1})` 把库转检索器。
3. **llm** = `ChatOpenAI(DeepSeek, base_url 不带 /v1, temperature=0, key 从 .env)`。
4. **LCEL 管道**替代已删 `RetrievalQA`：`{context, question} | prompt | llm | parser`。
5. **prompt 防幻觉是软约束**：LLM 对常识会忽略指令用外部知识，RAG 防幻觉是工程难题非一行代码。

---

## 下一步 W11-D6
答案溯源 + 检索质量评估：让回答标注来源 chunk（可信度关键）。
