---
tags: [W3, Python基础, 复习清单]
创建: 2026-08-14
关联: [[00-学习路线图]]
---

# Week 3 · 函数与模块

tags: #W3 #阶段1 #地基

## 学习目标
- 封装函数、使用标准库模块
- 掌握 try-except 异常处理

## 核心知识点
- `import math` 后须 `math.sqrt()`；`from math import sqrt` 后才能直接 `sqrt()`
- `float()`/`int()` 对非法值抛 ValueError（非 TypeError）
- try-except：except 只捕 try 内异常；except 块只 print 不 return 会"穿过去"

## 我的易错点（来自测评，根因2漏）
1. import 后函数调用写法（math.sqrt vs sqrt）
2. `float("x")` 抛 ValueError 非 TypeError

## 测评记录
- 7/7 练习全完成
- 周末考试：91/100 🌟

## 链接
- 返回 [[00-学习路线图]]
- 模板 [[01-模板库/Prompt模板库]]

---

## 🧠 知识整合（函数封装与异常处理）

### 本周在 AI 学习路线图中的位置
- **阶段1 (W1-4)**：Python 基础 ← 当前 W3
- 承前：W2 循环与条件；启后：W4 API 调用中的函数封装

### 核心概念深层理解

#### import 的两种写法（对比表）
```python
# 写法1：import 整个模块（用时加模块名前缀）
import math
math.sqrt(16)      # → 4.0
math.pi            # → 3.14159...

# 写法2：from 模块 import 具体函数（直接用）
from math import sqrt
sqrt(16)           # → 4.0，不需要 math.

# ⚠️ 写法1更安全：命名空间不冲突
# ⚠️ 写法2更简洁：但可能和本地命名冲突
```

#### try/except 异常处理（最重要的防御性编程工具）
```python
# 基础结构
try:
    age = int(input("年龄："))
except ValueError:
    print("请输入有效数字")

# except 块只有 print 没有 return → 会"穿过去"
def safe_div(a, b):
    try:
        return a / b
    except ZeroDivisionError:
        print("除数不能为零")
    # ⚠️ 这里没有 return，如果触发 except，函数返回 None

# 正确写法：except 块也要 return
def safe_div_fixed(a, b):
    try:
        return a / b
    except ZeroDivisionError:
        return None  # ← 必须 return，否则穿过去
```

#### 常见异常类型对照表
| 异常类型 | 触发场景 | 示例 |
|:---|:---|:---|
| `ValueError` | 值格式错误 | `int("abc")` / `float("x")` |
| `TypeError` | 类型不匹配 | `"str" + 1` |
| `KeyError` | 字典 key 不存在 | `d["不存在"]` |
| `ZeroDivisionError` | 除以零 | `1 / 0` |

### W3 知识在 RAG/Agent 体系中的潜在应用
| W3 知识 | RAG/Agent 应用 |
|:---|:---|
| 函数封装 | 把 PDF 读取/切块/查询封装成独立函数，W10-D5 pipeline 核心 |
| try/except | API 调用失败处理（W7 429/401/400）；文件读取失败 |
| return 值传递 | ChromaDB query 返回的 results 字典传给 LLM |

### 最重要的踩坑教训
1. **import 后必须加模块前缀**：不是 `sqrt(16)` 而是 `math.sqrt(16)`
2. **except 块要 return**：否则"穿过去"继续执行，导致返回 None 或后续报错
3. **ValueError vs TypeError**：`float("abc")` 是 ValueError，不是 TypeError

---

---

# 🧾 W3 复习清单｜函数与模块

> 📚 考试形式：口头/默写，10 分钟自检
> ⏱️ 推荐时长：15 分钟

---

## 一、函数定义与调用

- [ ] `def` 关键字用来定义函数
- [ ] 函数定义后**不会自动执行**，必须**调用**才会运行
- [ ] 调用函数时注意：`import math` 后要用 `math.sqrt()` 而不是 `sqrt()`
- [ ] 能区分「定义函数」和「调用函数」的顺序（先定义，后调用）

---

## 二、参数与返回值

- [ ] `return` 的作用：把函数内部的结果**返回给调用者**，并**结束函数执行**
- [ ] `return` 后面的代码**不会执行**（穿过去的问题）
- [ ] 没有 `return` 的函数返回值是 `None`
- [ ] 函数可以返回多个值（返回元组）

---

## 三、异常处理 try / except

- [ ] `try` 块里放**可能报错**的代码
- [ ] `except` 块里放**报错后**要做什么
- [ ] `except` **只捕获** `try` 里面的错误，不会跨块
- [ ] `except` 块里如果只有 `print()` 没有 `return`，会**穿过去**继续执行
- [ ] 常见异常类型：`ValueError`（值错误）、`TypeError`（类型错误）、`KeyError`（字典键不存在）

---

## 四、模块导入

- [ ] `import 模块名` 导入整个模块
- [ ] `from 模块名 import 函数名` 导入特定函数
- [ ] 知道常见模块：`math`（数学）、`random`（随机）
- [ ] `math.sqrt(x)` 里的 `math.` 是**命名空间前缀**，不能省略

---

## 五、字典 key 与查询

- [ ] 字典的 key 必须是**不可变类型**（字符串/数字）
- [ ] 查询字典时 key 类型必须**完全匹配**（字符串 key 不能用数字查）
- [ ] `float("hello")` 会抛出什么异常？（答案：`ValueError`）
- [ ] `except` 能捕获 `ValueError`，不能捕获 `TypeError`（类型不对）

---

## 六、常见错误

- [ ] 函数定义写了但忘记调用
- [ ] `except` 块里只有 `print()` 没有 `return`，导致「穿过去」
- [ ] `import` 后调用函数忘了加模块名前缀
- [ ] 字典查询时 key 类型写错

---

## 📝 自测小测（口头答）

1. `float("abc")` 会报错吗？报什么错？
2. `except` 块里只有 `print()` 没有 `return`，会怎样？
3. `import math` 后调用 `sqrt(4)` 对吗？应该怎么写？
4. 函数里 `return` 后面的代码会执行吗？

**答案**：① 报错，`ValueError` ② 会「穿过去」，函数继续执行 `return` 后面的代码 ③ 不对，应写 `math.sqrt(4)` ④ 不会执行，`return` 结束函数

---

> 🔗 返回：[[00-学习路线图]]｜[[02-Week2-判断循环]]｜[[04-Week4-API入门]]