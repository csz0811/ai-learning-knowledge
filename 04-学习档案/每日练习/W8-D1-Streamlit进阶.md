# W8-D1 Streamlit 进阶（2026-08-16 凌晨）

> 前置：W7 ④ 已会跑基础 Streamlit。本课把生成器升级成「真产品」。

---

## 本课四件套

### ① st.session_state — 跨重新运行保存变量
- Streamlit 每次交互都会**从头重跑整个脚本**，普通变量会重置
- `st.session_state` 是跨重跑的「记忆」：字典用法 `st.session_state["key"] = value`
- 用途：存生成历史、记住用户选择、避免重复生成

### ② st.columns(n) — 并排布局
- 返回 n 个列对象：`col1, col2 = st.columns(2)`
- `with col1:` 里放的组件就显示在左列

### ③ st.download_button — 一键下载
- `st.download_button("文字", 数据, file_name="x.md")` → 点击下载
- 数据可以是字符串（自动存为文件）

### ④ st.file_uploader — 上传文件
- `uploaded = st.file_uploader("标签", type=["txt"])`
- `uploaded.read()` 拿到 bytes → `.decode("utf-8")` 转文本
- **坑**：`read()` 第二次会返回空（指针到尾）→ 用 `session_state` 按 `file_id` 缓存

---

## 升级版 streamlit_app.py 做了什么
- 话题 + 类型**并排**（columns）
- 生成后 `st.markdown` 渲染 + `st.download_button` 下载 `.md`
- `session_state.history` 存**本次会话历史**
- `file_uploader` 上传参考素材 → 拼进 prompt（让 AI 读素材再写）

---

## 立即行动
1. 跑：`source venv/bin/activate && streamlit run streamlit_app.py` → 打开 http://localhost:8501
2. 读一遍代码，标出四个组件各自在哪
3. 试：生成两次 → 看底部历史是否累积；上传一个 txt → 看 AI 是否引用
4. **改造题**：给历史加一个「🗑 清空历史」按钮（用 `st.button` + `st.session_state.history = []`）

---

## 下一步 W8-D2
把生成器做成真产品：加 `st.sidebar` 菜单、生成结果可切换「JSON / Markdown」视图、错误用 `st.error` 友好提示。
