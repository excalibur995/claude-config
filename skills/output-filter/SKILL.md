---
name: output-filter
description: Use before running commands with large output — enforces filtering/capping so raw output doesn't flood context
---

# Intent

Unfiltered command output is a silent token killer. `git log`, `npm list`, `find .`, `cat package-lock.json` — these can dump thousands of lines into context. This skill enforces output discipline: cap and filter before the output lands.

# Rules

Before running any command that could return more than 50 lines, apply one of the strategies below.

## Strategy 1 — Hard cap with head

When you need a sample or recent entries:

```bash
git log --oneline | head -20
find . -name "*.ts" | head -30
npm list --depth=0   # always use --depth=0 on npm list
```

## Strategy 2 — Filter with grep

When you need specific content from large output:

```bash
git log --oneline --grep="fix\|feat" | head -20
npm list 2>/dev/null | grep "your-package"
find . -type f | grep -v "node_modules\|dist\|.git"
```

## Strategy 3 — Summarize with wc or count

When you just need to know scale, not content:

```bash
find src/ -name "*.ts" | wc -l
git log --oneline | wc -l
```

## Strategy 4 — Targeted flags instead of full output

Prefer commands with built-in scoping:

```bash
git log --oneline -10                    # last 10 only
git diff --stat HEAD~1                   # summary not full diff
git show --stat HEAD                     # no patch, just files
npm outdated                             # only what's stale
```

# High-Risk Commands — Always Filter

| Command | Safe version |
|---|---|
| `git log` | `git log --oneline -15` |
| `git diff` | `git diff --stat` or `git diff src/specific-file.ts` |
| `find .` | `find src/ -name "*.ts" \| head -30` |
| `npm list` | `npm list --depth=0` |
| `cat package-lock.json` | Never read lock files — use `npm list --depth=0` instead |
| `ls -la` recursively | `find . -maxdepth 2 -type f` |
| `env` / `printenv` | `printenv \| grep SPECIFIC_VAR` |

# Absolute Prohibitions

- Never `cat` or Read `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` — they are binary-scale noise
- Never run `find .` without `-maxdepth` or `| head`
- Never run `git log` without `-n` or `| head`
- Never run `npm list` without `--depth=0`

# Trigger

Apply this skill before any shell command whose output length is unknown or potentially large.
