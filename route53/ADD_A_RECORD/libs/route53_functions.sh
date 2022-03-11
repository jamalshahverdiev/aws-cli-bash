#!/usr/bin/env bash

prepare_ip_struct(){
    if [[ $# -lt 1 ]]; then echo "Usage: $(basename $0) ips_object"; exit 89; fi
    ip_addr=$1
    ip_array+=('{ "Value": "'${ip_addr}'" },')
    echo $ip_array && unset ip_array
}

create_route53_record() {
    if [[ $# -lt 1 ]]; then echo "Usage: $(basename $0) domain_name"; exit 90; fi
    domain_name_input=$1
    for ip in ${ip_list[*]}; do global_array+=$(prepare_ip_struct "${ip}"); done 
    export IP_ADDRESS_LIST=$(echo ${global_array} | sed 's/,$//') 
    export RECORD_DOMAIN_NAME=${domain_name_input}
    cat ${record_json_file} | envsubst > ${temp_record_json_file}
    resource_create_response=$(aws route53 change-resource-record-sets --hosted-zone-id "${zone_id_by_dns_name}" --change-batch file://${temp_record_json_file})
    resource_id=$(echo ${resource_create_response} | jq -r '.ChangeInfo.Id')
    get_record_state_syntax="aws route53  get-change --id $resource_id | jq -r '.ChangeInfo.Status'"
    while [[ ! "$(eval ${get_record_state_syntax})" =~ .*"INSYNC".* ]]; do echo "A record still creating!" && sleep 5; done
    rm ${temp_record_json_file} && unset global_array 
}

collect_instance_ips() {
    unset ip_list
    for instance_id in ${instance_ids}; do
        instance_ip=$(aws ec2 describe-instances --filters \
                "Name=instance-state-name,Values=running" \
                "Name=instance-id,Values=${instance_id}" \
                --query 'Reservations[*].Instances[*].[PrivateIpAddress]' \
                --output text)
        ip_list+=("$instance_ip")
    done
}

execute_all_functions() {
    if [[ $# -lt 2 ]]; then echo "Usage: $(basename $0) asg_contains domain_name"; exit 111; fi
    asg_contains=$1
    record_name=$2
    find_asg_syntax="aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[].AutoScalingGroupName' | jq -r '.[]' | grep ${cluster_name} | grep ${asg_contains}"
    
    while [[ ! "$(eval ${find_asg_syntax})" =~ .*"$asg_contains".* ]]; do echo "Data autoscaling group still creating!" && sleep 5; done
    instance_ids=$(aws autoscaling describe-auto-scaling-groups \
                            --auto-scaling-group-name $(eval ${find_asg_syntax}) | \
                            jq -r '.AutoScalingGroups[].Instances[].InstanceId')
    collect_instance_ips  
    create_route53_record ${record_name}
}