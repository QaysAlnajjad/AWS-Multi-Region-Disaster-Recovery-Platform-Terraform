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
-backend-config="bucket=$TF_STATE_BUCKET_NAME" \
-backend-config="key=environments/$stack/terraform.tfstate" \
-backend-config="region=$TF_STATE_BUCKET_REGION"



terraform -chdir="environments/$stack" fmt -check


terraform -chdir="environments/$stack" validate



TFVARS=""

FOUND=$(find environments/$stack -maxdepth 1 -name "*.tfvars" | head -1)


if [ -n "$FOUND" ]; then

  TFVARS="-var-file=$(basename "$FOUND")"

  echo "Using vars: $TFVARS"

fi



set +e


terraform -chdir="environments/$stack" plan \
${STACK_VARS[$stack]} \
$TFVARS \
-no-color



RESULT=$?


set -e



if [ $RESULT -eq 0 ]; then

echo "✅ $stack: No changes"

elif [ $RESULT -eq 2 ]; then

echo "⚠️ $stack: Changes detected (plan is valid)"

else

echo "❌ $stack: Terraform plan failed"

exit $RESULT

fi


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



echo "======================"
echo "Verification completed"
echo "======================"
