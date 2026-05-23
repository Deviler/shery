#!/bin/bash
## 创建 shery-1.0.1.sh 的最小化版本
## 脚本名称：create_shery-1.0.1-min.sh
## 功能：移除注释、空行和函数定义，生成精简版脚本

# 获取脚本所在目录
SCRIPT_DIR=$(dirname "$0")

# 源文件和目标文件
SOURCE_FILE="${SCRIPT_DIR}/shery-1.0.1.sh"
TARGET_FILE="${SCRIPT_DIR}/shery-1.0.1.min.sh"

# 检查源文件是否存在
if [ ! -f "$SOURCE_FILE" ]; then
    echo "错误: 源文件 $SOURCE_FILE 不存在!"
    exit 1
fi

# 步骤1: 移除所有注释行（以 ## 开头的行）
echo "步骤1: 移除注释行..."
sed "s/##.*//g" "$SOURCE_FILE" > "$TARGET_FILE"

# 步骤2: 移除空行
echo "步骤2: 移除空行..."
sed -i '/^$/d' "$TARGET_FILE"

# 步骤3: 移除只包含空格的行
echo "步骤3: 移除只包含空格的行..."
sed -i '/^[ ]*$/d' "$TARGET_FILE"

# 步骤4: 移除函数定义（匹配函数名后跟括号和大括号的行）
# 注意：这个正则表达式可能不够完善，但基于图片中的模式
echo "步骤4: 移除函数定义..."
sed -i '/^[a-z\_]\+[\(\)]\+[\{]/,/^[}]/d' "$TARGET_FILE"

# 步骤5: 移除剩余的空行
echo "步骤5: 再次移除空行..."
sed -i '/^$/d' "$TARGET_FILE"

# 步骤6: 添加执行权限
chmod +x "$TARGET_FILE"

echo "完成! 已生成最小化脚本: $TARGET_FILE"
echo "原始文件大小: $(wc -l < "$SOURCE_FILE") 行"
echo "精简文件大小: $(wc -l < "$TARGET_FILE") 行"
echo "精简率: $(echo "scale=2; (1 - $(wc -l < "$TARGET_FILE") / $(wc -l < "$SOURCE_FILE")) * 100" | bc)%"
