---
tags: [W4, Python基础, 复习清单]
创建: 2026-08-14
关联: [[00-学习路线图]]
---

# Week 4 · API调用入门

tags: #W4 #阶段1 #地基

## 学习目标
- 用 requests 调 API、读写文件
- 解析 JSON、处理异常

## 核心知识点
- requests 调接口 + `.json()` 解析
- 文件读写 open/with
- JSON 解析：`int(code)` 须放进 try 内
- 防御：`response` 未赋值就 print → NameError（用 else 隔离成功逻辑）

## 我的易错点（来自测评）
- response 未赋值就 print → NameError（用 else 隔离）
- `int(code)` 须放进 try 内
- `int(age)<=0` 须 while 非 if 且转数字比较
- GitHub 上传因代理限制改网页上传（raw 返回 200 验证）

## 测评记录
- 7/7 练习全完成
- 阶段1 收尾：✅ 完成

## 链接
- 返回 [[00-学习路线图]]
- 模板 [[02-资产层/模板库/Prompt模板库]]

---

## 🧠 知识整合（API 调用与文件操作）

### 本周在 AI 学习路线图中的位置
- **阶段1 (W1-4)**：Python 基础 ← 当前 W4（阶段1收尾）
- 承前：W3 函数封装；启后：W7 LLM API 调用（实战升级）

### 核心概念深层理解

#### requests 调 API 完整流程
```python
import requests

url = "https://api.example.com/data"
params = {"key": "value"}  # URL 参数

response = requests.get(url, params=params)
# ⚠️ 必须先赋值给 response，才能用 response

if response.status_code == 200:        # 成功
    data = response.json()            # 解析 JSON
    print(data)
else:
    print(f"请求失败：{response.status_code}")
```

#### JSON 解析 + 防御性处理
```python
import json

try:
    data = json.loads(response.text)  # 字符串 → Python 对象
    print(data["name"])
except json.JSONDecodeError:
    print("返回的不是合法 JSON")
except KeyError:
    print("JSON 里没有 name 字段")
```

#### API 调用防御性编程模式
```python
def call_api(url, params):
    try:
        response = requests.get(url, params=params)
        response.raise_for_status()          # 4xx/5xx 抛异常
        data = response.json()
        return data                         # ✅ 成功才 return
    except requests.ConnectionError:
        print("网络连接失败")
    except requests.Timeout:
        print("请求超时")
    except requests.HTTPError as e:
        print(f"HTTP错误：{e}")
    # ⚠️ except 块里不要 pass，要 print 或 return
    return None                            # 失败返回 None，调用方处理
```

#### API 错误码速查
| 错误码 | 含义 | 常见原因 |
|:---|:---|:---|
| 200 | 成功 | - |
| 400 | 请求无效 | 参数格式错误 |
| 401 | 认证失败 | API Key 错误/缺失 |
| 429 | 限速/配额满 | 请求太频繁 |
| 500 | 服务器内部错误 | API 服务端问题 |

### W4 知识在 RAG/Agent 体系中的潜在应用
| W4 知识 | RAG/Agent 应用 |
|:---|:---|
| requests 调 API | 调用 DeepSeek / OpenAI LLM API（W7 核心） |
| JSON 解析 | 解析 LLM 返回的 JSON 响应（W7-8 项目） |
| try/except + return | ChromaDB 查询失败处理、文件读取失败处理 |
| 防御性 API 调用 | W10-D5 pipeline 里的 DeepSeek 生成调用 |

### 最重要的踩坑教训
1. **response 必须先赋值再使用**：`requests.get()` 的结果要存到变量里才能 `.json()`，否则 `NameError`
2. **`int()` 必须放 try 里**：因为用户输入非法字符会抛 `ValueError`，不在 try 里无法捕获

---

---

# 🧾 W4 复习清单｜API 调用入门

> 📚 考试形式：口头/默写，10 分钟自检
> ⏱️ 推荐时长：15 分钟

---

## 一、API 基本概念

- [ ] API = **应用程序接口**，让程序之间能互相「对话」
- [ ] 知道「调用 API」和「打开网页」的区别（程序 ↔ 程序 vs 人 ↔ 程序）
- [ ] 能说出至少 1 个真实 API 例子（如天气 API、翻译 API）

---

## 二、API 请求流程

- [ ] 完整流程：发请求 → 等待响应 → 接收数据 → 解析使用
- [ ] 知道「request 失败」的情况（网络问题/参数错误/超时）
- [ ] 知道如何用 `try/except` 包裹 API 调用代码（W3 知识的实战应用）

---

## 三、GitHub 文件上传（实操）

- [ ] 能在 GitHub 网页版创建新仓库
- [ ] 能上传 `.py` 文件到仓库
- [ ] 能复制文件的 GitHub 链接
- [ ] 能说出 GitHub 的三个核心功能：存储代码、版本管理、分享协作

---

## 四、API 错误处理（W3 try/except 知识应用）

- [ ] `response` 没有赋值就直接 `print(response)` 会怎样？（答案：**`NameError`**，变量不存在）
- [ ] `int(age)` 如果 `age` 不是数字会怎样？（答案：**`ValueError`**）
- [ ] `age <= 0` 的判断应该用 `while` 还是 `if`？（答案：`while`，不合法要**持续要求重输**）
- [ ] `int(age)` 必须放在 `try` 块里，否则异常无法被捕获

---

## 五、防御性编程（W4 核心）

- [ ] 能写出「带输入验证的 API 调用」代码：
  - 输入不合法 → `while not valid: input()` 持续要求重输
  - 请求失败 → `try/except` 捕获网络错误
  - 数据解析错误 → `try/except` 捕获 JSON 解析错误
- [ ] 能用 `else` 分支隔离「成功逻辑」（成功才处理数据）

---

## 六、常见错误

- [ ] `NameError`：变量未赋值就使用
- [ ] `ValueError`：类型转换时传入非法值
- [ ] 死循环：验证输入的 `while` 没有退出条件
- [ ] `NameError`：没有 `response = requests.get(...)` 就 `print(response)`

---

## 📝 自测小测（口头答）

1. 什么叫「API」？用大白话解释
2. `int("abc")` 会报什么错？
3. 输入年龄应该用 `if age <= 0` 还是 `while age <= 0`？为什么？
4. `try/except` 能捕获哪几种错误？

**答案**：① 程序和程序之间的对话接口 ② `ValueError` ③ `while`，输入不合法要**循环要求重输**直到合法 ④ 任何在 `try` 块里发生的错误，只要 `except` 声明了对应类型就能捕获

---

> 🔗 返回：[[00-学习路线图]]｜[[03-Week3-函数模块]]｜[[05-Week5-Prompt基础]]