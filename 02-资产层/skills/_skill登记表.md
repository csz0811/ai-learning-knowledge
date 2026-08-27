# Skill 登记表

> 规则（知识库结构说明第六节 v1.2）：新增 skill 同步登记——名称 / 功能一句话 / 适用方 / 来源 / 日期 / 状态
> 适用方：教学讲解类→小舟；架构审查沟通类→小舟；写码编程类→Codex；通用→全部；用户自用→用户
> 装任何第三方 skill 本体前，先过 SkillSpector 扫描（安全闸）

| 名称 | 功能一句话 | 适用方 | 来源 | 日期 | 状态 |
|---|---|---|---|---|---|
| sync-skills.sh | 把知识库 skill 源文件同步到各工具目录（Mac 写死路径，Windows 待改造） | 小舟 | 知识库自建 | 2026-08-20 | ✅ 在用 |
| skill防滥用指南.md | 写 skill 描述的规则（防误触发/防乱用） | 小舟 | 知识库自建 | 2026-08-19 | ✅ 在用 |
| SkillSpector | 装第三方 skill 前的安全扫描器（64+ 漏洞模式，0-100 风险分） | 小舟/通用 | NVIDIA 官方 GitHub | 2026-08-27 | 🟢 已装（2026-08-27） |
| OpenAI Skills Catalog | skill 机制知识档案（Codex 官方范式） | 小舟 | openai/skills | 2026-08-27 | 📚 知识档案（不装本体） |
| Anthropic Skills | skill 写法知识档案（Claude 官方范式） | 小舟 | anthropics/skills | 2026-08-27 | 📚 知识档案（不装本体） |
| Superpowers | 「规划-执行-复盘」方法论增强包知识档案 | 小舟 | obra/superpowers | 2026-08-27 | 📚 知识档案（不装本体） |
| vibe-coding-cn | 中文 Vibe Coding 教程仓知识档案 | 小舟 | tukuaiai/vibe-coding-cn | 2026-08-27 | 📚 知识档案（不装本体） |
| Vibe Coding 雷达站 | 每周项目+skill 榜单信源 | 小舟 | radar.lyihub.com | 2026-08-27 | 📚 信源登记 |

## 状态说明

- 🟢 已装：本体已装入工具链，可调用
- 📚 知识档案：不装本体，知识在 `skill生态知识档案.md`，永久可查
- ⚫ 已砍：评估后决定不装（原因见 skill评估登记表 E 类）
- 🟡 观察：条件成熟再评估（见 skill评估登记表 D 类）

## 相关文件

- `skill生态知识档案.md` —— B 类 5 项详细档案
- `skill防滥用指南.md` —— 写 skill 描述的反滥用规则
- `sync-skills.sh` —— 同步脚本（Windows 适配待改造，见结构说明第六节）
- 完整评估过程：`D:\workbody\2026-08-19-13-35-10\personal-workbench\docs\skill评估登记表.md`
