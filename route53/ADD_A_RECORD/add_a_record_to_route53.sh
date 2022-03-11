#!/usr/bin/env bash
. ./libs/route53_variables.sh
. ./libs/route53_functions.sh

for a_name in 'data' 'initial'; do execute_all_functions ${a_name} ${app_record_name}; done