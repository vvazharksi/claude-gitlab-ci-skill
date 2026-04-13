# Claude Skill Template — GitLab CI

A bare-bones template for building Claude Code skills focused on GitLab CI/CD pipeline diagnosis and repair.

Use this to teach Claude how to recognise, diagnose, and fix GitLab pipeline failures in your projects — either interactively via Claude Code CLI or as part of an automated self-healing agent.

> **Remedy compatibility:** This template follows the skill format expected by Remedy, a self-healing agent that watches GitLab pipelines and triggers Claude to fix failures automatically.

---

## What it is

A skill is a folder of structured files that teaches Claude how to behave in a specific domain. This template targets **GitLab CI/CD** — it gives Claude the patterns, failure knowledge, and reference material it needs to diagnose broken pipelines and suggest or apply fixes.

Skills are loaded into Claude's context before it starts diagnosing a failure, whether you're asking Claude interactively or running it as an automated agent.

This template gives you the correct folder structure and file format so your skill:

- Works with Claude Code CLI (skills loaded automatically from `~/.claude/skills/`)
- Works with any Claude agent that reads from the same skills directory
- Keeps token usage bounded as your failure database grows (keyword pre-filtering)
- Loads only the references relevant to each failure (tag-based selection)
- Is compatible with Remedy's self-healing loop out of the box

---

## Why it exists

A useful GitLab CI skill needs more than a prompt. It needs a consistent structure that scales — where failure knowledge grows over time without bloating every agent call, and where domain-specific references are only loaded when they're actually relevant.

This template enforces that structure:

1. **SKILL.md** — reasoning patterns and principles. Always loaded.
2. **symptoms.json** — a database of known failure patterns. Only the top matching symptoms are injected per call, so token usage stays flat regardless of how many symptoms accumulate.
3. **references/index.json** — a manifest of reference files. Only references whose tags match the failure context are loaded.
4. **scripts/scaffold.py** — a CLI tool agents call to detect project context and scaffold config files.
5. **hooks/** — shell scripts for Claude Code hooks (secrets scanning, linting).

Without this structure, an agent injecting the full symptom table and all references on every call gets slower and more expensive as the skill grows. With it, a skill with 200 symptoms injects the same ~5 entries as one with 20.

---

## Installation

```bash
# 1. Copy the template to your skills directory
cp -r claude-gitlab-ci-skill ~/.claude/skills/your-skill-name

# 2. Rename and fill in your skill
cd ~/.claude/skills/your-skill-name
```

---

## Usage

### 1. Fill in SKILL.md

Replace all `[PLACEHOLDER]` blocks with your domain's reasoning patterns, principles, and self-healing rules. This is the file Claude reads to understand how to think about failures in your domain.

### 2. Build your symptoms database

Edit `symptoms.json`. Each entry needs:

```json
{
  "symptom": "what the failure looks like",
  "cause": "root cause",
  "fix": "exact fix steps",
  "keywords": ["verbatim", "substrings", "from", "error", "output"]
}
```

Keywords must be verbatim substrings from actual GitLab job logs — not descriptions. The agent scores each symptom by how many keywords appear in the logs, then injects only the top 5 matches into the prompt.

### 3. Add reference files

Put lookup tables, config schemas, and domain-specific reference content in `references/`. Register every file in `references/index.json`:

```json
{
  "file": "references/my-reference.md",
  "description": "What this file contains",
  "tags": ["keyword1", "keyword2"]
}
```

Tags are matched against the failure context (GitLab job log text + job and stage names). Only files with matching tags are loaded — so a Docker build failure won't load your Python dependency reference.

### 4. Adapt the scaffold script

Edit `scripts/scaffold.py`. Implement `detect_project()` to identify indicators relevant to your domain, and update the `TEMPLATES` dict with the config files you want to generate.

### 5. Register hooks (optional)

The `hooks/` folder contains two ready-to-use scripts:

| Script | What it does |
|---|---|
| `pre-push-secrets.sh` | Blocks `git push` if gitleaks detects secrets |
| `post-edit-lint.sh` | Runs a linter after Claude edits domain-specific files |

These do nothing until registered. See [hooks/README.md](hooks/README.md) for setup instructions.

---

## Folder structure

```
your-skill-name/
├── SKILL.md                     ← Reasoning patterns and self-healing rules
├── symptoms.json                ← Failure pattern database (pre-filtered per diagnosis)
├── references/
│   ├── index.json               ← Manifest: which reference files exist and when to load them
│   └── quick_reference.md      ← Lookup tables — no reasoning
├── scripts/
│   └── scaffold.py              ← CLI: detect project context + scaffold config files
└── hooks/
    ├── README.md                ← How to register hooks in settings.json
    ├── pre-push-secrets.sh      ← Block git push if secrets found
    └── post-edit-lint.sh        ← Lint after editing domain files
```

---

## Conventions to preserve

These are load-bearing for Remedy compatibility:

- **Symptom table lives in `symptoms.json`**, not SKILL.md
- **Every reference file must be in `references/index.json`** with specific tags — files not in the manifest are never loaded
- **SKILL.md frontmatter** must have `name` and `description` fields
- **`keywords` in symptoms.json** must be verbatim substrings from actual error output — not descriptions
- **Confidence HIGH/LOW** must follow the rules in SKILL.md's Self-Healing section