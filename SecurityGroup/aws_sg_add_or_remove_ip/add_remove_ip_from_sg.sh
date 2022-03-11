#!/usr/bin/env bash
# Error code 19: File cannot be empty
# Error code 20: Argument cannot be empty
# Error code 77: Third argument not valid
# Error code 100: Variable is empty
# Error code 101: Entered Security Group deosn't exists
# Error code 111: Entered argument of Security group ID is wrong
# Error code 131: Enter right IP address

if [[ $# != 3 ]]; then echo "Usage: ./$(basename $0) add/remove security_group_name prod/nonprod"; exit 20; fi

. ./libs/variables.sh
. ./libs/functions.sh

check_file_exists_and_not_empty ${ip_address_file}

if [[ ${input_mode} == 'add' ]]; then
    check_security_group_exists && add_ip_to_sg ${ip_address_file}
elif [[ ${input_mode} == 'remove' ]]; then
    check_security_group_exists && remove_ip_from_sg 
else 
    echo "First argument can be 'add' or 'remove'" && exit 17
fi