import json
import re
import sys


def reason(prefix):
    return (
        f"{prefix} is blocked by policy. Do *NOT* try to work around the policy. "
        "Explain the problem and prompt the operator for another way"
    )


raw = sys.argv[1]
try:
    payload = json.loads(raw)
except json.JSONDecodeError:
    sys.exit(0)

tool_args = payload.get("toolArgs", "")
if re.search(r"(?<!\w)\.env\b", tool_args):
    print(
        json.dumps(
            {
                "permissionDecision": "deny",
                "permissionDecisionReason": reason("Access to .env files"),
            }
        )
    )
if re.search(r"(?:^|[|;&])\s*(?:[\w\/.-]+\/)?env\b", tool_args):
    print(
        json.dumps(
            {
                "permissionDecision": "deny",
                "permissionDecisionReason": reason("Command env"),
            }
        )
    )
if re.search(r"\bgetenv\b", tool_args):
    print(
        json.dumps(
            {
                "permissionDecision": "deny",
                "permissionDecisionReason": reason("Function getenv"),
            }
        )
    )
