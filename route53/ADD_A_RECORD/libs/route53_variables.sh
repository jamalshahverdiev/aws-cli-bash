#!/usr/bin/env bash

cluster_name='elmesterati'
domain_name='example.com.'
record_json_file='record.json'
temp_record_json_file='add_record.json'
app_record_name="*.app.${cluster_name}.corporate.domain.name"
data_record_name="*.data.${cluster_name}.corporate.domain.name"
zone_id_by_dns_name=$(aws route53 list-hosted-zones-by-name | jq -r '.HostedZones[] | select(.Name=="'${domain_name}'")|.Id')
declare -a global_array ip_list