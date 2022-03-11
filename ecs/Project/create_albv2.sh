#!/usr/bin/env bash
. ./libs/variables.sh
. ./libs/albv2_functions.sh
# Struct 'name' 'alb_listener' 'tg_port'
alb_tg_names='''
prod-authdata_80_8080
sandbox-authdata_80_8080
prod-front1_80_80
sandbox-front1_80_80
prod-front2_80_80
sandbox-front2_80_80
prod-site_80_80
sandbox-site_80_80
'''

for resource in ${alb_tg_names}; do
    name=$(echo $resource | awk -F '_' '{print $1}')
    alb_name="${project_name}-${name}-alb"
    tg_name="${project_name}-${name}-tg"
    alb_port=$(echo $resource | awk -F '_' '{print $2}')
    tg_port=$(echo $resource | awk -F '_' '{print $3}')
    create_tg_alb ${alb_name} ${alb_port} ${tg_name} ${tg_port}
done