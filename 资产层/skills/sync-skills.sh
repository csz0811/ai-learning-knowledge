#!/bin/bash
#===========================================================
# skill 同步脚本（双端兼容 v1.2，2026-08-20）
# 把知识库里的 skill 源文件同步到各工具的 skill 目录
#
# 使用方法：./sync-skills.sh
# 依赖：rsync（macOS 自带；Windows 需 Git Bash/WSL，纯 PowerShell 不支持 bash）
#
# 路径策略：
#   Mac/Linux  ：默认 ~/Desktop/<知识库>/资产层/skills（可用 KB_HOME 覆盖）
#   Windows    ：读 KB_HOME 环境变量，指向 D 盘知识库根目录
#                回家后 Set：export KB_HOME='/d/你实际的文件夹名' 并写入 ~/.bashrc 永久生效
#===========================================================

# 颜色输出（提前定义，供路径提示使用）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 知识库 skill 源文件目录（双端：OS 检测 + KB_HOME 兜底，不写死任何平台路径）
if [[ "$OS" == "Windows_NT" ]] || [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
    # Windows 端：必须设 KB_HOME（如 /d/AI学习知识库）
    if [ -z "${KB_HOME}" ]; then
        echo -e "${YELLOW}⚠ 未检测到 KB_HOME，Windows 端已用兜底 /d/AI学习知识库。${NC}"
        echo -e "${YELLOW}  请在 Git Bash 执行：export KB_HOME='/d/你实际的文件夹名'，并写入 ~/.bashrc 永久生效。${NC}"
    fi
    SOURCE_DIR="${KB_HOME:-/d/AI学习知识库}/资产层/skills"
else
    # Mac / Linux
    SOURCE_DIR="${KB_HOME:-$HOME/Desktop/AI学习知识库}/资产层/skills"
fi

# 同步目标
OPENCLAW_SKILLS="$HOME/.qclaw/skills"
CLAUDE_CODE_SKILLS="$HOME/.claude/skills"

echo "=========================================="
echo "  skill 同步脚本"
echo "=========================================="
echo ""
echo "源目录: $SOURCE_DIR"
echo ""

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}错误：源目录不存在: $SOURCE_DIR${NC}"
    exit 1
fi

# 列出所有 skill
echo "检测到的 skill："
echo ""
ls "$SOURCE_DIR" | grep -v ".sh$" | grep -v ".md$" | while read skill_name; do
    if [ -d "$SOURCE_DIR/$skill_name" ]; then
        echo "  📦 $skill_name"
    fi
done
echo ""

# 选择同步目标
echo "请选择同步目标："
echo "  1) OpenClaw (QClaw)"
echo "  2) Claude Code"
echo "  3) 全部"
echo ""
read -p "输入选项 [1/2/3]: " choice

case $choice in
    1)
        TARGET_DIR="$OPENCLAW_SKILLS"
        TARGET_NAME="OpenClaw"
        ;;
    2)
        TARGET_DIR="$CLAUDE_CODE_SKILLS"
        TARGET_NAME="Claude Code"
        ;;
    3)
        echo ""
        echo "同步到 OpenClaw..."
        ;;
    *)
        echo -e "${RED}无效选项${NC}"
        exit 1
        ;;
esac

# 同步函数
do_sync() {
    local source="$1"
    local target="$2"
    local name="$3"

    if [ ! -d "$target" ]; then
        echo -e "${YELLOW}目标目录不存在，跳过: $target${NC}"
        return
    fi

    for skill_dir in "$source"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            skill_file="$skill_dir/SKILL.md"

            if [ -f "$skill_file" ]; then
                # 如果目标目录没有这个 skill，创建
                if [ ! -d "$target/$skill_name" ]; then
                    mkdir -p "$target/$skill_name"
                    echo -e "${GREEN}  + 新增 $name/$skill_name${NC}"
                fi

                # 复制 SKILL.md
                cp "$skill_file" "$target/$skill_name/SKILL.md"

                # 同步子目录（references/ 等）
                for subdir in "$skill_dir"*/; do
                    if [ -d "$subdir" ] && [ "$(basename "$subdir")" != "SKILL.md" ]; then
                        subdir_name=$(basename "$subdir")
                        mkdir -p "$target/$skill_name/$subdir_name"
                        cp -r "$subdir"/* "$target/$skill_name/$subdir_name/" 2>/dev/null || true
                    fi
                done

                echo -e "${GREEN}  ✓ 已同步 $name/$skill_name${NC}"
            fi
        fi
    done
}

# 执行同步
if [ "$choice" == "3" ]; then
    echo "同步到 OpenClaw..."
    do_sync "$SOURCE_DIR" "$OPENCLAW_SKILLS" "OpenClaw"
    echo ""
    echo "同步到 Claude Code..."
    do_sync "$SOURCE_DIR" "$CLAUDE_CODE_SKILLS" "Claude Code"
else
    do_sync "$SOURCE_DIR" "$TARGET_DIR" "$TARGET_NAME"
fi

echo ""
echo -e "${GREEN}同步完成${NC}"
echo ""
echo "提示：同步后需要重启对应工具才能加载新 skill"
