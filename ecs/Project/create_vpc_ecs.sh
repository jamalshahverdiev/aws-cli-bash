#!/usr/bin/env bash
. ./libs/variables.sh
. ./libs/vpc_functions.sh
. ./libs/iam_functions.sh
. ./libs/ecs_functions.sh

create_pvc && sleep 5
. ./libs/variables.sh
create_ecs_iam_roles && sleep 5
create_update_ecs_cluster 
