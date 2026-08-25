---
状态: ✅ 已完成
时间: 2026-08-18
标签: [W10, RAG, ChromaDB, PyMuPDF, 语义搜索, 中文embedding局限]
---

# W10-D5+D6｜PDF 切片入库 + 语义搜索（合并记录）

> D5 = 跑通完整 pipeline（PDF→切块→向量库→查询）
> D6 = 深化语义搜索（多 query / 距离阈值 / metadata 过滤）

---

## 一、知识整合（5 条核心）

### 1. RAG 的「Retrieval」= 4 步链路
```
PDF/文档 → 读取 → 切块(chunk) → embedding(向量化) → 存入向量库
                                                    ↓
用户问题 → embedding → 与库内所有向量算距离 → 取 top-k
```
**关键认识**：检索阶段**完全不经过 LLM**，纯靠向量相似度。

### 2. chunk_size 不是越大越好
| chunk_size | 块数（430字） | 召回质量 |
|:---|:---|:---|
| 100 / overlap 20 | 6 块 | 每块语义破碎，top-1 集中 |
| **200 / overlap 30**（采用） | 3 块 | 块语义较完整，但**样本太少** |

**真实工程值**：生产用 500-1000，文档至少 5000+ 字才有意义。

### 3. 距离阈值经验值
- ChromaDB 默认 **L2 距离**（越小越相似）
- 距离 < 1.0 → 真相关 ✅
- 距离 1.0-1.3 → "最不烂"的块
- 距离 > 1.3 → 完全不相关
- **本次 D5 query="python" 距离 1.791**：因为 query 是英文、库是中文 → 跨语言降级

### 4. 「最相似 ≠ 相关」是 RAG 死结
向量只认"语义距离"，不认"事实匹配"。库里没答案时，会**硬返回"最靠近"的块**——
所以**检索质量决定 RAG 天花板**（呼应 D1 的"减幻觉"承诺）。

### 5. metadata 过滤的 where 语法坑
```python
# ❌ 错：ChromaDB 0.4.24 不支持并列字段
where = {"来源": "xx.pdf", "块编号": {"$gte": 2}}

# ✅ 对：必须用 $and / $or 嵌套
where = {
    "$and": [
        {"来源": "xx.pdf"},
        {"块编号": {"$gte": 2}}
    ]
}
```

---

## 二、D5 Pipeline 代码骨架（3 个填的空）

```python
# 第 1 步：读取 PDF
PDF_PATH = "/Users/hechengfajituan/ai-assistant/test_zh.pdf"
raw_text = read_pdf(PDF_PATH)  # fitz.open → page.get_text

# 第 2 步：切块
CHUNK_SIZE = 200
OVERLAP    = 30  # step = CHUNK_SIZE - OVERLAP
chunks = chunk_text(raw_text, CHUNK_SIZE, OVERLAP)

# 第 3 步：存入 ChromaDB（持久化）
DB_PATH  = "/Users/hechengfajituan/ai-assistant/chroma_db"
PDF_NAME = os.path.basename(PDF_PATH)  # 路径取文件名做 metadata
client   = chromadb.PersistentClient(path=DB_PATH)
collection = client.get_or_create_collection(name="pdf_knowledge")
# add 三件套等长：documents / ids / metadatas
collection.add(documents=chunks, ids=ids, metadatas=metadatas)
```

**踩坑记录**：
- `PersistentClient(path=...)` 的 path 必须是**目录路径**，不是 PDF 路径
- `metadata` 的中文字段名（如 `来源`）合法，但 where 查询时**必须拼写完全一致**
- `add` 三件套等长，**整行插入**（W10-D2 已踩过 Unequal lengths）

---

## 三、D6 语义搜索的 3 道改造题（**留作延伸，未做**）

| 题号 | 题目 | 状态 | 原因 |
|:---|:---|:---|:---|
| ① | query_list 换 3 个 PDF 相关 query，看距离是否 < 1.0 | ⚠️ 部分 | 已跑 6 个 query，**距离普遍 0.97-1.25**，根因见下方 |
| ② | test_query n_results=1，看 top-1 是否最相关 | ⏸ 未做 | 上面已说明召回质量受限 |
| ③ | where 条件改（`{"来源": "xx.pdf"}`），对比过滤前后 | ✅ 修过语法 | $and 嵌套已验证 |

