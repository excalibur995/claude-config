---
name: refactor-map
description: Map the full blast radius of a refactor using only grep before touching any file — no speculative reading
---

# Intent

The most expensive refactor pattern: read file A to understand it, then read file B because A imports it, then file C... Speculative reading scales with codebase size, not with the actual change size.

The right approach: grep builds the complete impact map in 3–5 commands. You know every file that needs changing before reading a single one.

Works for any language or stack.

# Protocol

## Step 1 — Define the change contract

Before anything, write one line:
> "I am changing [X] from [old] to [new]."

Examples:
- "I am renaming `getUserById` to `fetchUserById`"
- "I am adding a required `locale` field to the `User` model"
- "I am changing the `createOrder` function signature to accept `options` instead of positional args"
- "I am splitting `AuthService` into `AuthService` and `TokenService`"
- "I am moving `utils/date.ts` to `shared/date.ts`"

If you can't write this one line, the scope isn't defined. Stop and clarify.

## Step 2 — Grep the blast radius (don't read yet)

```bash
# Files that reference the thing being changed
grep -rn "thingBeingChanged" . --include="*.ts" -l
grep -rn "thingBeingChanged" . --include="*.py" -l
grep -rn "thingBeingChanged" . --include="*.go" -l
# (use the extension for your stack, or omit --include for all files)

# Count impact
grep -rln "thingBeingChanged" . | grep -v "node_modules\|dist\|build\|vendor" | wc -l
```

This gives the complete file list without reading anything.

## Step 3 — Find and change the contract definition first

The contract (type, interface, schema, function signature, struct, class definition) is always the smallest file to change and produces the most information about what else needs updating.

```bash
# Find the definition
grep -rn "class User\|interface User\|type User\|def create_user\|func CreateUser\|struct User" . \
  --include="*.ts" --include="*.py" --include="*.go" --include="*.java" --include="*.kt" -l
```

Read only the definition (20–30 lines). Change it. Then let the compiler/linter/type-checker surface every other file that needs updating — don't read them speculatively.

For dynamically typed languages (Python, JS without TS, Ruby): skip this step, go straight to step 4.

## Step 4 — Triage the blast radius without reading

From the grep output, categorize the files:

```
Definition (1–3 files):   src/models/user.ts           ← change first
Consumers (many files):   src/services/user.service.ts ← change as you reach them
Tests:                    src/models/__tests__/user.ts  ← change last, driven by failures
```

## Step 5 — Change in sequence, read only the file you're on

Read one file → make the change → move to the next. Never read ahead.

For simple changes (import rename, single call site), don't read the whole file:
```bash
grep -n "oldName" path/to/file.ext
# read 10–15 lines around the match, change it, done
```

## Step 6 — Batch identical changes

When many files need the same mechanical change (e.g., rename an import):

```bash
# Find all files with that exact import pattern
grep -rln "import.*OldName\|from.*old-module\|require.*old-module" . | grep -v "node_modules\|dist"
```

All files in the list get the identical change. Read one as a sample, apply to all. This is faster than reading each file individually.

## Blast radius by refactor type

| Refactor | Grep to run |
|---|---|
| Rename function/method | `grep -rn "oldFuncName" . -l` |
| Rename class/struct | `grep -rn "ClassName" . -l` |
| Change function signature | `grep -rn "funcName(" . -l` |
| Add required field to model/type | `grep -rn "ModelName" . -l` |
| Move file | `grep -rn "from.*old/path\|import.*old/path\|require.*old/path" . -l` |
| Rename module/package | `grep -rn "\"old-package\"\|'old-package'\|old_package" . -l` |
| Change env variable name | `grep -rn "OLD_VAR_NAME" . -l` |
| Change API endpoint path | `grep -rn '"/old/path"\|old_endpoint' . -l` |
| Rename DB table/column | `grep -rn "old_table\|old_column" . -l` |
| Change interface/contract | `grep -rn "InterfaceName\|implements.*Interface" . -l` |

## What NOT to do

- Do NOT read every file in the blast radius before starting
- Do NOT read files "for context" — read only the lines being changed
- Do NOT re-read already-changed files to verify — trust the edit, verify with tests/compiler
- Do NOT read test files before changing them — test failure output tells you what to fix
- Do NOT grep the whole filesystem — scope to the project root and exclude `node_modules`, `dist`, `build`, `vendor`, `.git`

# Trigger

Apply at the start of any refactor, rename, signature change, model update, or file move task.
