# W11-D1 LangChain 安装与 Document Loader（2026-08-19）

> 前置：W10 全部完成（ChromaDB + PDF 加载 + 切块 + 语义搜索 + 流程图）。本周 W11 = 用 LangChain 搭完整 RAG 问答系统。
> 今日任务（教程 W11 周一）：安装 LangChain + 学习 Document Loader，目标 = 能加载 PDF/Word/Markdown。

---

## ⚠️ 环境关键结论（动手前必看，否则必报错）

教程里的 LangChain 代码是**老版本写法**，我们装的是 **langchain 1.3.15（最新大版本）**，包结构已拆分。实测对照：

| 教程老写法（已废弃） | 我们环境正确写法 |
|:---|:---|
| `from langchain.document_loaders import PyPDFLoader` | `from langchain_community.document_loaders import PyPDFLoader` |
| `from langchain.embeddings import OpenAIEmbeddings` | `from langchain_openai import OpenAIEmbeddings` |
| `from langchain.chat_models import ChatOpenAI` | `from langchain_openai import ChatOpenAI` |
| `from langchain.vectorstores import Chroma` | `from langchain_chroma import Chroma` |
| `from langchain.chains import RetrievalQA` | ❌ **1.x 已删除** → D4/D5 改用 LCEL 管道写法 |

已装包：`langchain 1.3.15` / `langchain-community 0.4.2` / `langchain-openai 1.5.1` / `langchain-chroma 1.1.0` / `pypdf 6.16.1` / `docx2txt 0.9`。
测试夹具（助手已生成）：`~/Desktop/AI学习知识库/W11测试文件/{demo.pdf, demo.docx, demo.md}`。

---

## 本课四件套

### ① LangChain 是什么 / 为什么用
- 一个 LLM 应用开发框架，把 RAG 拆成**标准化积木**：Loader（读）→ Splitter（切）→ Embedding（向量化）→ VectorStore（存/检索）→ Chain（串联问答）
- 价值：不用自己从零拼 ChromaDB + API + Prompt，框架给现成组件，且各组件可替换（换 embedding 模型、换向量库都不用改整体结构）

### ② Document Loader 的作用
- RAG 第一步永远是"把各种格式的文档读进来"
- Loader 的职责：把 PDF / Word / Markdown / 网页 / 网页… **统一成 `Document` 对象**，后面切块、向量化全都吃这个统一格式
- `Document` = 一个数据类，含 `page_content`（正文文本）+ `metadata`（来源/页码等元信息）

### ③ 三种 Loader（今日主角）
| 格式 | Loader 类 | 依赖 |
|:---|:---|:---|
| PDF | `PyPDFLoader` | `pypdf`（已装）|
| Word(.docx) | `Docx2txtLoader` | `docx2txt`（已装）；**不支持老 .doc** |
| Markdown | `TextLoader(encoding="utf-8")` | 无额外依赖，最稳 |

> 为什么 MD 用 `TextLoader` 而不是 `UnstructuredMarkdownLoader`？后者要装庞大的 `unstructured` 包，MD 本质就是纯文本，用 `TextLoader` + `utf-8` 就够了，简单且中文不乱码。

### ④ Document 结构 & 核心 API
```python
loader = PyPDFLoader("x.pdf")
docs = loader.load()        # 返回 List[Document]，1页≈1块
docs[0].page_content        # 这段文本
docs[0].metadata           # {'source': 'x.pdf', 'page': 0, 'total_pages': 1, ...}
len(docs)                   # 文档块数
```
- 关键认知：**Loader 只负责"读成 Document"，不做切块**；切块是下一步（W11 之后或 W10 已学 `RecursiveCharacterTextSplitter`）的活。

---

## 立即行动（今日作业）

### 步骤 A：装包（助手已装好，你只需知道命令长这样）
```bash
SSL_CERT_FILE=/etc/ssl/cert.pem \
~/ai-assistant/venv/bin/pip install -U \
  -i https://mirrors.aliyun.com/pypi/simple/ \
  --trusted-host mirrors.aliyun.com \
  langchain langchain-community langchain-openai langchain-chroma pypdf docx2txt
```

