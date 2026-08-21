---
tags: [W11, RAG, LangChain, 复习清单, 已完成]
创建: 2026-08-14
更新: 2026-08-22
状态: ✅ 已完成
关联: [[00-学习路线图]]
---

# 🧾 W11 复习清单｜LangChain 与 RAG 实战（完整 RAG 问答系统 + bge 中文 embedding）

> 学完日期：2026-08-22。W11 把 W10 的 ChromaDB 基础升级成完整 RAG 问答应用，并换用 bge-small-zh 中文 embedding。六块技术（Loader→Embedding→建库→检索→闭环→溯源）全通，D7 画全链路流程图收官。

---

## 一、本周学习目标（已达成）

- [x] 掌握 LangChain 1.x 基本用法（包结构全拆，适配当前版本实测可跑）
- [x] 能用 LangChain + bge 构建完整 RAG 应用（Loader→Embedding→建库→检索→闭环→溯源）
- [x] 理解 RAG 防幻觉边界与答案溯源

---

## 二、每日进展（D1-D7）

### D1 DocumentLoader（评分 92）
- 内容：LangChain 1.x 包结构（langchain_community / langchain_openai / langchain_chroma），Loader 选型（PyMuPDF / pypdf / docx2txt）
- 关键：1.x 包全拆，教程老写法 import 失败；装包实测：langchain 1.3.15 + langchain-community 0.4.2 + langchain-openai 1.5.1 + langchain-chroma 1.8 + pypdf 6.16.1 + docx2txt 0.9
- 评分：92 分

### D2 bge 中文 Embedding
- 内容：`langchain_community.embeddings.HuggingFaceEmbeddings` 加载 `BAAI/bge-small-zh`（512 维）
- 关键：❌ langchain_huggingface 未装、❌ langchain.embeddings 1.x 已删；需补 sentence-transformers
- 兼容组合（固化）：torch 2.2.2 + numpy 1.26.4 + sentence-transformers 2.7.0 + transformers 4.44.2
- 验收：猫-猫咪 0.966 vs 猫-股票 0.718 ✅ 中文语义区分有效

### D3 bge 建 Chroma 库
- 内容：`Chroma.from_documents(embedding=emb)` 建库，`similarity_search` 检索
- 关键：①`from langchain_chroma import Chroma`（老 langchain.vectorstores 已删）②必须显式 `embedding=emb`（漏了静默错误：默认 OpenAI 向量空间，中文检索全错）③`persist_directory` 同名目录重复 from_documents 追加非覆盖
- 验收：切块 3、检索命中"猫猫喜欢爬窗户"、embedding=emb 传参正确
- Warning vs Error：langchain-community sunset DeprecationWarning 是黄牌非红牌，程序照跑

### D4 语义检索参数
- 内容：k / with_score / filter 三个参数
- 关键：①score_threshold 当前 langchain_chroma 版本直接报 TypeError（改用自己 if 过滤）②同名目录重复 from_documents 追加非覆盖
- 验收：4 段全对；猫 0.291 < 狗 0.530（距离小更相关）；filter 是硬约束（先按 metadata 钉死范围再语义排序）
- 改造题：k=3、filter 动物

### D5 完整 RAG 闭环
- 内容：retriever + llm(DeepSeek) + LCEL 管道（`{"context": retriever|format_docs, "question": RunnablePassthrough()} | prompt | llm | StrOutputParser()`），替代已删 RetrievalQA
- 关键：①base_url 不带 `/v1` ②temperature=0 ③key 从 .env ④LCEL import 路径 1.x 又拆包
- 验收：文档内"猫喜欢抓什么"→"老鼠"；文档外"今天天气"→"不知道"（防幻觉生效）
- ⚠️ 误判纠正：用户自己把"利群"加进文档，答"香烟品牌"是基于文档的正确回答，非 RAG 泄漏。我之前默认 raw_docs 还是演示数据误判，已更正。

### D6 答案溯源
- 内容：代码级溯源（retriever.invoke 拿 metadata → src），拆解 D5 LCEL 管道
- 关键：①D6 拆 D5 管道：retriever.invoke 单独拿 chunk + prompt|llm|parser 生成 ②检索兜底返回（问题不在库时返回最"近" chunk，溯源来源可能是假来源）③多文档带 src metadata
- 验收：利群→品牌库、猫→动物百科、天气→不知道（来源理财指南=兜底）
- RAG 边界认知：检索准 ≠ 全知，文档外答"不知道"是正确行为

