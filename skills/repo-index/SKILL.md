---
name: repo-index
description: Build and maintain a compact repo index file so future sessions never re-scan the codebase from scratch
---

# Intent

Re-discovering repo structure every session is the biggest recurring token waste. This skill creates a persistent `CLAUDE_INDEX.md` at the repo root — a compact map of everything relevant. Future sessions read it in one shot instead of running find/ls/grep to rebuild context.

# When to use

- Start of a session in an unfamiliar or large repo
- After a significant structural change (new module, major refactor)
- When you catch yourself running `find src/` or `ls` to orient yourself

# Index Format

Keep it under 150 lines. Dense, no prose.

```markdown
# Repo Index
_last updated: YYYY-MM-DD_

## Stack
Next.js 14 app router / TypeScript / Tailwind / TanStack Query / Zustand / Zod / React Hook Form / Axios

## Entry Points
- `src/app/` — Next.js routes (app router)
- `src/features/` — feature modules (one folder per domain)
- `src/shared/` — cross-feature utilities, components, hooks
- `src/lib/` — third-party config (axios instance, query client, etc.)
- `src/store/` — Zustand stores

## Module Map
| Feature | Path | Key files |
|---|---|---|
| auth | src/features/auth/ | schema.ts, useAuth.ts, auth.store.ts |
| user | src/features/user/ | types.ts, useUser.ts, user.api.ts |
| ... | | |

## Conventions
- API calls: axios instance at `src/lib/axios.ts`, per-feature api files
- State: Zustand at `src/store/`, one file per domain
- Forms: React Hook Form + Zod, schema colocated with form component
- Data fetching: TanStack Query hooks in `src/features/<name>/hooks/`
- Types: `types.ts` or `*.types.ts` colocated in feature folder

## Key Config Files
- `src/lib/axios.ts` — base URL, interceptors, auth headers
- `src/lib/query-client.ts` — TanStack Query defaults
- `src/store/` — all Zustand stores

## Shared Components
- `src/shared/components/ui/` — base UI components
- `src/shared/hooks/` — reusable hooks

## What Lives Where
- New API endpoint → `src/features/<name>/api/`
- New page → `src/app/<route>/page.tsx`
- New shared hook → `src/shared/hooks/`
- New form → colocate with the feature component + add Zod schema
```

# Protocol

## Building the index (first time)

Run these in sequence — each is one command, no file reads:

```bash
# 1. Stack
cat package.json | grep -A50 '"dependencies"' | grep -v "dev" | head -30

# 2. Directory structure (2 levels deep)
find src/ -maxdepth 2 -type d | sort

# 3. Entry points
ls src/app/ src/features/ src/pages/ 2>/dev/null

# 4. Config files
find src/lib src/config -type f 2>/dev/null | head -20

# 5. Conventions (grep for patterns, not file reads)
grep -rn "axios.create" src/ --include="*.ts" -l
grep -rn "create(" src/ --include="*.store.ts" -l
grep -rn "z.object" src/ --include="*.ts" -l | head -10
```

Write the index from this output. Do not read individual files to build it.

## Reading the index (subsequent sessions)

At session start, read `CLAUDE_INDEX.md` first:
- If it exists and was updated recently → use it, skip all find/ls exploration
- If it's stale (major structural changes visible) → rebuild only the changed section

## Updating the index

After completing a task that changes structure:
- Add the new feature/module to the module map
- Update "what lives where" if a new convention was established
- Update the date

Do not rewrite the whole index — edit only the changed section.

## What NOT to index

- Individual function signatures (grep for those on demand)
- File contents (the index is a map, not a copy)
- Anything already in `README.md` — link to it instead

# Trigger

Apply at the start of any session in a codebase you haven't worked in recently, or any codebase larger than ~20 files.
