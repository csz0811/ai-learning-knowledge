# W10-D2 ChromaDB 安装与基础使用（2026-08-17 周二）

> 前置：W10-D1 完成（RAG 概述 + Embedding 原理）。今天把"向量库"真正跑起来。

---

## 本课四件套

### ① 向量数据库是干嘛的
- 普通列表存文本，检索靠"关键词匹配"；向量库存"文本的向量"，检索靠"语义相似度"
- ChromaDB 是轻量级向量库，Python 原生、本地能跑，最适合学习 / RAG 原型

### ② 安装（venv + 国内镜像，SSL 坑由助手处理）
- `pip install chromadb`（装在 ~/ai-assistant/venv）
- 首次 `add()` 会自动下载嵌入模型 all-MiniLM-L6-v2（~80MB，本地免费，只要这一次）

### ③ 三个核心对象
- **Client**：向量库客户端（入门用内存版 `chromadb.Client()`，不依赖外部服务）
- **Collection**：类似一张"表"，存一组相关文档
- **Document**：一条文本 + `id` + `metadata`(可选过滤字段)；**向量由 ChromaDB 自动生成**（默认 sentence-transformers）

### ④ 两个基本操作
- `collection.add(documents=[...], ids=[...], metadatas=[...])` → 插入
- `collection.query(query_texts=["..."], n_results=2)` → 语义查询，返回 top-k + 距离(越小越相似)

---

## Embedding 现实提醒
- ChromaDB 默认嵌入 = sentence-transformers 的 all-MiniLM-L6-v2（本地免费，首次下载）
- **DeepSeek 不做 Embedding**；生产环境可选 OpenAI `text-embedding-3-small`(要钱但稳) 或本地模型
- 今天先跑通默认方案，理解"插文档 → 查相似"的闭环即可

---

## 立即行动
1. 助手已装好 chromadb；你跑：`source ~/ai-assistant/venv/bin/activate && python w10_d2_chroma_demo.py`
2. 看输出：问"哪家公司做手机？"应召回"苹果公司发布了新款 iPhone"
3. 改造题（手敲）：①再加 2 条文档 ②把 n_results 改成 3 ③加 metadata 过滤 `where={"类别":"科技"}`

---

## ✅ 验证结果（2026-08-17）
- `chromadb-1.5.9` 安装成功（venv）
- 首次运行自动下载嵌入模型 all-MiniLM-L6-v2（79MB，已缓存 ~/.cache/chroma，后续秒开）
- demo 跑通：问"哪家公司做手机？" → top1="苹果公司发布了新款 iPhone"(距离0.53)，top2="特斯拉..."(1.25) → 语义检索命中 ✅
- 这就是 RAG 的 **Retrieval（检索）** 步：向量库捞出最相关片段，下一步喂给 LLM 生成

---

---

## 🧠 知识整合（ChromaDB 向量库核心）

### ChromaDB 在 RAG 中的角色
ChromaDB = **检索器（Retriever）**的核心组件，负责：
1. 存储文本块对应的向量
2. 接收问题向量
3. 计算相似度，返回 top-k 最相关文本块

### ChromaDB 的三个核心对象
| 对象 | 比喻 | 说明 |
|:---|:---|:---|
| Client | 数据库连接 | 管理所有 Collection |
| Collection | 一张表 | 存一组相关文档 |
| Document | 一行记录 | 文本 + id + metadata |

### Embedding 模型（ChromaDB 自动处理）
- **默认模型**：`sentence-transformers/all-MiniLM-L6-v2`
- 首次运行自动下载（~80MB，已缓存 ~/.cache/chroma）
- 输出维度：384维（比 OpenAI 1536维小，但够用）
- **本地免费**，无需 API Key

### add 三个参数（缺一不可）
| 参数 | 含义 | 示例 |
|:---|:---|:---|
| `documents` | 切好的文本块列表 | `["块1", "块2"]` |
| `ids` | 每块唯一标识符 | `["chunk_0", "chunk_1"]` |
| `metadatas` | 附加信息（可选） | `[{"来源":"笔记", "页码":1}]` |

### query 返回结果解读
- `results['documents']`：匹配的文本块列表
- `results['distances']`：距离值（越小越相似，0=完全一样）
- 语义检索示例：问"哪家公司做手机？" → 苹果(0.53) < 特斯拉(1.25)，语义理解发挥作用

### 内存版 vs 持久化版
- `chromadb.Client()`：内存版，程序结束数据消失（适合练习）
- `chromadb.PersistentClient(path="./db")`：持久化版，数据存磁盘（生产用）

### ChromaDB 不做的事
- ❌ 不做 LLM 生成（那是 DeepSeek 的活）
- ❌ 不做 PDF 读取（那是 PyMuPDF 的活）
- ❌ 不做文本切块（那是自定义逻辑的活）
- ✅ 只负责：存储向量 + 语义检索（专注 Retrieval）

## 下一步 W10-D3
PDF 文档加载（pdfplumber）→ 读取 PDF 前 3 页文本，为"切块"做准备。
