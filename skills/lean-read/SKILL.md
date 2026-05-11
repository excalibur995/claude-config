---
name: lean-read
description: Use before reading any file — enforces grep-first targeting to avoid full file reads that waste tokens
---

# Intent

Never read a file in full when you only need part of it. Large files read in full are the single biggest source of wasted tokens. This skill enforces a grep-first discipline: locate the target lines first, then read only that range.

# Rules

**NEVER** call Read on a file without first knowing which lines you need — unless the file is guaranteed to be small (scripts, configs under 50 lines).

**ALWAYS** follow this sequence:

## Step 1 — Estimate file size before reading

```bash
wc -l path/to/file
```

- Under 80 lines → read freely
- 80–300 lines → grep first, then read only relevant section
- Over 300 lines → grep is mandatory; read with offset+limit only

## Step 2 — Grep for the target symbol or term

```bash
grep -n "functionName\|className\|keyword" path/to/file
```

Note the line numbers returned.

## Step 3 — Read only the relevant range

Use `offset` and `limit` on the Read tool:
- `offset`: start ~5 lines before the match
- `limit`: read ~40–60 lines (enough for context, not the whole file)

## Step 4 — Expand only if needed

If the first read was insufficient, read the next 40–60 lines. Do not re-read from the top.

# What NOT to do

- Do not Read a file just to "get familiar" with it
- Do not Read a file from line 1 when grep told you the target is on line 340
- Do not Read the same file twice — use the already-loaded content

# Trigger

Apply this skill whenever you are about to call the Read tool on any file that might be longer than 80 lines.
