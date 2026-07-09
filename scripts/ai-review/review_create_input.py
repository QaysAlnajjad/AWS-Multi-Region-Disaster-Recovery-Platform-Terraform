#!/usr/bin/env python3

import json
from pathlib import Path

################################################################################
# Directories
################################################################################

RESULTS_DIR = Path("ai-results")

OUTPUT_FILE = RESULTS_DIR / "review_input.json"

################################################################################
# Build Review Input
################################################################################

review_input = {}

for file in sorted(RESULTS_DIR.glob("*.json")):

    # Ignore previously generated files
    if file.name == "review_input.json":
        continue

    if file.name == "ai-report.json":
        continue

    key = file.stem

    try:

        with open(file, "r", encoding="utf-8") as f:

            review_input[key] = json.load(f)

    except Exception as e:

        review_input[key] = {

            "error": str(e)

        }

################################################################################
# Save Review Input
################################################################################

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:

    json.dump(

        review_input,

        f,

        indent=4

    )

print(f"Created {OUTPUT_FILE}")
