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


echo "Checking remote state..."

STATE_EXISTS=$(aws s3api head-object \
--bucket "$TF_STATE_BUCKET_NAME" \
--key "environments/$stack/terraform.tfstate" \
2>/dev/null || true)



if [ -z "$STATE_EXISTS" ]; then

echo "⚠️ No remote state found for $stack"

else

echo "✅ Remote state found"

fi



echo "Running terraform plan..."

set +e


terraform -chdir="environments/$stack" plan \
${STACK_VARS[$stack]} \
-no-color \
-detailed-exitcode


RESULT=$?


set -e



case $RESULT in


0)

echo "✅ $stack OK"

;;


2)

echo "⚠️ $stack has changes"

;;


1)

echo "❌ $stack terraform error"

exit 1

;;


*)

echo "❌ Unexpected terraform exit code $RESULT"

exit $RESULT

;;


esac


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
