# W11-D3 bge + Chroma 建中文向量库（2026-08-22）

> 前置：W11-D1（Loader，92分）、W11-D2（bge embedding，跑通）。今日：用 bge 中文 embedding 建 Chroma 向量库 = RAG 的「索引」核心。

---

## ⚠️ 环境关键结论（动手前必看）

- **langchain-community 被 sunset**（DeprecationWarning），但当前能用，不处理。未来可能拆成 langchain-huggingface 等独立包——又一次版本漂移实证。
- **1.x 导入路径**：
  - ✅ `from langchain_chroma import Chroma`（❌ 老 `langchain.vectorstores` 已删）
  - ✅ `from langchain_text_splitters import RecursiveCharacterTextSplitter`
  - ✅ `from langchain_community.embeddings import HuggingFaceEmbeddings`（D2 验过）
- **建库必须 `embedding=emb`**：漏了默认用 OpenAI embedding，中文检索全错且**不报错**（静默错误，最害人）。
- **Warning ≠ Error**：黄牌（DeprecationWarning）程序照跑，记着以后改；红牌（Error）才阻断。这是调试基本功。

---

## 本课四件套

### ① 为什么建库
RAG 需提前把大量文档切块向量化存好，查询时直接检索。Chroma 就是存这些向量的数据库。D3 把 D1 文档 + D2 bge 接进 Chroma，形成可检索知识库。

### ② 建库入口（1.x）
```python
Chroma.from_documents(documents=docs, embedding=emb, persist_directory="./chroma_db")
```

### ③ 必须显式传 embedding=emb
Chroma 默认 OpenAI embedding（要 key、中文差）。必须传 bge 对象，否则向量空间不匹配。

### ④ 切块再存
原始文档太长直接 embed 会截断/语义混乱。用 `RecursiveCharacterTextSplitter`（chunk_size/overlap）切块再逐块 embed。

---

## 立即行动

### 步骤 A：手敲骨架（已落盘 `~/ai-assistant/W11_D3_skeleton.py`）
PyCharm 打开 → 改 `raw_docs` 为自定义中文 → 底部 Terminal 跑
### 步骤 B：验收检索命中

---

## 📝 代码骨架（已落盘，用户手敲）

`~/ai-assistant/W11_D3_skeleton.py`：
- import: langchain_community.embeddings / langchain_chroma / langchain_core.documents / langchain_text_splitters
- emb = HuggingFaceEmbeddings(model_name="BAAI/bge-small-zh")
- raw_docs = [Document(...), ...]（用户自定义三句）
- splitter = RecursiveCharacterTextSplitter(chunk_size=100, overlap=20)
- vs = Chroma.from_documents(documents=docs, embedding=emb, persist_directory="./chroma_db_d3")
- res = vs.similarity_search("猫抓什么动物", k=1)

---

## 学员作业（已跑通 ✅）

用户改 `raw_docs` 为自定义三句（含"猫猫喜欢爬窗户"），运行输出：
```
切块数: 3
检索结果: 猫猫喜欢爬窗户
```

判定：
- 切块数 3 ✅（短文本不切，3 块符合预期）
- 检索返回相关句 ✅（建库 + bge + 检索全链路工作）
- embedding=emb 传参正确 ✅（否则默认 OpenAI 向量空间，中文检索会乱/报错；正常返回中文句说明 bge 空间对了）
- 用户改 raw_docs 自己填 TODO ✅（带脑子敲）
- 返回"猫猫喜欢爬窗户"因演示数据仅该句含"猫"，命中正确（非 bug）

---

## 🧠 知识整合（W11-D3 核心）

1. **Chroma.from_documents 是 1.x 建向量库标准入口**（老 `langchain.vectorstores` 已删）。
2. **embedding=emb 必须显式传**，漏了是静默错误（最害人，不报错但检索全错）。
3. **切块再 embed**：长文档直接 embed 会截断，用 RecursiveCharacterTextSplitter（chunk_size/overlap）。
4. **1.x 导入路径**：`langchain_chroma` / `langchain_text_splitters`（不是老 `langchain.vectorstores`）。
5. **Warning ≠ Error**：sunset 是未来弃用非现在不能用；黄牌能用红牌阻断——调试基本功。

---

## 下一步 W11-D4
语义检索深化：`similarity_search` 的 `k` / `score_threshold` / `metadata` 过滤；Chroma 查询机制（查询也用建库时的 emb 变向量，同一向量空间才有效）。
