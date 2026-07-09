#!/usr/bin/env bash

set -euo pipefail

################################################################################
# Load Configuration
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/config.sh"

################################################################################
# Validate Required Variables
################################################################################

: "${TF_STATE_BUCKET_NAME:?TF_STATE_BUCKET_NAME is not set}"
: "${TF_STATE_BUCKET_REGION:?TF_STATE_BUCKET_REGION is not set}"

################################################################################
# Terraform environments
################################################################################

ENVIRONMENTS=(

    global/iam
    global/oac
    global/cdn_dns

    primary/network
    primary/s3
    primary/alb
    primary/rds
    primary/ecs
    primary/failover_alarms

    dr/network
    dr/s3
    dr/alb
    dr/read_replica_rds
    dr/ecs

    operations/dr_orchestration

)

################################################################################
# Validation Loop
################################################################################

for env in "${ENVIRONMENTS[@]}"; do

    echo
    echo "=========================================================="
    echo "Checking ${env}"
    echo "=========================================================="

    pushd "$ROOT_DIR/environments/$env" > /dev/null

    terraform init \
        -backend-config="bucket=${TF_STATE_BUCKET_NAME}" \
        -backend-config="region=${TF_STATE_BUCKET_REGION}" \
        -input=false \
        -reconfigure

    terraform validate

    echo "✅ ${env} OK"

    popd > /dev/null

done

echo
echo "=========================================================="
echo "Terraform validation completed successfully."
echo "=========================================================="
