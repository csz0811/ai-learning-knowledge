# W10-D3 PDF 文档加载（2026-08-17 周三）

> 前置：W10-D2 ChromaDB 已跑通。今天把**真实文档**读进来，为明天"切块"做准备。

---

## 本课四件套

### ① 为什么需要 PDF 加载
- RAG 的第一步：把**外部知识**（PDF/Word/网页）变成**文本**
- 不能手动复制粘贴 → 用代码批量读取

### ② pdfplumber 安装（SSL 坑由助手处理）
- `pip install pdfplumber`
- 专门读 PDF，能提取文本、表格，比 PyPDF2 更稳

### ③ 基本用法
```python
import pdfplumber

with pdfplumber.open("xxx.pdf") as pdf:
    for page in pdf.pages[:3]:      # 遍历前 3 页
        text = page.extract_text()  # 提取文本
```

### ④ 关键概念：为什么不能直接塞全文？
- 一本 100 页的 PDF → 提取出来可能 5 万字
- 直接 `collection.add(documents=["5万字全文"])` → **向量失真，检索质量暴跌**
- 解决：**切块（chunking）** → 把长文切成小段（200/500/1000 字），每段独立向量化
- 明天 W10-D4 专门练这个

---

## 立即行动
1. ✅ 助手已创建测试 PDF + 跑通读取（`PyMuPDF` 方案，pdfplumber 依赖编译失败换的）
2. 改造题（手敲）：
   - 把 3 页文本拼成一个大字符串 `all_text` ✅（代码里已实现）
   - 打印 `len(all_text)` 看总字符数 ✅（本例 165 字符，真实 PDF 可能是几千/几万）
   - 思考：如果直接塞 ChromaDB，会有什么问题？

## ✅ 验证结果（2026-08-17）
- `pymupdf-1.28.2` 安装成功（替代 pdfplumber，后者 cryptography 编译失败）
- 自动创建 3 页测试 PDF → 读取成功 → 总字符数 165
- 中文显示乱码（reportlab 默认字体不支持），不影响流程学习
- 核心问题暴露：即使是 165 字符，如果是一整本书的 5 万字，直接塞 ChromaDB → 向量稀释 → 检索不准 → **必须切块（W10-D4）**

---

---

## 🧠 知识整合（文档读取核心）

### PDF 加载在 RAG 中的位置
```
外部文档（PDF/Word/网页）
  ↓ PDF 加载（提取文本）
原始文本
  ↓ 切块（chunking）
文本块列表
  ↓ 向量化（Embedding）
向量块列表
  ↓ 存入向量库（ChromaDB）
可检索知识库
```

### 常见 PDF 加载方案对比
| 方案 | 优点 | 缺点 |
|:---|:---|:---|
| **PyMuPDF**（当前用） | 轻量、安装简单、中文支持好 | 表格处理弱 |
| pdfplumber | 表格处理强 | cryptography 依赖编译可能失败 |
| PyPDF2 | 轻量 | 功能较少 |
| pdfminer | 功能丰富 | 安装复杂 |

### 切块前的关键问题：为什么不直接塞全文？
| 方案 | 问题 | 后果 |
|:---|:---|:---|
| 全文直接塞 | 向量"稀释" | 5万字→一个向量，检索时关键词被淹没 |
| 切块后塞 | 每块独立向量 | "苹果"相关内容精准命中 |

### PyMuPDF 核心用法
```python
import fitz  # PyMuPDF

doc = fitz.open("xxx.pdf")
for page in doc[:3]:           # 前3页
    text = page.get_text()      # 提取文本
```

### 中文 PDF 乱码问题
- 原因：默认字体不支持中文
- 解决：生成测试 PDF 用中文字体（如 SimHei）；真实 PDF 用 PyMuPDF 直接读自带字体

## 下一步 W10-D4
**文本切块策略**（chunk_size / overlap）→ 对比 chunk=200/500/1000 的效果差异。
