---
name: lean-explore
description: Use when exploring a codebase — enforces grep/find-first discipline instead of reading files broadly
---

# Intent

Codebase exploration is a major token sink. Reading multiple files to "understand the structure" burns context fast. This skill enforces a targeted approach: use grep and find to pinpoint exactly what you need before touching Read.

# Exploration Protocol

## Step 1 — Start with find, not Read

To understand structure, list — don't read:

```bash
find src/ -name "*.ts" | head -40
ls src/api/ src/components/ src/middlewares/
```

Never read an index file just to discover what exists. Use find.

## Step 2 — Grep before Read

To find where a function, type, or pattern is defined:

```bash
grep -rn "functionName" src/ --include="*.ts"
grep -rn "ComponentName" src/ --include="*.tsx" -l  # -l = filenames only, no content
```

Use `-l` first to get filenames, then grep the specific file with `-n` to get line numbers.

## Step 3 — Read only the confirmed file at the confirmed line

Use the `lean-read` discipline: offset to the line, limit to 50 lines.

## Step 4 — Stop when you have enough

Do not continue exploring "just in case." If you have the answer, stop. Unexplored files cost zero tokens.

# Tiered Strategy by Task

| Task | Approach |
|---|---|
| Find where X is defined | `grep -rn "X" src/ --include="*.ts"` |
| Understand a module's exports | `grep -n "^export" src/module/index.ts` |
| Find all usages of X | `grep -rn "X" src/ --include="*.ts" -l` then spot-check 1–2 files |
| Understand file structure | `find src/ -type f -name "*.ts" \| head -50` |
| Find config values | `grep -rn "KEY_NAME" config/ .env*` |

# What NOT to do

- Do not read multiple files to "build a mental model" — grep builds the model cheaper
- Do not use the Explore subagent for tasks solvable with one grep command
- Do not read a file to find out if it contains something — grep tells you first
- Do not list directory contents with `ls -la` when `find` with filters is more precise

# Trigger

Apply this skill at the start of any task that requires understanding existing code before making changes.