### D7 RAG 流程图（收官）
- 内容：ASCII + Mermaid 双版 RAG 全链路图（离线建库 D1-D3 + 在线问答 D4-D6）
- D1-D7 全通

---

## 三、📝 复习清单

### 必背知识点（可默写）
1. LangChain 1.x 包结构：langchain_community / langchain_openai / langchain_chroma（老 langchain.xxx 已删）
2. bge：`BAAI/bge-small-zh`，512 维，HuggingFaceEmbeddings 加载
3. 建库：`Chroma.from_documents(documents=docs, embedding=emb, persist_directory=...)`——必须显式 embedding=emb
4. 检索：`similarity_search(query, k=N)` / `retriever.as_retriever(search_kwargs={"k":N, "filter":{...}})`
5. 闭环：retriever + ChatOpenAI(DeepSeek, base_url 不带/v1, temp=0) + LCEL 管道 + StrOutputParser
6. 溯源：retriever.invoke 拿 metadata → src
7. 防幻觉：prompt "不知道就说不知道"（软约束，LLM 对常识会泄漏）
8. Warning ≠ Error（DeprecationWarning 黄牌，程序照跑）

### 常见错误（能说 3 个）
1. `from langchain.embeddings import ...` 1.x 已删 → 用 langchain_community.embeddings
2. `Chroma.from_documents` 漏 `embedding=emb` → 静默错误，中文检索全错
3. `base_url="https://api.deepseek.com/v1"` → 模型不存在，应不带 /v1
4. 同名 persist_directory 重复 from_documents → 追加非覆盖
5. score_threshold 直接传 → TypeError，改自己 if 过滤

### 自测小测（5 题，口头答）
1. LangChain 1.x 的 Chroma 从哪里 import？（langchain_chroma）
2. bge 模型名和维度？（BAAI/bge-small-zh, 512）
3. 建库时漏 embedding=emb 会怎样？（静默错误，默认 OpenAI 向量空间，中文检索全错）
4. RAG 防幻觉靠什么？（prompt "不知道就说不知道"，但软约束）
5. 怎么给 RAG 回答标来源？（retriever.invoke 拿 metadata → src）

### 核心代码片段
- 建库：`vs = Chroma.from_documents(documents=docs, embedding=emb, persist_directory="./db")`
- 检索：`retriever = vs.as_retriever(search_kwargs={"k": 1, "filter": {"type": "动物"}})`
- 闭环：`rag_chain = {"context": retriever | format_docs, "question": RunnablePassthrough()} | prompt | llm | StrOutputParser()`
- 溯源：`retrieved = retriever.invoke(q); sources = [d.metadata["src"] for d in retrieved]`

### 关联双链
- [[00-学习路线图]]（总入口）
- [[10-Week10-向量库]]（W10 ChromaDB 基础，W11 进阶）
- [[12-Week12-FAQ机器人]]（W11 RAG 闭环直接复用，W12 项目期）

---

## 四、项目衔接小节（W11 起新增）

本周 RAG 闭环是 W12 FAQ 机器人地基，三件事衔接：

1. **Loader 选型**：PyMuPDF（PDF）/ pypdf（简单 PDF）/ docx2txt（Word）——W12 直播话术 / 竞品文档用 PyMuPDF
2. **中文 embedding**：bge-small-zh 比 MiniLM 中文强，W12 继续用 bge
3. **检索质量**：k / filter / score 调参 + 溯源，W12 FAQ 需高召回（直播弹幕快速匹配知识库）

---

## 五、协作中枢建议清单（标待拍板）

- [ ] W11 周总已收官，D5/D6/D7 每日文件待安全策略恢复后落档（要点已在聊天，不丢）
- [ ] 留言板使用说明.md 补"学习期小舟只读、不进场"写死条目
- [ ] W12 项目期：提供业务需求 + 原始文档（Markdown/PDF/TXT 最稳）+ 约束

> 🔗 返回：[[00-学习路线图]]｜[[10-Week10-向量库]]｜[[12-Week12-FAQ机器人]]
