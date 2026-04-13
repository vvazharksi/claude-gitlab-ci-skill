# Hooks

Hook scripts for this skill. These run automatically via Claude Code when registered in `settings.json`.

**Important:** Hook scripts in this folder do nothing on their own. They must be registered in `~/.claude/settings.json` (global) or `.claude/settings.json` (project-level) to fire.

---

## Hooks in this folder

| Script | Event | Fires when |
|---|---|---|
| `pre-push-secrets.sh` | `PreToolUse` → `Bash` | Claude runs any `git push` command |
| `post-edit-lint.sh` | `PostToolUse` → `Write\|Edit` | Claude writes or edits a file matching the pattern |

---

## Registering hooks in settings.json

### Option A — Inline command (what's already in settings.json)

Suitable when the command is short. The command string runs in a shell with hook input JSON on stdin.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git push*)",
            "command": "command -v gitleaks >/dev/null 2>&1 || exit 0; if ! gitleaks detect --source . --redact 2>&1; then echo '{\"continue\":false,\"stopReason\":\"gitleaks: secrets detected.\"}'; fi",
            "timeout": 120,
            "statusMessage": "Scanning for secrets..."
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // empty' -); [ -z \"$f\" ] && exit 0; echo \"$f\" | grep -qE '\\.your-extension$' || exit 0; your-linter \"$f\" 2>&1 || echo '{\"continue\":false,\"stopReason\":\"lint failed\"}'",
            "timeout": 30,
            "statusMessage": "Linting..."
          }
        ]
      }
    ]
  }
}
```

### Option B — Script reference (use when the command is complex)

Store the script here and reference it from settings.json:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git push*)",
            "command": "bash ~/.claude/skills/your-skill-name/hooks/pre-push-secrets.sh",
            "timeout": 120,
            "statusMessage": "Scanning for secrets..."
          }
        ]
      }
    ]
  }
}
```

---

## Scope: global vs project

| File | When to use |
|---|---|
| `~/.claude/settings.json` | Hooks that apply to every project (e.g. secrets scan before any push) |
| `.claude/settings.json` | Hooks specific to this project (committed, shared with team) |
| `.claude/settings.local.json` | Personal overrides for this project (gitignored) |

---

## Per-project file pattern override

The `post-edit-lint.sh` hook checks `SKILL_FILE_PATTERN` before falling back to its default. Set it per-project in `.claude/settings.json`:

```json
{
  "env": {
    "SKILL_FILE_PATTERN": "path/to/specific/.*\\.yml"
  }
}
```

---

## Hook input format

Claude Code passes JSON on stdin to every hook command:

```json
{
  "session_id": "abc123",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file",
    "content": "..."
  },
  "tool_response": { "success": true }
}
```

Use `jq` to extract fields: `jq -r '.tool_input.file_path // empty'`

## Blocking output format

To block the action, output JSON with `continue: false`:

```json
{"continue": false, "stopReason": "Message shown to the user explaining why it was blocked."}
```

Exit code non-zero also blocks — but JSON output gives a better user message.