### 步骤 B：手敲下面骨架，加载三份测试文件，打印「块数 + 前200字」
> 复制友好：常量已分离，路径是助手生成的测试文件，你也可换成自己的文件（见 TODO）。

---

## 📝 代码骨架（手敲，勿复制粘贴；又变…就在 PyCharm 照敲）

```python
# === W11-D1: 用 LangChain Document Loader 加载 PDF/Word/Markdown ===
# 注意：教程的 from langchain.document_loaders 已废弃
#       新版统一改成 from langchain_community.document_loaders

from langchain_community.document_loaders import (
    PyPDFLoader,
    Docx2txtLoader,
    TextLoader,
)

# === 1. 加载 PDF ===
# TODO(你填): 换成你自己的 PDF 路径；下面是我生成的测试文件
PDF_PATH = "/Users/hechengfajituan/Desktop/AI学习知识库/W11测试文件/demo.pdf"
pdf_loader = PyPDFLoader(PDF_PATH)
pdf_docs = pdf_loader.load()  # 返回 List[Document]

# === 2. 打印 PDF 结果 ===
# ⚠️ 坑: 扫描件(图片型)PDF 读出来是空文本，需要 OCR 才能加载
print(f"PDF 文档块数: {len(pdf_docs)}")
print(f"PDF 前200字: {pdf_docs[0].page_content[:200]}")
print(f"PDF 元数据: {pdf_docs[0].metadata}")

# === 3. 加载 Word(.docx) ===
# TODO(你填): 换成你自己的 .docx；注意 .doc 老格式不支持
DOCX_PATH = "/Users/hechengfajituan/Desktop/AI学习知识库/W11测试文件/demo.docx"
docx_loader = Docx2txtLoader(DOCX_PATH)
docx_docs = docx_loader.load()
print(f"Word 文档块数: {len(docx_docs)}")
print(f"Word 前200字: {docx_docs[0].page_content[:200]}")

# === 4. 加载 Markdown ===
# TODO(你填): 换成你自己的 .md；encoding 必须 utf-8 否则中文乱码
MD_PATH = "/Users/hechengfajituan/Desktop/AI学习知识库/W11测试文件/demo.md"
md_loader = TextLoader(MD_PATH, encoding="utf-8")
md_docs = md_loader.load()
print(f"Markdown 文档块数: {len(md_docs)}")
print(f"Markdown 前200字: {md_docs[0].page_content[:200]}")
```

---

## 学员作业（待提交 + 待点评）
> 把上面骨架在 PyCharm 手敲运行，把三份文件的「文档块数 + 前200字」发给我。

---

## 🧠 知识整合（W11-D1 核心）

1. **LangChain = RAG 积木框架**：Loader→Splitter→Embedding→VectorStore→Chain，每块可单独替换。
2. **Loader 统一格式**：任何文档进来都变成 `Document(page_content, metadata)`，是后续所有步骤的"通用货币"。
3. **版本陷阱**：langchain 1.x 把 `document_loaders/embeddings/chat_models/vectorstores` 全拆进 `langchain_community` / `langchain_openai` / `langchain_chroma`；`langchain.chains`（含 RetrievalQA）已删除 → 用 LCEL。
4. **三类 Loader 选型**：PDF→`PyPDFLoader`、Word(.docx)→`Docx2txtLoader`、Markdown→`TextLoader(utf-8)`；`.doc` 老格式不支持，图片型 PDF 需 OCR。
5. **Loader 只"读"不"切"**：输出是 `List[Document]`，切块是下一步（`RecursiveCharacterTextSplitter`）的活，别混淆职责。

---

## 下一步 W11-D2
Embedding 模型调用：用 **bge-small-zh 本地中文 embedding**（sentence-transformers，免费、中文效果好；不用教程的 OpenAIEmbeddings，因为我们没有 OpenAI key，且要中文）。
