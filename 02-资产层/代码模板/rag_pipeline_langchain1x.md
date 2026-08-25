# 配方卡：RAG 完整闭环（LangChain 1.x + bge + Chroma + DeepSeek）

> 适用：私有知识库问答 / FAQ 机器人（W12 直接复用）
> 验证环境：macOS, Python 3.12, langchain 1.3.15，2026-08-22 W11-D5 实测跑通
> 来源学习层：[[11-Week11-LangChainRAG]]

---

## 一、依赖锁定（写进 requirements.txt，pip install -r 恢复）

```txt
# RAG 闭环依赖（W11 实测兼容组合，勿随意升级）
langchain==1.3.15
langchain-community==0.4.2
langchain-openai==1.5.1
langchain-chroma==1.1.0
sentence-transformers==2.7.0
transformers==4.44.2
torch==2.2.2
numpy==1.26.4
```

```bash
# 安装需 SSL_CERT_FILE + 阿里源（W9 归档方案，清华源 403）：
SSL_CERT_FILE=/etc/ssl/cert.pem pip install -r requirements.txt \
  -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
```

---

## 二、核心代码（可直接抄，已含关键坑标）

```python
# === 1. 环境：加载 DeepSeek key（.env，不硬编码）===
import os
from dotenv import load_dotenv
load_dotenv()
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY")

# === 2. 文档：Loader 加载（PDF 用 PyMuPDF，简单 PDF 用 pypdf，Word 用 docx2txt）===
from langchain_community.document_loaders import PyMuPDFLoader
raw_docs = PyMuPDFLoader("your.pdf").load()

# === 3. 切块：RecursiveCharacterTextSplitter ===
from langchain_text_splitters import RecursiveCharacterTextSplitter
splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
docs = splitter.split_documents(raw_docs)

# === 4. Embedding：bge-small-zh（512维，中文优于 MiniLM）===
from langchain_community.embeddings import HuggingFaceEmbeddings
emb = HuggingFaceEmbeddings(model_name="BAAI/bge-small-zh")  # ⚠️ 模型名大小写敏感

# === 5. 建库：Chroma（⚠️ 必须显式 embedding=emb，漏了静默错误中文全错）===
from langchain_chroma import Chroma
vs = Chroma.from_documents(documents=docs, embedding=emb, persist_directory="./chroma_db")
# ⚠️ 同名 persist_directory 重复 from_documents 会追加非覆盖，改数据先删目录

# === 6. 检索：retriever ===
retriever = vs.as_retriever(search_kwargs={"k": 1})
# ⚠️ score_threshold 直接传会 TypeError，需自己 if 过滤；filter 是硬约束

# === 7. LLM：DeepSeek（OpenAI 格式，base_url 不带 /v1）===
from langchain_openai import ChatOpenAI
llm = ChatOpenAI(
    model="deepseek-chat",
    api_key=DEEPSEEK_API_KEY,
    base_url="https://api.deepseek.com",  # ⚠️ 不带 /v1
    temperature=0,
)

# === 8. LCEL 管道（替代已删 RetrievalQA）===
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

prompt = ChatPromptTemplate.from_template(
    "只根据上下文回答，上下文没有就回答不知道。\n上下文：{context}\n问题：{question}"
)
def format_docs(docs): return "\n\n".join(d.page_content for d in docs)

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt | llm | StrOutputParser()
)

print(rag_chain.invoke("你的问题"))  # 或 rag_chain.invoke(input("问题: "))
```

---

## 三、五个坑（必看，W11 实测踩过）

1. **`from langchain.embeddings import ...` 1.x 已删** → 用 `langchain_community.embeddings`
2. **建库漏 `embedding=emb` 静默错误**：默认 OpenAI 向量空间，中文检索全错，无报错
3. **DeepSeek `base_url` 不带 `/v1`**：写了 `/v1` 报模型不存在
4. **同名 `persist_directory` 重复 `from_documents` 追加非覆盖**：改数据先删目录
5. **`score_threshold` 直接传 TypeError**：当前 langchain_chroma 版本不支持，改自己 if 过滤

---

## 四、适配说明

- **bge-small-zh**：512 维，中文语义优于 MiniLM（W10 用 MiniLM 中文短文本召回差）
- **ChatOpenAI 伪装 DeepSeek**：DeepSeek 兼容 OpenAI 格式，用 langchain_openai 调
- **LCEL 替代 RetrievalQA**：langchain 1.x 删了 chains 包，用 `retriever|prompt|llm|parser` 管道
- **防幻觉软约束**：prompt "不知道就说不知道" 是软约束，LLM 对常识会忽略指令（RAG 边界=检索准≠全知）
- **答案溯源**：拆管道用 `retriever.invoke(q)` 拿 `metadata["src"]`（见 W11-D6）

---

## 五、关联

- 学习层：[[11-Week11-LangChainRAG]]（D1-D7 完整过程）
- 项目层：W12 FAQ 机器人（待建，直接复用本卡）
- 每日文件：[[04-学习档案/每日练习/W11-D5-完整RAG闭环]] [[04-学习档案/每日练习/W11-D6-答案溯源]]
