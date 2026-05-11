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

## Updating the index — agent responsibility

**After completing any task that causes structural change, you MUST update `CLAUDE_INDEX.md` before ending the session.** Do not wait for the user to ask.

Structural changes that require an update:

| Change made | What to update in the index |
|---|---|
| Created a new file in a new directory | Add directory to module map |
| Created a new module/feature/domain | Add row to module map with path and key files |
| Moved or renamed a file | Update the path in module map and entry points |
| Deleted a module or feature | Remove from module map |
| Added a new config file | Add to key config files section |
| Established a new convention | Add to conventions section |
| Added a new entry point | Add to entry points section |

Changes that do NOT require an index update:
- Editing existing files without moving them
- Bug fixes within an existing module
- Adding a function inside an existing file
- Changing implementation without changing module structure

## How to update

Edit only the affected section — never rewrite the whole file:
1. Update the relevant rows/lines
2. Update the `_last updated` date
3. Leave all other sections untouched

## What NOT to index

- Individual function signatures (grep for those on demand)
- File contents (the index is a map, not a copy)
- Anything already in `README.md` — reference it instead
- Dependency version numbers (check `package.json`/`go.mod` directly when needed)

# Trigger

- **Session start**: read `CLAUDE_INDEX.md` before any exploration in repos larger than ~20 files
- **Session end / task completion**: update `CLAUDE_INDEX.md` if any structural change was made
