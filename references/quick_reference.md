# [Your Skill] Quick Reference

Lookup table for exact names, values, and config keys. For reasoning and adaptation guidance, see SKILL.md.

---

## [First Lookup Category]

| Name / Key | Value / Description |
|---|---|
| `EXAMPLE_VAR` | What it does and when to set it |
| `ANOTHER_VAR` | What it does and when to set it |

---

## [Second Lookup Category — e.g. Required Flags]

```
--flag-name value    # what this controls
--other-flag         # what this controls
```

---

## [Third Lookup Category — e.g. Common Commands]

```bash
# What this command does
tool command --option

# What this command does
tool other-command
```

---

## [Fourth Lookup Category — e.g. File Paths / Locations]

| Purpose | Path |
|---|---|
| [Config file] | `path/to/config` |
| [Output dir] | `path/to/output/` |

---

## Notes

- Keep this file as a lookup table only — no reasoning, no "why". That lives in SKILL.md.
- One entry per concept. If something needs explanation, it belongs in SKILL.md's Pattern Library.
- Register this file in `references/index.json` with tags that match when it's relevant.
