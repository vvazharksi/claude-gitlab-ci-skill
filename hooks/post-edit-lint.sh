#!/usr/bin/env bash
# post-edit-lint.sh
#
# Claude Code PostToolUse hook — runs a linter after editing domain-specific files.
# Reads hook input JSON from stdin (provided by Claude Code harness).
#
# SETUP: Register in ~/.claude/settings.json (see hooks/README.md)
# REQUIRES: your linter CLI (replace LINTER_CMD below)
#
# TEMPLATE: Replace LINTER_CMD and FILE_PATTERN with your own.
# FILE_PATTERN is a regex matched against the edited file path.
# Override per-project by setting SKILL_FILE_PATTERN in .claude/settings.json env block.

set -euo pipefail

# --- Configuration -----------------------------------------------------------
LINTER_CMD="your-linter"          # TEMPLATE: replace with your linter binary
DEFAULT_PATTERN='\.your-extension$'  # TEMPLATE: regex matching files to lint
# -----------------------------------------------------------------------------

# Extract file path from Claude Code hook input JSON
FILE=$(jq -r '.tool_input.file_path // empty' -)
[ -z "$FILE" ] && exit 0

# Match against the configured pattern
# Per-project override: set SKILL_FILE_PATTERN in .claude/settings.json env block
PATTERN="${SKILL_FILE_PATTERN:-$DEFAULT_PATTERN}"
BASENAME=$(basename "$FILE")

# Check by basename OR full path pattern
( [ "$BASENAME" = "$(echo "$BASENAME" | grep -E "$DEFAULT_PATTERN" || true)" ] \
  || echo "$FILE" | grep -qE "$PATTERN" ) || exit 0

# Skip silently if linter is not installed
command -v "$LINTER_CMD" >/dev/null 2>&1 || exit 0

# Run the linter
if ! "$LINTER_CMD" "$FILE" 2>&1; then
    # Output JSON to block further actions and show a message
    printf '{"continue":false,"stopReason":"%s lint failed for %s — fix the errors above before continuing."}\n' \
        "$LINTER_CMD" "$FILE"
fi