**根因分析（召回质量）**：
- MiniLM-L6-v2 是**英文为主**的 embedding 模型，对中文短文本不友好
- 测试 PDF 仅 430 字 / 5 页，切 3 块后**样本量不够**，top-1 必集中
- **解法**（W11 真实项目用）：换中文专用模型 `BAAI/bge-small-zh`（需装 sentence-transformers + 200M 模型）

---

## 四、关键技术细节（防止下次踩坑）

| 概念 | 数值/写法 | 备注 |
|:---|:---|:---|
| PersistentClient path | 目录绝对路径 | `os.path.dirname(__file__)` 锁脚本目录最稳 |
| chromadb 版本 | 1.5.9 | onnxruntime 依赖 ~40 个 |
| fitz vs pymupdf | fitz 已 deprecated | 警告无碍，未来迁移 `import pymupdf` |
| where 多条件 | `$and` 嵌套 | 不支持并列字段 |
| distance 范围 | < 1.0 真相关 | 中文库对中文 query 通常 0.5-0.8 |
| embedding 模型 | all-MiniLM-L6-v2 | 79M，**英文友好** |

---

## 五、产出的代码文件

| 文件 | 大小 | 用途 |
|:---|:---|:---|
| `~/ai-assistant/w10_d5_rag_pipeline.py` | ~3KB | PDF→切块→入库完整 pipeline |
| `~/ai-assistant/w10_d6_semantic_search.py` | ~2.4KB | 多 query 测距 + metadata 过滤 |
| `~/ai-assistant/w10_generate_test_pdf.py` | ~2.5KB | reportlab STSong-Light 字体生成中文 PDF |
| `~/ai-assistant/test_zh.pdf` | 5 页 | 直播带货实战知识（可删可重用） |

---

## 六、给 W11 的接口

W11 教程 = "搭建完整 RAG 问答系统"，**D5+D6 的代码骨架就是 W11 的地基**：
- D5 的 pipeline = W11 的"离线建库"阶段
- D6 的 query + distance 判断 = W11 的"在线检索"阶段
- 缺的：把检索到的 top-k 块**塞进 LLM Prompt**，让 LLM 综合归纳答用户

```python
# W11 将长这样（伪代码）
top_k = collection.query(query_texts=[user_q], n_results=3)
context = "\n".join(top_k["documents"][0])
prompt = f"""基于以下资料回答问题（不允许编造）：
{context}
问题：{user_q}
"""
answer = openai_client.chat.completions.create(
    model="deepseek-chat",
    messages=[{"role": "user", "content": prompt}]
)
```

---

## 七、复盘三问

1. **Q**：为什么测试 PDF 跑出来的距离都 > 1.0，跟教程说的"距离 < 1.0 才相关"对不上？
   **A**：①测试 PDF 字数太少（430 字）②中文短句对 MiniLM-L6-v2 不友好③样本少导致 top-1 集中。这三件事都是工程现实，不是代码错。

2. **Q**：D5 的 bug 是什么？谁的责任？
   **A**：原代码 `DB_PATH` 变量没独立出来，PDF 路径被误用为向量库路径 → 报错。**是我（D5 骨架作者）写错的，不是你手敲错的**。下次 TODO 注释必须明确每个独立变量的作用。

3. **Q**：改造题没做完算 W10 不及格吗？
   **A**：不算。改造题是"延伸实验"不是"必做项"。**核心概念都过了**（pipeline 流程、距离阈值判断、where 语法）→ W10 视为通过，改造题留作 W11 真实项目里的实战。

---

## 八、下一步预告

- **W10-D7（周三）**：RAG 完整流程图（ASCII + Mermaid 双版本） + 周日汇总 `10-Week10-向量库.md`
- **W11（预告）**：基于 D5+D6，加 LLM 综合生成答案 = 完整 RAG 问答系统
- **真实数据**（W11 用）：朋友的直播带货产品知识库（不再用测试 PDF）
