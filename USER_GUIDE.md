# User Guide — Getting the Most Out of Your AI Config

How to phrase requests so the skills trigger correctly and you get the best results with the fewest tokens.

---

## Repo Index

The repo index is a `CLAUDE_INDEX.md` file at the root of your project. It stores a compact map of the codebase so the AI never re-scans the repo from scratch each session.

### First time in a repo — build the index

```
index this repo
```
```
build a repo index for this project
```
```
create a CLAUDE_INDEX.md for this codebase
```

The AI will run directory and dependency scans (no file reads), then write a compact `CLAUDE_INDEX.md` covering: stack, module map, entry points, conventions, and key config files.

**Tip:** Run this once at the start of any new project. Commit `CLAUDE_INDEX.md` to the repo so your whole team benefits.

---

### Returning to a repo — load the index

```
read the repo index before we start
```
```
check the CLAUDE_INDEX before doing anything
```

Or just start working — the AI should check for `CLAUDE_INDEX.md` automatically at the start of any session.

---

### After structural changes — update the index

```
update the repo index, I added a new auth module
```
```
update CLAUDE_INDEX.md — we moved the API layer to src/server/
```
```
the repo index is stale, rebuild only the module map section
```

Be specific about what changed so the AI edits only that section instead of rewriting the whole file.

---

### Force a full rebuild

```
rebuild the repo index from scratch
```
```
the CLAUDE_INDEX is outdated, regenerate it completely
```

---

## Refactor Map

The refactor-map skill makes the AI grep for every affected file before reading anything. You get a complete impact list upfront, and files are read and changed one at a time — no speculative reading.

### How to phrase a refactor request

Always include: **what is changing** and **old → new**. The more specific, the better the blast-radius grep.

---

**Rename a function or method:**
```
refactor: rename getUserById to fetchUserById across the whole codebase
```
```
rename the function processPayment to handlePayment — map all usages first
```

---

**Change a type, model, or schema:**
```
refactor: add a required locale field to the User model — map all files that use User first
```
```
the Order type needs a new optional notes field — find all consumers before changing anything
```

---

**Change a function signature:**
```
refactor: createProduct currently takes (name, price, stock) — change it to take a single options object
map all call sites first
```

---

**Move or rename a file:**
```
refactor: move src/utils/date.ts to src/shared/date.ts — grep all imports before touching anything
```
```
rename the AuthController file to auth.controller.ts — find all references first
```

---

**Change an API endpoint path:**
```
refactor: the /api/users endpoint is moving to /api/v2/users — find all hardcoded references first
```

---

**Rename an env variable:**
```
refactor: rename API_BASE_URL to SERVICE_BASE_URL across the codebase — map all usages before changing
```

---

**Split or extract a class/module:**
```
refactor: extract the token logic out of AuthService into a new TokenService
map all AuthService usages first so we know what moves
```

---

### The one-liner format (most reliable)

This phrasing most reliably triggers the map-first approach:

```
refactor: [what is changing] — [old] → [new]. Map all affected files before touching anything.
```

Examples:
```
refactor: getUserById → fetchUserById. Map all affected files before touching anything.
```
```
refactor: add required field `tenantId` to the User model. Map all affected files before touching anything.
```
```
refactor: move src/lib/http.ts → src/shared/http.ts. Map all affected files before touching anything.
```

---

### What to expect

After your refactor request, the AI should:

1. State the change contract in one line
2. Show the grep command and the list of affected files with a count
3. Identify the definition file (type/class/schema) and change it first
4. Work through the file list one at a time — reading and changing each before moving on
5. Note when it reaches tests (changed last, driven by failures)

If it skips straight to reading files without showing the blast radius first, remind it:

```
map all affected files with grep first before reading anything
```

---

## General Tips

**Starting a session on an existing project:**
```
check the repo index, then [your task]
```

**Large unknown codebase:**
```
build a repo index first, then help me understand the auth flow
```

**Refactor + index update together:**
```
refactor: rename X to Y across the codebase. Map usages first. Update the repo index when done.
```

**Explicit token discipline:**
```
grep before you read anything — I want minimal file reads
```
