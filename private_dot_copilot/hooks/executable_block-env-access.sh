#!/bin/bash
set -euo pipefail

input=$(cat)

python3 - "$input" <<'PY'
import json
import re
import sys

raw = sys.argv[1]
try:
    payload = json.loads(raw)
except json.JSONDecodeError:
    sys.exit(0)

tool_args = payload.get("toolArgs", "")
if re.search(r'(^|["\'/])\.env($|["\'/,\s}])', tool_args):
    print(json.dumps({
        "permissionDecision": "deny",
        "permissionDecisionReason": "Access to .env files is blocked by policy",
    }))
PY
