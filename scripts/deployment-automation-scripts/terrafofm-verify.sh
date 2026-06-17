#!/bin/bash

set -e

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/stacks_config.sh"


verify_stack(){

stack=$1

echo "======================"
echo "Checking $stack"
echo "======================"


terraform -chdir="environments/$stack" init \
-reconfigure \
-backend=false


terraform -chdir="environments/$stack" validate


terraform -chdir="environments/$stack" plan \
${STACK_VARS[$stack]} \
-no-color

}



verify_stack "global/iam"
verify_stack "global/oac"

verify_stack "primary/network"
verify_stack "primary/rds"

verify_stack "dr/network"

verify_stack "primary/alb"

verify_stack "primary/ecs"

verify_stack "dr/ecs"

verify_stack "operations/dr_orchestration"

verify_stack "primary/failover_alarms"


echo "Verification completed"
