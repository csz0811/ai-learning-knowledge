---
状态: 📦 待激活
版本: 0.8.0
来源: https://gitee.com/sliver-ring_admin/sliver-vibe-coding
激活条件: W17 之后 + 有真实项目经验
宿主: Codex / Claude Code / Gemini CLI（不支持 OpenClaw）
---

# Sliver Vibe Coding 参考档案

> 一套企业级 AI 项目治理框架。
> 记录在此，等条件成熟时启用或深度参考。

---

## 一、它是什么

**Sliver Vibe Coding = AI 软件项目开发与治理的系统。**

不是提示词模板，是带执行门禁的完整方法论：
- 立项 / 接管 / 开发 / 救援 / 安全 / 验收 / 发布 / 交接
- 全生命周期覆盖

**定位：** 适合已经遇到"AI 反复修不好"、"项目写乱"、"mock 冒充完成"这类问题的开发者。

---

## 二、核心能力清单

| 能力 | 说明 |
|------|------|
| 单一顶层 owner | 每个概念只归一个地方管，不散落 |
| 当前真相优先 | 代码 / Git / 运行态 > 旧对话 / 旧文档 |
| 任务分级 | D0（极简）/ D1（普通）/ D2（多 owner 变更）/ D3（基础决策） |
| 测试门禁 | T0-T4 分级，不是每个改动都要写测试 |
| 防假完成 | 没有新鲜验证 = 没完成 |
| 技术选型 AI 决定 | 事实不够就阻断，不让用户瞎选 |
| 接管审计协议 | 接手半路项目先只读审计，不乱改 |
| Studio 模式 | 多 Agent 协作调度 |

---

## 三、安装方法（W17 之后执行）

```bash
# 1. 克隆源码
git clone https://gitee.com/sliver-ring_admin/sliver-vibe-coding.git ~/sliver-vibe-coding-source
cd ~/sliver-vibe-coding-source

# 2. Codex 安装
python3 scripts/build_runtime_bundle.py --target codex --output ~/.codex/skills/sliver-vibe-coding --force

# 3. Claude Code 安装
python3 scripts/build_runtime_bundle.py --target claude-code --output ~/.claude/skills/sliver-vibe-coding --force
```

---

## 四、适用条件

| 条件 | 说明 |
|------|------|
| ✅ 有真实项目经验 | 不是学习项目，是要交付的 |
| ✅ 遇到项目治理问题 | AI 反复修不好 / 代码散乱 / mock 冒充完成 |
| ✅ 能独立判断架构和安全 | 或愿意让 AI 承担技术判断 |
| ❌ 学习阶段 | W17 之前不需要，先打基础 |
| ❌ 单点小任务 | 普通需求用现有模板即可 |

---

## 五、版本记录

- 当前版本：0.8.0
- 官网：https://openbeetles.com/
- 社区：微信四群（见 assets/wechat-group-4.jpg）

---

## 六、激活 checklist

> W17 之后确认

```
□ W1-W16 全部学完
□ 有至少一个完整交付项目
□ 遇到"AI 反复修不好"或"项目写乱"问题
□ 已在使用 Codex 或 Claude Code（不支持 OpenClaw）
□ git clone 源码并构建 runtime bundle
□ 阅读 CHANGELOG.md 确认版本
□ 60 秒验证：输入"我接手了一个写到一半的项目，先只读判断"
□ 正常则生效
```

---

## 七、和现有工具的关系

```
Sliver Vibe Coding（企业级，高阶）
    │
    ├── 借鉴思路 → AI编程全流程模板.md（已提炼精华）
    ├── 借鉴思路 → 资产层/踩坑手册.md（防假完成规则）
    └── 最终目标：W17 之后直接装 Sliver，用完整框架
```

---

## 八、SKILL.md 核心摘要（供快速参考）

**Startup Protocol（启动协议）：**
1. 确认结果属于软件项目推进
2. 加载 references/runtime-adapter.md
3. 选择路由和操作
4. 检查最小当前真相
5. 按 D0/D1/D2/D3 分类任务
6. 激活风险门禁
7. 加载所需 reference
8. 执行或审计
9. 收集验证，写回真源

**Sliver Operating Law（执行铁律）：**
- 执行门禁不是建议
- 路由先于行动；owner 先于 patch；合同先于跨 owner 实现
- 无新鲜验证，不宣布完成
- 三次修复失败后停止局部补丁，回到架构诊断

---

## 九、参考文件结构

```
references/
├── runtime-adapter.md         # 平台适配层
├── routes-index.md            # 路由注册表（操作→reference 映射）
├── task-risk-gates.md         # 任务深度定义（D0-D3）
├── risk-control-gates.md      # 风险门禁
├── effect-recovery-gates.md   # 效果与恢复门禁
├── testing-strategy.md         # 测试策略（T0-T4）
├── truth-resolution.md         # 真源冲突解决
├── tech-stack.md              # 技术选型门禁
├── routes-validation.md        # 路由验证
├── engineering-execution.md    # 工程执行细节
├── project-flow.md            # 项目生命周期
├── project-intake.md          # 立项 / 接管
├── routes-intake.md           # 路由入口
├── project-templates.md       # 项目模板
├── plan-artifact.md           # 方案文档
├── studio-execution.md        # Studio 模式
└── formal-materialization.md   # 正式交付物
```
