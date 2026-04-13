#!/usr/bin/env bash
# pre-push-secrets.sh
#
# Claude Code PreToolUse hook — blocks git push if secrets are detected.
# Reads hook input JSON from stdin (provided by Claude Code harness).
#
# SETUP: Register in ~/.claude/settings.json (see hooks/README.md)
# REQUIRES: gitleaks (https://github.com/gitleaks/gitleaks)
#
# TEMPLATE: Replace the gitleaks command with your preferred secrets scanner.
# Other options: trufflehog, detect-secrets, git-secrets

set -euo pipefail

# Skip silently if scanner is not installed
command -v gitleaks >/dev/null 2>&1 || exit 0

# Run the scan
# --redact  replaces secret values with REDACTED in output (safe to log)
# --source  path to scan (defaults to current directory = the project)
if ! gitleaks detect --source . --redact 2>&1; then
    # Output JSON to block the push and show a message to the user
    printf '{"continue":false,"stopReason":"gitleaks: potential secrets detected. Run: gitleaks detect --source . --verbose to review."}\n'
fi
