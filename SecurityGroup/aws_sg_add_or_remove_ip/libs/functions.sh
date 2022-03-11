#!/usr/bin/env bash

remove_ip_from_sg_validate_template() {
    if [[ $# != 1 ]]; then echo "Usage: remove_ip_from_sg_validate_template ip.address.to.remove"; exit 20; fi
    ip_addr_input=$1
    result_of_delete=$(aws ec2 revoke-security-group-ingress \
        --group-id ${sg_id} \
        --ip-permissions IpProtocol=all,IpRanges="[{CidrIp=${ip_addr_input}/32}]" | \
        jq '.Return')
    if [[ ${result_of_delete} == 'true' ]]; then
        echo "IP address ${ip_addr_input} deleted from access list."
        sed -i "/${ip_addr_input}/d" ${ip_address_file} > /dev/null
    fi
}

check_security_group_exists(){
    if [[ "$all_security_group_names" == *"$sg_name"* ]]; then
        sg_id=$(echo $security_groups_object | jq -r '.SecurityGroups[]|select(.GroupName=="'$sg_name'").GroupId')
        echo "Security group $sg_name with ${sg_id} id exists in AWS."
        all_ips_database=$(cat ${ip_address_file})
        for ip_address in ${get_all_ips_by_security_group}; do
            if ! [[ "$all_ips_database" =~ .*"$ip_address".* ]]; then
                remove_ip_from_sg_validate_template ${ip_address}
            fi
        done
        echo "Security group $sg_name syncronized with ${ip_address_file} file."
    else
        echo "Security group ${sg_id} doesn't exists in AWS. Please input right value of Security group."
        exit 101
    fi
}

check_input_variable () {
    if [[ $# != 1 ]]; then echo "Usage: check_input_variable ip_address_to_validate"; exit 20; fi
    ip_addr_input=$1
    if [[ -z $check_input_variable ]]; then
        if [[ $ip_addr_input =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "IP address ${ip_addr_input} is valid"
        else
            echo "Please enter valid IP adresss"; exit 131
        fi
    fi
}

add_ip_to_sg(){
    if [[ $# != 1 ]]; then echo "Usage: add_ip_to_sg ip_address_file_to_iterate"; exit 20; fi
    input_file_name=$1
    while read -r line; do
        ip_address_from_file=$(echo ${line} | awk '{ print $1 }')
        description_from_file=$(echo ${line} | awk '{ print $2 }')
        check_input_variable ${ip_address_from_file}
        if [[ "$get_all_ips_by_security_group" == *"$ip_address_from_file"* ]]; then
            echo "Your IP ${ip_address_from_file} address is already present in Security group ${sg_name}."
        else
            added_rule=$(aws ec2 authorize-security-group-ingress \
                --group-id ${sg_id} \
                --ip-permissions IpProtocol=all,IpRanges="[{CidrIp=${ip_address_from_file}/32,Description="${description_from_file}"}]")
            added_ip=$(echo ${added_rule} | jq '.SecurityGroupRules[].CidrIpv4')
            echo "Script added IP ${added_ip} address to Security Group ${sg_name}"
        fi 
    done < $input_file_name
}

remove_ip_from_sg(){
    read -p 'InputIP: ' ip_addr_input
    check_input_variable ${ip_addr_input}
    if [[ "$get_all_ips_by_security_group" == *"$ip_addr_input"* ]]; then
        remove_ip_from_sg_validate_template ${ip_addr_input}
    else
        echo "IP ${ip_addr_input} address doens't exists in Security Group ${sg_name}"
    fi
}

check_file_exists_and_not_empty() {
    if [[ $# != 1 ]]; then echo "Usage: check_file_exists_and_not_empty file_name_to_check"; exit 20; fi
    file_name=$1
    if [[ -f ${file_name} ]]; then
        echo "IP address file ${file_name} found."
        if [[ ! -s ${file_name} ]]; then
            echo "But empty!!!"
            echo "Each line in file must be as: ip.address.of.host description_of_host"
            exit 19
        fi
    else 
        echo "File ${file_name} desn't exists. Please create IP database file"
        echo "Each line in file must be as: ip.address.of.host description_of_host"
        exit 19
    fi
}