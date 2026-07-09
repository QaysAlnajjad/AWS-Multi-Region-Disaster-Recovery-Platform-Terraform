#!/usr/bin/env python3

import json
import os
from datetime import datetime, timezone


INPUT_FILE = "ai-results/ai-analysis.json"

OUTPUT_FILE = "ai-results/ai-report.json"


################################################################################
# Load AI Analysis
################################################################################

with open(INPUT_FILE, "r", encoding="utf-8") as f:

    analysis = json.load(f)


################################################################################
# Collect CI Metadata
################################################################################

metadata = {

    "repository": os.getenv(
        "GITHUB_REPOSITORY",
        "unknown"
    ),

    "branch": os.getenv(
        "GITHUB_REF_NAME",
        "unknown"
    ),

    "commit": os.getenv(
        "GITHUB_SHA",
        "unknown"
    ),

    "workflow": os.getenv(
        "GITHUB_WORKFLOW",
        "unknown"
    ),

    "run_id": os.getenv(
        "GITHUB_RUN_ID",
        "unknown"
    ),

    "actor": os.getenv(
        "GITHUB_ACTOR",
        "unknown"
    ),

    "event": os.getenv(
        "GITHUB_EVENT_NAME",
        "unknown"
    ),

    "generated_at": datetime.now(
        timezone.utc
    ).isoformat()

}


################################################################################
# Add Tool Versions
################################################################################

def get_version(command):

    try:

        import subprocess

        result = subprocess.check_output(

            command,

            shell=True,

            text=True

        )

        return result.strip()

    except Exception:

        return "unknown"



metadata["terraform_version"] = get_version(
    "terraform version"
)

metadata["trivy_version"] = get_version(
    "trivy --version"
)

metadata["checkov_version"] = get_version(
    "checkov --version"
)


################################################################################
# Build Final Report
################################################################################

report = {

    "metadata": metadata,

    "analysis": analysis

}


################################################################################
# Save Report
################################################################################

with open(
    OUTPUT_FILE,
    "w",
    encoding="utf-8"
) as f:

    json.dump(

        report,

        f,

        indent=4

    )


print(
    f"Created {OUTPUT_FILE}"
)
