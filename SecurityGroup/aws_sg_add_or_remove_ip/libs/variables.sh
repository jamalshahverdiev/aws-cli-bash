#!/usr/bin/env bash

region_name='us-east-1'
input_mode=$1
sg_name=$2
env_name=$3

if [[ ${env_name} == 'prod' ]]; then
    ip_address_file='ip_prod.txt' && AWS_PROFILE='ihs_prod_admin'
elif [[ ${env_name} == 'nonprod' ]]; then
    ip_address_file='ip_nonprod.txt' && AWS_PROFILE='ihs_nonprod_admin'
else    
    echo "Environment argument can be only 'prod' or 'nonprod'" && exit 77
fi

if [[ -z ${AWS_PROFILE} ]]; then echo "Varialbe 'AWS_PROFILE' cannot be empty. Please set and continue."; exit 100; fi
security_groups_object=$(aws ec2 describe-security-groups --region ${region_name})
all_security_group_names=$(echo $security_groups_object | jq -r '.SecurityGroups[].GroupName')
get_all_ips_by_security_group=$(echo $security_groups_object | \
    jq -r '.SecurityGroups[]|select(.GroupName=="'$sg_name'").IpPermissions[].IpRanges[].CidrIp' | \
    awk -F'/' '{ print $1 }')