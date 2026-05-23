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
S_SPLIT_VARS_TO_LIST(){
    ## vars--list
    ##将变量分割成列表，默认分隔符为英文逗号
    local i=0; local OLDIFS=$IFS; IFS=','
    for line in $(echo "${1}"); do
        eval ${2}["${i}"]="${line}"
        i=$((i+1))
    done
    IFS=$OLDIFS
}
S_APPEND_LIST(){
    ##增加列表行数据内容
    local length=$(eval echo "\${#${1}[@]}")
    eval ${1}["${length}"]='${2}[*]'
}
S_APPEND_ROWDATA_LIST(){
    ##增加列表行数据内容
    local length=$(eval echo "\${#${1}[@]}")
    eval ${1}["${length}"]='${2}[*]'
}
S_APPEND_COLDATA_LIST(){
    ##增加列表列数据内容
    local i
    for ((i=0; i<$(eval echo "\${#${1}[@]}"); i++)); do
        rowdata=$(eval echo "\${$1[${i}]} \${$2[*]}")
        eval ${1}["${i}"]='${rowdata}'
    done
}
S_CUT_SEMI_LIST(){
    ##剪切行尾行数据中的分号
    local i
    for ((i=0; i<$(eval echo "\${#${1}[@]}"); i++)); do
        rowdata=$(eval echo "\${$1[${i}]}")
        rowdata=$(echo ${rowdata} | sed "s/;[ ]*$//g")
        eval ${1}["${i}"]='${rowdata}'
    done
}
S_ADD_SEMI_LIST(){
    ##增加行数据行尾分号 （参数1：name--列表名）
    local i
    for ((i=0; i<$(eval echo "\${#${1}[@]}"); i++)); do
        rowdata=$(eval echo "\${$1[${i}]}")
        $(echo ${rowdata} | grep -q "^[ ]*$") || $(echo ${rowdata} | grep -q "^[ ]*";)
        case "${?}" in
            0) ;;
            *)
                rowdata=$(eval echo "\${$1[${i}]};")
        esac
        eval ${1}["${i}"]='${rowdata}'
    done
}
S_SHOW_LIST(){
    ##展示列表内容（参数1：name--列表名）
    local i
    for ((i=0; i<$(eval echo "\${#${1}[@]}"); i++)); do
        eval echo "\${$1[${i}]}"
    done
}
S_EXEC_RESULT(){
    ##执行语句结果存入列表 （参数1：exec_cmd--执行命令 参数2：exec_result--存储变量--默认类型数组）
    OLDIFS=$IFS && IFS=$'\n'; local i=0
    for line in $(eval echo "\${${1}[*]}"); do
        eval ${2}["${i}"]='${line}' 
        i=$((i+1))
    done
    IFS=$OLDIFS
}
S_LIST_MATCH_SUM(){
    ##统计列表中匹配内容的行数 (参数1：name--列表名 参数2：string--匹配内容)
    declare -n list_ref=${1}
    local i
    for ((i=0; i<${#list_ref[*]}; i++)); do
        echo ${list_ref[${i}]}
    done
}
## math
S_RANDOM_NUMBER(){
    ##生成随机数 (参数1：min--最小值 参数2：max--最大值) (参数1：max--最大值) (参数2：无--随机抽取)
    case "${2}" in
        "")
            case "${1}" in
                "") echo "$RANDOM";;
                *) echo $((0 + $RANDOM % $((1-0))));;
            esac
        ;;
        *) echo $((${1} + $RANDOM % (${2}-${1})));;
    esac
}
S_RANDOM_NUMBER_PLUS(){
    ##生成随机数(超大范围随机) (参数1：min--最小值 参数2：max--最大值) (参数1：max--最大值) (参数：无--随机抽取)
    RANDOM_PLUS=$(head -20 /dev/urandom | cksum | cut -f1 -d" ")
    case "${2}" in
        "")
            case "${1}" in
                "") echo "$RANDOM_PLUS";;
                *) echo $((0 + $RANDOM_PLUS % (${1}-0)));;
            esac
        ;;
        *) echo $((${1} + $RANDOM_PLUS % (${2}-${1})));;
    esac
}
S_RANDOM_STRING(){
    ##生成随机字符串 (参数1：length--长度) (参数：无--随机长度)
    case "${1}" in
        "") echo "$(tr -dc A-Za-z0-9 </dev/urandom | head -c $RANDOM ; echo '')";;
        *) echo "$(tr -dc A-Za-z0-9 </dev/urandom | head -c $1 ; echo '')";;
    esac
}
## time
S_TIME_START(){
    ##方法开始时间标记
    starttime=$(date +'%Y-%m-%d %H:%M:%S'); start_seconds=$(date --date="$starttime" +%s)
    echo -e "========== Start <${FUNCNAME[1]}> $(date +'%Y-%m-%d %H:%M:%S') 当前进程号$BASHPID"
}
S_TIME_END(){
    ##方法结束时间标记
    endtime=$(date +'%Y-%m-%d %H:%M:%S'); end_seconds=$(date --date="$endtime" +%s)
    echo "$(date +'%Y-%m-%d %H:%M:%S') | [ $((end_seconds - start_seconds)) ] | ${FUNCNAME[1]} | 当前进程号$BASHPID |"
    echo -e "========== Complete <${FUNCNAME[1]}> $(date +'%Y-%m-%d_%H:%M:%S') 当前进程号$BASHPID \t\n"
}
## string
## json
## curl
S_CURL_EXECUTE(){
    ##执行curl命令 (参数1：domain--域名--含http前缀 参数2：interface--接口 参数3：method--请求类型 参数4：token--认证 参数5)
    eval curl -s -X ${3} ${1}${2} -H "Authorization: Bearer ${4}" -H 'accept: application/json' -H 'Content-Type: application/x-www-form-urlencoded'
}
## file
S_JUDGE_FILE(){
    ##判断文件类型状态 (参数1：file--文件路径) (返回：判断结果--exist/notexist/dir/link/empty/text/tarfile/zipfile--字符串)
    case "$(file -b "${1}")" in
        *No\ such*) echo "notexist";;
        *directory*) echo "dir";;
        *symbolic*) echo "link";;
        *empty*) echo "empty";;
        *text*) echo "text";;
        *tar*) echo "tarfile";;
        *Zip*) echo "zipfile";;
        *) echo "other";;
    esac
}
S_LIST_TO_FILE(){
    ## shell变量按行导出至文件内容 (参数1：list--存储变量--默认类型数组 参数2：file--文件路径)
    local i
    case $(S_JUDGE_FILE "${2}") in
        text|notexist|empty)
            mkdir -p $(dirname ${2})
            truncate -s 0 ${2}
            for ((i=0; i<$(eval echo "\${#${1}[@]}"); i++)); do
                eval echo "\${$1[${i}]}" >> ${2}
            done
        ;;
        *)
            S_JOB_FAILED "shell变量按行导出至文件内容 $1 --> $2 失败! 原因为：$(S_JUDGE_FILE "${2}")";
        ;;
    esac
}
S_FILE_TO_LIST(){
    ## 文件内容按行导入shell变量 (参数1：file--文件路径 参数2：list--存储变量--默认类型数组)
    case $(S_JUDGE_FILE "${1}") in
        text)
            OLDIFS=$IFS && IFS=$'\n'; local i=0
            for line in $(cat ${1} | grep -v "^$"); do
                eval ${2}["${i}"]='${line}'
                i=$((i+1))
            done
            IFS=$OLDIFS
        ;;
        *)
            S_JOB_FAILED "文件内容按行导入shell变量 $1 --> $2 失败! 原因为：$(S_JUDGE_FILE "${1}")";
        ;;
    esac
}
S_FILE_TO_LIST_BASE64(){
    ## 文件内容导入编码为base64至shell变量 (参数1：file--文件路径 参数2：list--存储变量--默认类型数组)
    case $(S_JUDGE_FILE "${1}") in
        text)
            eval ${2}="$(cat ${1} | grep -v "^$" | base64 | tr -d '\n')"
        ;;
        *)
            S_JOB_FAILED "文件内容按行导入shell变量 $1 --> $2 失败! 原因为：$(S_JUDGE_FILE "${1}")";
        ;;
    esac
}
## flow
S_LIST_EXEC(){
    ## 执行列表中内容 (参数1：list--执行内容--列表存储)
    ## cmd快速添加方法：
    ## exec_cmd=(
    ##       "echo ababababab ELEMENT"
    ##       "echo bababababababababab"
    ##       )
    ## 转成一行执行，以英文分号';'分隔，存在'$'符号应使用转义符号'\'进行转义'\$'
    ## 在主脚本中执行的变量则不需进行转义
    S_CUT_SEMI_LIST ${1} && S_ADD_SEMI_LIST ${1}
    eval echo "\${$1[*]}" | awk '{run=$0;system(run)}'
}
S_MULTI_EXEC(){
    ## 并发执行列表中内容 (参数1：list--并发到方)
    echo "并发执行功能待实现"
}
S_MULT_EXEC(){
    ## 并发执行列表中内容 (参数1: list--并发列表 参数2: num--并发数量 参数3: exec_cmd--并发执行内容--列表存储)
    local i thread_num tempfifo
    thread_num=$2; tempfifo="my_temp_fifo"; mkfifo ${tempfifo}; exec 6<>${tempfifo}; rm -f ${tempfifo};
    for ((i=1; i<=$thread_num; i++)); do echo; done >&6
    for ((i=0; i<$(eval echo "\${#${1}[@]}"); i++)); do
        read -u6
        {
            element=$(eval echo "\${${1}[${i}]}")
            execcmd=$(eval echo "\${${3}[@]}")
            S_CUT_SEMI_LIST ${3} && S_ADD_SEMI_LIST ${3}
            eval echo "\${${3}[*]}" | sed 's/ELEMENT/'${element}'/g' | awk '{run=$0;system(run)}'
            echo >&6
        } &
    done
    wait
    exec 6>&-
}
S_MULT_SAME_EXEC(){
    ## 并发执行相同内容 (参数1: sum--并发总数 参数2: num--并发数量 参数3: exec_cmd--并发执行内容--列表存储)
    local i thread_num tempfifo
    thread_num=$2; tempfifo="my_temp_fifo"; mkfifo ${tempfifo}; exec 6<>${tempfifo}; rm -f ${tempfifo};
    for ((i=1; i<=$thread_num; i++)); do echo; done >&6
    for ((i=0; i<${1}; i++)); do
        read -u6
        {
            element=$(eval echo "\${${3}[${i}]}")
            execcmd=$(eval echo "\${${3}[@]}")
            S_CUT_SEMI_LIST ${3} && S_ADD_SEMI_LIST ${3}
            eval echo "\${${3}[*]}" | sed 's/ELEMENT/'${element}'/g' | awk '{run=$0;system(run)}'
            echo >&6
        } &
    done
    wait
    exec 6>&-
}
## ssh
S_TELNET_CHECK(){
    ##检查目标机器和端口是否连通（参数1：host--目标机器IP 参数2：port--目标机器端口）
    telnet_result=$(sleep 0 | telnet $1 $2 | grep Escape)
    echo ${telnet_result}
    sleep 1; case "${telnet_result}" in
        Connected*) echo "telnet $1 $2 success";;
        Escape*) echo "telnet $1 $2 success";;
        *) echo "telnet $1 $2 failed";;
    esac
}
S_SSHX_EXEC(){
    ##远程执行列表中内容（参数1：account--目标用户和IP--user@host 参数2：list--执行内容--列表存储）
    S_CUT_SEMI_LIST ${2} && S_ADD_SEMI_LIST ${2}
    eval echo 'ssh -q ${1}' "\"\${${2}[*]}\"" | awk '{run=$0;system(run)}'
}
S_SSHX_RESULT(){
    ##远程执行语句结果存入列表（参数1：account--目标用户和IP--user@host 参数2：sshx_cmd--执行命令 参数3：sshx_result--存储变量--默认类型数组）
    S_CUT_SEMI_LIST ${2} && S_ADD_SEMI_LIST ${2}
    OLDIFS=$IFS && IFS=$'\n'; local i=0
    for line in $(eval echo 'ssh -q ${1}' "\"\${${2}[*]}\"" | awk '{run=$0;system(run)}'); do
        eval ${3}["${i}"]='${line}' 
        i=$((i+1))
    done
    IFS=$OLDIFS
}
S_SSHX_MKDIR_EXPECT(){
    ##创建远端目录（参数1：account--目标用户和IP--user@host 参数2：sshx_dir--远端目录 参数3：passwd--认证）
    echo "----[$(bash -c "${NOWTIME}")] 创建远端目录: ${1} ${2}"
    /usr/bin/expect <<-EOF
    set timeout 30
    spawn ssh ${1}
    expect {
        "*yes/no" { send "yes\r"; exp_continue }
        "*password:" { send "${3}\r" }
        "*@" { send "hostname -I\r" }
    }
    expect "*@*"
    send "mkdir -p ${2}\r"
    expect "*@*"
EOF
}
S_SCP_UPLOAD_FILE_EXPECT(){
    ##同步文件至远端 (参数1：account--目标用户和IP--user@host 参数2：sshx_file--同步文件名)
    echo "----[$(bash -c "${NOWTIME}")] 同步文件至远端目录：${1} ${2} /tmp/shery-file-${1%*}/$(date +%Y%m%d)/"
    /usr/bin/expect <<-EOF
    set timeout 30
    spawn scp ${2} ${1}:/tmp/shery-file-${1%*}/$(date +%Y%m%d)/
    expect {
        "*yes/no" { send "yes\r"; exp_continue }
        "*password:" { send "${3}\r" }
    }
    expect "*@*"
EOF
}
S_SCP_UPLOAD_EXPECT_WITHLOG(){
    ##同步文件至远端 (参数1：account--目标用户和IP--user@host 参数2：sshx_file--同步文件名)
    echo "----[$(bash -c "${NOWTIME}")] 同步文件至远端目录：${1} ${2} /tmp/shery-file-${1%*}/$(date +%Y%m%d)/"
    /usr/bin/expect <<-EOF
    set timeout 15
    log_user 0
    log_file -a ${4}
    spawn scp ${2} ${1}:/tmp/shery-file-${1%*}/$(date +%Y%m%d)/
    expect {
        "*yes/no" { send "yes\r"; exp_continue }
        "*password:" {
            send "${3}\r"
            expect "*@*"
        }
    }
EOF
}
S_SSHX_EXEC_EXPECT(){
    ##触发远端执行脚本
    ## 参数1：account--目标用户和IP--user@host
    ## 参数2：sshx_file--执行脚本文件名
    set timeout 30
    spawn ssh ${1}
    expect {
        "*yes/no" { send "yes\r"; exp_continue }
        "*password:" {
            send "${3}\r"
            expect {
                "*denied*" { puts "密码错误，退出! "; exit 1 }
                "*@*" { send "sh ${2}\r" }
            }
        }
        "*@*" { send "hostname -I; sh ${2}\r" }
    }
EOF
}
S_SSHX_EXEC_EXPECT_WITHLOG(){
    ##触发远端执行脚本
    ## 参数1：account--目标用户和IP--user@host
    ## 参数2：sshx_file--执行脚本文件名
    echo "----[$(bash -c "${NOWTIME}")] 触发远端执行脚本：${1} ${2}"
    /usr/bin/expect <<-EOF
    set timeout 15
    log_user 0
    log_file -a ${4}
    spawn ssh ${1}
    expect {
        "*yes/no" { send "yes\r"; exp_continue }
        "*password:" { 
            send "${3}\r"
            expect {
                "*denied*" { puts "密码错误，退出! "; exit 1 }
                "*@*" { send "sh ${2}; echo \$? > ${2}.result\r" }
            }
        }
        "*@*" { send "hostname -I; sh ${2}; echo \$? > ${2}.result\r" }
    }
    expect "*@*"
    send "\r"
    expect "*@*"
EOF
}
S_SSHX_EXEC_EXPECT_WITHPARAM(){
    ##触发远端执行脚本，带参数文件
    ## 参数1：account--目标用户和IP--user@host
    ## 参数2：sshx_file--执行脚本文件名
    ## 参数5：参数文件
    echo "----[$(bash -c "${NOWTIME}")] 触发远端执行脚本，带参数文件：${1} ${2} ${5}"
    /usr/bin/expect <<-EOF
    set timeout 300
    log_user 0
    log_file -a ${4}
    spawn ssh ${1}
    expect {
        "*yes/no" { send "yes\r"; exp_continue }
        "*password:" {
            send "${3}\r"
            expect {
                "*denied*" { puts "密码错误，退出! "; exit 1 }
                "*@*" { send "sh ${2} \$(dirname ${2})/${5}; echo \$? > ${2}.result\r" }
            }
        }
        "*@*" { send "hostname -I; sh ${2} \$(dirname ${2})/${5}; echo \$? > ${2}.result\r" }
    }
    expect "*@*"
    send "\r"
    expect "*@*"
EOF
}
S_SSHX_RESULT_EXPECT(){
    ##获取远端执行结果
    ## 参数1：account--目标用户和IP--user@host
    ## 参数2：sshx_file--执行文件
    ## 参数3：password--密码
    ## 参数4：result_file--本地存放执行结果文件--优先使用绝对路径
    ## 参数5：result_list--存储结果列表
    ## 未简化参数传递，获取远端执行结果，暂未将expect内容打印至日志
    echo "----[$(bash -c "${NOWTIME}")] 获取远端执行结果：${1} ${2}"
    local result_code
    declare -n list_ref=${5}
    local length=$(echo ${#list_ref[@]})
    /usr/bin/expect <<-EOF
    set timeout 15
    log_user 0
    spawn scp ${1}:${2} ${4}
    expect {
        "*yes/no" { send "yes\r"; exp_continue }
        "*password:" {
            send "${3}\r"
            expect "*@*"
        }
    }
EOF
    result_code=$(cat ${4})
    echo ${result_code}
    S_JOB_INFO "当前实例：${1} 执行结果码为：${result_code}"
    case "${result_code}" in
        0)
            list_ref[${length}]="[${1} result_code:${result_code} Success]"
        ;;
        *)
            list_ref[${length}]="[${1} result_code:${result_code} Failed]"
        ;;
    esac
}
## security
S_ENCODE_BASE64_WITH_FREQ(){
    ##加密列表内容 （参数1：input--待加密内容--优先使用list存储 参数2：output--加密输出文件）
    local input cipher i num output
    input=$(eval echo "\${$1}")
    output=${2}
    cipher=$(echo ${input} | grep -v "^$" | base64 | tr -d '\n')
    num=$(S_RANDOM_NUMBER 2 5)
    for ((i=1; i<=${num}; i++)); do
        cipher=$(echo ${cipher} | grep -v "^$" | base64 | tr -d '\n')
    done
    S_LIST_TO_FILE cipher ${output}
    echo ${num} >> ${output}
}
S_DECODE_BASE64_WITH_FREQ(){
    ##解密列表内容 （参数1：input--待解密内容--上一步加密文件 参数2：output--解密结果变量名）
    local input list cipher plain output
    input=${1}
    output=${2}
    S_FILE_TO_LIST ${input} list
    cipher=${list[0]}
    num=${list[1]}
    plain=$(echo ${cipher} | base64 -d)
    for ((i=1; i<=${num}; i++)); do
        plain=$(echo ${plain} | base64 -d)
    done
    eval ${output}='${plain}'
}
