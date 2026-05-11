---
name: refactor-map
description: Map the full blast radius of a refactor using only grep before touching any file — no speculative reading
---

# Intent

The most expensive refactor pattern: read file A to understand it, then read file B because A imports it, then file C... This is speculative reading. It scales with codebase size, not with the actual change size.

The right approach: grep builds the complete impact map in 3–5 commands. You know every file that needs changing before reading a single one.

# Protocol

## Step 1 — Define the change contract

Before anything, answer in one line:
> "I am changing [X] from [old shape] to [new shape]."

Examples:
- "I am renaming `getUserById` to `fetchUserById`"
- "I am adding a required `locale` field to the `User` type"
- "I am changing `useAuth` to return `{ user, session }` instead of just `user`"

If you can't write this one line, the scope isn't defined yet. Stop and clarify.

## Step 2 — Grep the blast radius (don't read yet)

```bash
# Find every file that imports or uses the thing being changed
grep -rn "getUserById\|useAuth\|User\b" src/ --include="*.ts" --include="*.tsx" -l

# Count the impact
grep -rn "getUserById" src/ --include="*.ts" --include="*.tsx" -l | wc -l
```

This gives you the complete file list in one command. No reading required.

## Step 3 — Read the type/interface contract first, nothing else

For TypeScript refactors, the type IS the contract. Change it first:

```bash
grep -rn "interface User\|type User " src/ --include="*.ts" -l
```

Read only the type definition (20–30 lines). Make the type change. Then let TypeScript errors guide every other file — you don't need to read them speculatively.

## Step 4 — Triage the impact list

From the grep output, categorize without reading:

```
Direct definitions (1–3 files):  src/features/user/types.ts
Consumers (grep count > 5):      src/features/user/hooks/useUser.ts, ...
Tests:                            src/features/user/__tests__/
```

Read definitions first (always small). Read consumers only when you reach that file in the change sequence.

## Step 5 — Change in order, read only what you're currently changing

Read one file → make the change → move to the next. Never read ahead.

If a file is straightforward (just an import rename), change it without reading the whole file:
```bash
# Check the specific line before editing
grep -n "getUserById" src/features/user/hooks/useUser.ts
```
Read 10 lines around the match. Change it. Done.

## For large refactors — batch by change type

Group the blast radius into batches of identical changes:

```bash
# Batch 1: rename imports only
grep -rln "import.*getUserById" src/ --include="*.ts"

# Batch 2: call site changes
grep -rln "getUserById(" src/ --include="*.ts"
```

Each batch is a single pattern → find all files → apply the same change. Read once per pattern, not once per file.

## Refactor patterns and their grep commands

| Refactor | Grep to run first |
|---|---|
| Rename function | `grep -rn "oldName" src/ --include="*.ts" -l` |
| Add required field to type | `grep -rn "TypeName" src/ --include="*.ts" -l` |
| Change hook return shape | `grep -rn "useHookName" src/ --include="*.tsx" -l` |
| Move file / change import path | `grep -rn "from.*old/path" src/ --include="*.ts" -l` |
| Change API response shape | `grep -rn "ResponseType\|\.data\." src/features/<name>/ -l` |
| Rename component | `grep -rn "ComponentName" src/ --include="*.tsx" -l` |
| Change Zustand store shape | `grep -rn "useStoreName\|storeSelector" src/ --include="*.tsx" -l` |
| Change Zod schema | `grep -rn "schemaName\|zodResolver.*schema" src/ --include="*.tsx" -l` |

## What NOT to do

- Do NOT read every consumer file before starting — grep tells you the list
- Do NOT read files "for context" before changing them — read only the lines being changed
- Do NOT re-read already-changed files to verify — trust the edit, verify with TypeScript
- Do NOT read test files before changing them — the test failure message tells you what to fix

# Trigger

Apply this skill at the start of any refactor, rename, interface change, or file restructure task.
