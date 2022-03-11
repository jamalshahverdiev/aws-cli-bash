#!/usr/bin/env bash
. ./libs/variables.sh
. ./libs/cw_functions.sh

for log_group_name in ${log_group_names}; do create_log_group ${log_group_name}; done 
