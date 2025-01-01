#!/usr/bin/env bash
## shery-1.0.0.sh  脚本库开发    注释必须使用##符号  脚本中字符串不要出现##字符
## shery-1.0.1.sh  统一函数命名  S_动_宾  模式命名
## shery-1.0.2.sh  消除eval命令  统一使用高版本bash支持的declare -n实现
## 主要思想：将所有数据转换为list列表进行处理，如同lua中的table进行各种逻辑实现

## tips
NOWTIME="date +'%Y-%m-%d %H:%M:%S'"
NOWTIPS="echo [$(date +'%Y-%m-%d %H:%M:%S')][PID:$$]"
S_JOB_START(){
    echo "$($NOWTIPS) job_start"
}
S_JOB_SUCCESS(){
    MSG="SUCC: $*"
    echo -e "$($NOWTIPS) job_success:\n[$MSG]"
    exit 0
}
S_JOB_FAILED(){
    MSG="ERROR: $*"
    echo -e "$($NOWTIPS) job_failed:\n[$MSG]"
    exit 1
}
S_JOB_INFO(){
    MSG="INFO: $*"
    echo -e "$($NOWTIPS) job_info:\n[$MSG]"
}
S_JOB_WARN(){
    MSG="WARN: $*"
    echo -e "$($NOWTIPS) job_warn:\n[$MSG]"
}
S_SPLIT_LINE(){
    echo -e "\n=========================================="
    echo -e "==========================================\n"
}

## vars--list
