# W11-D2 bge-small-zh 本地中文 Embedding（2026-08-22）

> 前置：W11-D1 完成（DocumentLoader，评分 92）。今日任务：用中文专用 **bge-small-zh** 本地 embedding 替换 W10 默认 MiniLM（中文语义弱）。

---

## ⚠️ 环境关键结论（动手前必看，否则必报错）

今天撞了**依赖地狱**，根因 = **阿里源只有 torch≤2.2.2，没有 torch≥2.5**，而 sentence-transformers 6.0.0 要求 torch≥2.5、transformers 4.57 强制 torch≥2.6 才让加载模型。

实测跑通的兼容组合（**已固化进 `~/ai-assistant/requirements.txt`**）：

| 包 | 版本 | 原因 |
|:---|:---|
| torch | 2.2.2 | 阿里源最高只有 2.2.2，装不了 2.5+ |
| numpy | 1.26.4 | 配合 torch 2.2；numpy 2.x 会崩内部初始化 |
| sentence-transformers | 2.7.0 | 兼容 torch 2.2；6.0.0 要求 torch≥2.5 必冲突 |
| transformers | 4.44.2 | 4.57 强制 torch≥2.6 才让 `from_pretrained` 加载，降级回兼容版 |

装包命令（venv 内，带 SSL 修复）：
```bash
SSL_CERT_FILE=/etc/ssl/cert.pem ~/ai-assistant/venv/bin/pip install \
  "numpy==1.26.4" "torch==2.2.2" "sentence-transformers==2.7.0" "transformers==4.44.2" \
  -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
```

import 正确路径（本环境 `langchain 1.3.15` 实测）：
- ✅ `from langchain_community.embeddings import HuggingFaceEmbeddings`（`langchain_huggingface` 未装、`langchain.embeddings` 1.x 已删，都不可用）
- ✅ `sentence_transformers` / `torch` / `numpy` 均可 import
- ⚠️ 模型名大小写敏感：`BAAI/bge-small-zh` 一字不差

---

## 本课四件套

### ① 为什么换 bge
- W10 默认 MiniLM 中文语义弱（D6 实测短板）。bge-small-zh 是 BAAI 专为中文训练的 embedding，免费、本地离线跑，输出维度 **512**。

### ② bge 是什么
- BAAI General Embedding，约 24M 参数，本地免费离线。首跑联网下载约 130MB 权重（之后缓存）。把文本变成 512 维向量，语义相近的文本向量距离近。

### ③ 用法（LangChain 1.x）
```python
from langchain_community.embeddings import HuggingFaceEmbeddings
emb = HuggingFaceEmbeddings(model_name="BAAI/bge-small-zh")
vec = emb.embed_query("一句话")  # 返回 512 维 list[float]
```

### ④ 验证方法
- 用三句中文测余弦相似度：近义句距离近、无关句距离远。
- ⚠️ bge 相似度基线偏高（所有句对都有不错基础分），看**相对差距**不看绝对值。

---

## 立即行动

### 步骤 A：装依赖（见上方兼容组合）
### 步骤 B：手敲骨架，生成三句中文的 512 维向量，验证相似度

---

## 📝 代码骨架（手敲；用户已手敲 `W11_D2_embedding.py` 跑通）

```python
# === W11-D2: 用 bge-small-zh 本地中文 embedding 生成向量 ===
# 注意: 教程的 from langchain.embeddings 已废弃
#       本环境用 from langchain_community.embeddings

from langchain_community.embeddings import HuggingFaceEmbeddings
import numpy as np

# === 1. 创建 bge 中文 embedding 对象 ===
# TODO(你填): 模型名大小写敏感, BAAI/bge-small-zh 一字不差
emb = HuggingFaceEmbeddings(model_name="BAAI/bge-small-zh")

# === 2. 三句测试文本 ===
# TODO(你填): 换成你想测的句子; 这里用近义+无关对比
sent_a = "猫喜欢抓老鼠"
sent_b = "猫咪爱抓小老鼠"      # 近义
sent_c = "今天股票跌了"        # 无关

# === 3. 生成 512 维向量 ===
vec_a = np.array(emb.embed_query(sent_a))
vec_b = np.array(emb.embed_query(sent_b))
vec_c = np.array(emb.embed_query(sent_c))

# === 4. 余弦相似度 ===
def cos_sim(x, y):
    return float(np.dot(x, y) / (np.linalg.norm(x) * np.linalg.norm(y)))

# === 5. 打印验证 ===
print("向量维度:", len(vec_a))
print("前五个值:", vec_a[:5])
print("猫-猫咪:", cos_sim(vec_a, vec_b))
print("猫-股票:", cos_sim(vec_a, vec_c))
```

---

## 学员作业（已跑通 ✅）

输出：
```
向量维度： 512
前五个值： [-0.0077, 0.0308, 0.0428, 0.0156, -0.0278]
猫-猫咪 0.9663633477223247
猫-股票 0.7179592534303227
```

判定：
- 维度 512 ✅（bge-small-zh 标准输出，模型加载正确）
- `猫-猫咪 0.97` >> `猫-股票 0.72` ✅（近义远于无关，中文语义区分有效）
- 用户自加「前五个值」打印，主动观察向量形态 → 好直觉，保留

---

## 🧠 知识整合（W11-D2 核心）

1. **bge-small-zh = 中文专用本地 embedding**：512 维、免费离线、中文语义强于 W10 的 MiniLM。
2. **LangChain 1.x 导入路径**：`langchain_community.embeddings.HuggingFaceEmbeddings`（不是 `langchain.embeddings` 也不是 `langchain_huggingface`）。
3. **相似度语义逻辑**：语义越近 → 余弦相似度越大（近义 0.97 > 无关 0.72）；bge 基线偏高，看相对差距。
4. **依赖锁定重要性**：今天撞坑 = 没锁版本导致 st 6.0.0 / torch 版本冲突。已固化兼容组合进 `requirements.txt`，换机器一行 `pip install -r requirements.txt` 恢复。
5. **query 和建库必须同一 embedding 对象**：否则向量空间不同，距离无意义（D3 建库直接用这条）。

---

## 下一步 W11-D3
用 bge 中文 embedding 建 **Chroma 向量库**：把 D1 的 Document + D2 的 bge 接进 Chroma（`from langchain_chroma import Chroma`），形成可检索知识库 —— RAG 的「索引」核心。
