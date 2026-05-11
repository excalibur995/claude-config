---
name: repo-index
description: Build and maintain a compact repo index file so future sessions never re-scan the codebase from scratch
---

# Intent

Re-discovering repo structure every session is the biggest recurring token waste. This skill creates a persistent `CLAUDE_INDEX.md` at the repo root — a compact map of everything relevant. Future sessions read it in one shot instead of running find/ls/grep to rebuild context.

Works for any stack: frontend, backend, mobile, monorepo, CLI, API service, etc.

# When to use

- Start of a session in an unfamiliar or large repo
- After a significant structural change (new module, major refactor)
- When you catch yourself running `find` or `ls` just to orient yourself

# Index Format

Keep it under 150 lines. Dense, no prose. Adapt sections to what actually exists in the repo.

```markdown
# Repo Index
_last updated: YYYY-MM-DD_

## Stack
[language] / [runtime or framework] / [key libraries] / [build tool] / [test framework]

## Entry Points
- `src/main.ts` or `cmd/` or `app/` — where execution starts
- `src/routes/` or `src/api/` or `src/controllers/` — request handling
- `src/services/` or `src/domain/` — business logic
- `src/lib/` or `src/utils/` — shared utilities

## Module / Feature Map
| Module | Path | Key files |
|---|---|---|
| auth | src/modules/auth/ | auth.service.ts, auth.controller.ts |
| user | src/modules/user/ | user.model.ts, user.service.ts |
| ... | | |

## Conventions
- [How the project is structured: feature-based, layered, domain-driven, etc.]
- [Where models/schemas/types live]
- [Where business logic lives vs infrastructure]
- [Test file location pattern: colocated, __tests__, spec/]
- [Config/env loading pattern]

## Key Config Files
- [main config file] — what it controls
- [env/secrets file] — how env vars are loaded
- [build/deploy config] — build tool config

## What Lives Where
- New feature/domain → [where to add it]
- New shared utility → [where to put it]
- New test → [where it goes]
- New config/env var → [where to register it]
```

# Protocol

## Building the index (first time)

Run in sequence — commands only, no file reads:

```bash
# 1. Detect stack (use whichever exists)
cat package.json 2>/dev/null | grep -A30 '"dependencies"' | head -25
cat go.mod 2>/dev/null | head -15
cat Cargo.toml 2>/dev/null | head -15
cat requirements.txt pyproject.toml 2>/dev/null | head -15
cat build.gradle pom.xml 2>/dev/null | head -15

# 2. Top-level structure
ls -1
find . -maxdepth 2 -type d | grep -v "node_modules\|\.git\|dist\|build\|__pycache__\|\.gradle\|vendor" | sort

# 3. Entry points (adapt to language)
find . -name "main.*" -o -name "index.*" -o -name "app.*" -o -name "server.*" | grep -v "node_modules\|dist\|build" | head -15

# 4. Config and env files
find . -maxdepth 2 -name "*.config.*" -o -name ".env*" -o -name "docker-compose*" | grep -v "node_modules" | head -15

# 5. Test pattern
find . -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" | grep -v "node_modules\|dist" | head -10
```

Write the index from this output. Do not read individual files to build it.

## Reading the index (subsequent sessions)

At session start, read `CLAUDE_INDEX.md` first:
- If it exists → use it, skip all find/ls exploration
- If it's stale (you see structural changes not reflected) → rebuild only the changed section

## Updating the index

After any task that changes structure:
- Add the new module/feature to the module map
- Update "what lives where" if a convention changed
- Update the date

Edit only the changed section — never rewrite the whole file.

## What NOT to index

- Individual function signatures (grep for those on demand)
- File contents (the index is a map, not a copy)
- Anything already in `README.md` — reference it instead
- Dependency version numbers (check `package.json`/`go.mod` directly when needed)

# Trigger

Apply at the start of any session in a codebase you haven't worked in recently, or any repo larger than ~20 files.
