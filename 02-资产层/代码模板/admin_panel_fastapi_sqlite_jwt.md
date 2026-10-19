# 配方卡：前后端分离后台骨架（FastAPI + SQLite + JWT + 原生前端）

- 场景：需要「多账号登录 + 角色权限 + 数据库增删改查 + 图表」的标准后台系统（财务/订单/内容管理等都适用）
- 依赖：`fastapi uvicorn sqlalchemy pyjwt`（4 个，前端零框架 + ECharts）
- 验证：已在「抖音广告财务后台」（2026-10-17 上线）全量跑通，本卡为核心骨架的 1:1 提炼
- 来源：`01-项目库/抖音广告财务后台/`

## 目录结构

```
项目根/
├── backend/
│   ├── database.py   # 引擎 + 模型 + 密码哈希 + init_db + get_db
│   ├── auth.py       # JWT 生成/解析 + get_current_user + require_admin
│   ├── routers.py    # 所有接口（login + 各资源 CRUD）
│   └── main.py       # app + init_db + 挂前端 + no-cache 中间件
├── frontend/
│   ├── index.html / style.css / app.js   # 原生前端
│   └── echarts.min.js                    # 本地化，不依赖 CDN
└── requirements.txt
```

## 完整可跑骨架（核心四文件）

### database.py

```python
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime
import hashlib, os

# 🔴 路径固定到脚本所在目录（相对路径会随启动 cwd 乱跑）
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "app.db")
engine = create_engine(f"sqlite:///{DB_PATH}", connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()

def hash_password(p: str) -> str:
    salt = os.urandom(16).hex()
    return salt + "$" + hashlib.pbkdf2_hmac("sha256", p.encode(), salt.encode(), 100000).hex()

def verify_password(p: str, stored: str) -> bool:
    salt, h = stored.split("$", 1)
    return hashlib.pbkdf2_hmac("sha256", p.encode(), salt.encode(), 100000).hex() == h

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    password_hash = Column(String)
    role = Column(String, default="viewer")   # admin / viewer

class Item(Base):
    __tablename__ = "items"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    amount_cents = Column(Integer, default=0)  # 🔴 金额按「分」存，避免浮点误差
    created_at = Column(DateTime, default=datetime.utcnow)

def init_db():
    Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### auth.py

```python
import jwt
from datetime import datetime, timedelta
from fastapi import Depends, HTTPException, Header

SECRET_KEY = "change-me-in-production"   # 🔴 上线前必换
ALGORITHM = "HS256"

def create_token(username: str, role: str) -> str:
    payload = {"sub": username, "role": role,
               "exp": datetime.utcnow() + timedelta(days=7)}
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

def get_current_user(authorization: str = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(401, "未登录")
    try:
        payload = jwt.decode(authorization[7:], SECRET_KEY, algorithms=[ALGORITHM])
    except jwt.InvalidTokenError:
        raise HTTPException(401, "登录已过期")
    return {"username": payload["sub"], "role": payload["role"]}

def require_admin(user=Depends(get_current_user)):
    if user["role"] != "admin":
        raise HTTPException(403, "无权限，仅管理员可操作")
    return user
```

### routers.py（登录 + 一个带权限的 CRUD 示例）

```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from database import get_db, User, Item, hash_password, verify_password
from auth import create_token, get_current_user, require_admin

router = APIRouter()

class LoginReq(BaseModel):
    username: str
    password: str

class ItemReq(BaseModel):
    name: str
    amount_cents: int = 0

@router.post("/api/login")
def login(req: LoginReq, db: Session = Depends(get_db)):
    user = db.query(User).filter_by(username=req.username).first()
    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(401, "账号或密码错误")
    return {"token": create_token(user.username, user.role),
            "username": user.username, "role": user.role}

@router.get("/api/items")
def list_items(db: Session = Depends(get_db), user=Depends(get_current_user)):
    return [{"id": i.id, "name": i.name, "amount_cents": i.amount_cents}
            for i in db.query(Item).all()]

@router.post("/api/items")
def create_item(req: ItemReq, db: Session = Depends(get_db), user=Depends(require_admin)):
    obj = Item(**req.model_dump())
    db.add(obj); db.commit(); db.refresh(obj)
    return {"id": obj.id}
```

### main.py

```python
from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
import os
from database import init_db
from routers import router

app = FastAPI(title="后台")
init_db()
app.include_router(router)

# 🔴 前端不缓存：避免改版后浏览器仍用旧页面
@app.middleware("http")
async def no_cache(request: Request, call_next):
    resp = await call_next(request)
    ctype = resp.headers.get("content-type", "")
    if "text/html" in ctype or "javascript" in ctype:
        resp.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    return resp

app.mount("/", StaticFiles(directory=os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "..", "frontend"), html=True), name="frontend")
```

## 注意事项（🔴 每条都是踩过的坑）

1. **🔴 金额一律整数「分」存**：`amount_cents`，展示时 `÷100` 格式化。浮点数算钱必出 0.01 级误差，财务对账对不上。
2. **🔴 DB 路径用 `os.path.abspath(__file__)` 固定**：写 `sqlite:///app.db` 相对路径会随 `uvicorn --app-dir` 的启动 cwd 乱跑，删库删错地方。
3. **🔴 无默认账号 + 首次初始化**：不预置 `admin/admin123`，谁都能登；第一次打开让用户自设管理员（加一个 `/api/init` 只在用户表为空时可用）。
4. **🔴 字典软删除（is_active）**：有历史记录的枚举项（类别/平台/账号）禁止物理删除，只「停用」，保护历史账目。
5. **🔴 账变日志不可删改**：多人共用账本，每次写操作自动记「谁/何时/做了什么」，只增不改。
6. **🔴 登录加验证码**：纯 SVG 生成（零依赖），一次性 + 5 分钟过期防重放，防暴力破解。
7. **🔴 前端加 `Cache-Control: no-cache`**：否则改版后用户看到的还是缓存旧页面（曾因此被误报 bug）。
8. **前端响应式**：`@media (max-width: 640px)` 表单单列；输入框字号 ≥16px 防 iOS 聚焦自动放大；金额框加 `inputmode="decimal"`（iOS 数字键盘竖屏无小数点）。
9. **角色检查放后端**：`require_admin` 依赖注入，前端隐藏按钮只是体验，真正的权限在后端 403 兜底。
