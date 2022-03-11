#!/usr/bin/env bash

create_log_group(){
    if [[ $# != 1 ]]; then echo "Usage: ./$(basename $0) log_group_name"; exit 21; fi
    log_group_name=$1
    create_log_group_result=$(aws logs create-log-group \
        --log-group-name ${log_group_name} \
        --region ${region_name})
    # echo ${create_log_group_result}
}

collect_log_group_names() {
    collect_lg_result=$(aws logs describe-log-groups \
        --region ${region_name} | jq -r '.logGroups[].logGroupName')
    echo ${collect_lg_result}
}