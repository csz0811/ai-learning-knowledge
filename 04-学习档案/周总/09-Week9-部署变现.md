---
tags: [W9, 部署, Zeabur, GitHub, 变现]
创建: 2026-08-14
更新: 2026-08-17
关联: [[00-学习路线图]] [[08-Week8-多轮Streamlit]] [[10-Week10-向量库]]
---

# W9｜部署上线与第一次变现

> 状态：✅ 已完成部署（2026-08-17 凌晨）
> 成果：GitHub 仓库 + Zeabur 公网可访问；变现（闲鱼上架）延后

## 一、本周学会了什么
- 把本地 Streamlit 应用部署到公网（任何人可访问）
- GitHub 建仓 + 多平台协同（Zeabur）
- 安全存储 GitHub Personal Access Token（PAT 存 macOS 钥匙串）
- 供应商切换：Streamlit Cloud 停服 → Hugging Face Spaces（配额满）→ **Zeabur（最终方案）**

## 二、GitHub 建仓与凭证管理
### 建仓（命令行）
```bash
# 创建新仓库（不克隆已有）
gh repo create csz0811/ai-content-generator --public

# 克隆到本地
git clone https://github.com/csz0811/ai-content-generator.git
cd ai-content-generator

# 推送现有文件
git add . && git commit -m "init" && git push -u origin main
```

### PAT（Personal Access Token）安全存储
- **不要**硬编码 Token 进代码或配置文件
- macOS：存进钥匙串 `git config --global credential.helper osxkeychain`
- 首次 push 输入一次后永久免密

### .gitignore 必备项
```
venv/
.env           # API Key 绝不能进 git
__pycache__/
*.pyc
```

## 三、部署方案对比
| 方案                  | 状态                      | 结论      |
| :------------------ | :---------------------- | :------ |
| Streamlit Cloud     | 停服                      | ❌ 不可用   |
| Hugging Face Spaces | 配额耗尽（cpu-basic limit=0） | ❌ 暂时不可用 |
| **Zeabur**          | ✅ 可用，免费层够用              | ✅ 当前最优  |

## 四、Zeabur 部署 Streamlit 最小配置
Zeabur 识别 Streamlit 只靠 `requirements.txt` + `streamlit_app.py`（或 `app.py`）。

**目录结构（最简）**：
```
ai-content-generator/
├── app.py                 # Streamlit 主入口（Zeabur 自动识别）
├── content_generator.py   # 核心逻辑
├── requirements.txt       # 依赖列表（锁版本）
└── .env                   # 不上传，Zeabur 环境变量设置
```

**requirements.txt 锁版本**（防新版本不兼容）：
```
openai==3.0.0
python-dotenv==1.2.2
streamlit==1.61.1
```

**不要上传的文件**：
- `.streamlit/config.toml`（本地配置）
- `zeabur.yml`（不需要）
- `.env`（含 API Key）

## 五、部署检查清单
- [x] GitHub 仓库 public 且有 `app.py` / `streamlit_app.py`
- [x] `requirements.txt` 锁版本
- [x] `.env` 已上传（不包含 API Key）
- [x] Zeabur 绑定 GitHub 仓库
- [x] 环境变量设好 `DEEPSEEK_API_KEY`
- [x] 访问公网 URL 测试

## 六、变现延后说明
- 部署已成功，但闲鱼上架需要：
  - 准备好产品介绍文案
  - 定价策略
  - 客服流程
- **不急**：先完成 W10-W12 RAG 学习，再回来做变现（届时技能更完整，产品更好卖）

## 七、踩坑永久记忆
1. **Hugging Face Spaces 配额满**：cpu-basic tier limit=0 → 改 Zeabur
2. **Zeabur 不需要配置文件**：不要自建 `zeabur.yml` / `index.html`，只靠 `requirements.txt` 自动识别
3. **依赖锁版本**：streamlit 新版可能不兼容旧代码，`streamlit==1.61.1` 锁定
4. **`.env` 不上传**：`DEEPSEEK_API_KEY` 存 Zeabur 环境变量，不进 git
5. **macOS 钥匙串存 PAT**：`git config --global credential.helper osxkeychain`

## 📝 复习清单
- [x] GitHub 建仓 + gh CLI
- [x] PAT 存 macOS 钥匙串
- [x] .gitignore 屏蔽 venv/.env
- [x] Zeabur 最小配置：requirements.txt + app.py
- [x] requirements.txt 锁版本
- [x] .env 不上传，Zeabur 环境变量设置

> 🔗 返回：[[00-学习路线图]]｜[[08-Week8-多轮Streamlit]]｜[[10-Week10-向量库]]
