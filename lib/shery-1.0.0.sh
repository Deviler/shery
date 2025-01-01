#!/usr/bin/env bash
## shery-1.0.0.sh  脚本库开发    注释必须使用##符号  脚本中字符串不要出现##字符
## shery-1.0.1.sh  统一函数命名  S_动_宾  模式命名
## shery-1.0.2.sh  消除eval命令  统一使用高版本bash支持的declare -n实现
## 主要思想：将所有数据转换为list列表进行处理，如同lua中的table进行各种逻辑实现

## tips
NOWTIME="date +'%Y-%m-%d %H:%M:%S'"; NOW="echo [\`$NOWTIME\`][PID:$$]"
S_JOB_START(){
    echo "`eval $NOW` job_start"
}