---
tags: [W8, Streamlit, 网页, 部署, 复习清单]
创建: 2026-08-14
更新: 2026-08-16
关联: [[00-学习路线图]] [[07-Week7-API调用]] [[09-Week9-部署变现]]
---

# W8｜多轮对话与 Streamlit 可视化

> 状态：✅ 已完成（闭卷 78 + 美化封顶）
> 成果：网页版 AI 内容生成器（API + 结构化 + UI + 本地部署，全栈雏形）

## 一、本周学会了什么
- Streamlit 基础组件，纯 Python 写网页 UI
- session_state / columns / download_button / file_uploader（D1 四件套）
- sidebar 菜单 / 视图切换 / 温度滑杆（D2 真产品）
- 本地部署（D3）+ 交付 requirements.txt
- 产品美化（说明+示例+品牌感）+ 深色模式踩坑

## 二、Streamlit 基础
- 价值：命令行程序→网页，创业闭环（提示词→脚本→落地）第一步
- 跑：`source venv/bin/activate && pip install streamlit && streamlit run streamlit_app.py` → 自动开 localhost:8501
- 基础组件：
```python
st.title("标题"); st.text_input("标签", "默认")
st.selectbox("标签", options); st.button("按钮")
st.write(变量); st.json(字典); st.error("出错"); st.spinner("...")
```

## 三、D1 四件套
1. **st.session_state**：跨重跑记忆（字典 `st.session_state["key"] = v`）。每次交互 Streamlit 从头重跑脚本，普通变量重置
2. **st.columns(2)**：`col1, col2 = st.columns(2)`，`with col1:` 放左列
3. **st.download_button**：`st.download_button("文字", 数据, file_name="x.md")` 一键下载
4. **st.file_uploader**：`uploaded.read().decode("utf-8")`；坑：read() 第二次空（指针到尾）→ 用 session_state 按 file_id 缓存

## 四、D2 三升级
1. **st.sidebar**：左侧设置栏（温度/长度滑杆）
2. **st.radio 视图切换**：`["Markdown","JSON"]`，同一 data 两种渲染不重调 API
3. **温度滑杆**：`generate()` 加可选参数 `(temperature=1.5, max_tokens=800)`，默认值不变 → CLI 老用法不受影响
- 错误友好：`st.error("❌ 生成失败...")`

## 五、D3 本地部署 + 复盘
- 本地部署 = 应用跑在 http://localhost:8501（公网部署是 W16-17 的事）
- 交付：`cd ~/ai-assistant && source venv/bin/activate && pip install -r requirements.txt && streamlit run streamlit_app.py`
- 前置：`.env` 有 `DEEPSEEK_API_KEY`

## 六、美化（产品感三件套）
1. **加说明**：Hero 大标题 + 功能介绍
2. **加示例**：示例话题按钮（咖啡/减肥/旅游/护肤），点了 `st.session_state.topic_input = ex` 填输入框
3. **加 logo/品牌感**：标题 emoji、CSS 注入（隐藏菜单+footer、圆角按钮、`layout="wide"`）
- 品牌蓝：`🚀生成` 按钮 `#2563eb`（悬停 `#1d4ed8`）；结果卡片白底圆角；页脚署名
- `set_page_config` 必须是第一个 st 调用

## 七、🐛 深色模式踩坑（通用法则）
- 现象：预设/示例按钮只看见 emoji，汉字隐形
- 根因：系统深色主题，Streamlit 默认按钮文字浅色；CSS 改背景浅灰 `#f8f9fa` 但**没改文字色** → 浅字落浅底
- 修法：按钮显式 `color: #1f2937`（深灰）；主按钮备用选择器 `button[kind="primary"]`
- **通用法则：任何自定义主题色组件 → 前景 + 背景必须同时设**，深色用户必踩

## 八、后台运维小知识
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8501   # 000=挂 200=在
ps aux | grep streamlit
nohup streamlit run streamlit_app.py --server.port 8501 --server.headless true > /tmp/streamlit.log 2>&1 &
```

## 九、W7→W8 全链路
| 阶段 | 学会 | 产物 |
|------|------|------|
| W7 ① | temp/max_tokens | day3_demo |
| W7 ② | 结构化 JSON mode | content_generator |
| W7 ③ | 错误码 429/401/400 | 重试逻辑 |
| W7 ④ | Streamlit 基础 | streamlit_app v1 |
| W8-D1 | session_state/columns/download/uploader | streamlit_app v2 |
| W8-D2 | sidebar/视图切换/温度滑杆 | streamlit_app v3 |
| W8-D3 | 本地部署+交付 | requirements.txt |

## 📝 复习清单
- [x] 多轮对话 = messages 历史累积（system/user/assistant）
- [x] Streamlit 基础组件：title/text_input/button/json/error
- [x] session_state 跨重跑记忆；columns 并排；download_button 下载；file_uploader 上传
- [x] sidebar 设置栏；radio 视图切换；温度滑杆实时控
- [x] 本地部署：streamlit run + 浏览器 8501
- [x] 美化三件套：说明 + 示例 + 品牌感
- [x] 深色模式：改背景必须同时改文字色

> TODO(你填)：回忆一下"🗑清空历史"按钮你是怎么写的（`st.button` + `st.session_state.history = ?`），写一遍巩固。

> 🔗 返回：[[00-学习路线图]]｜[[07-Week7-API调用]]｜[[09-Week9-部署变现]]
