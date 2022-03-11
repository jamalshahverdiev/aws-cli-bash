#!/bin/bash 
. ./libs/libraries.sh

if [ $# -ne 2 ]; then usage; fi
file_path=$1
bucket_name=$2

execute_flow
