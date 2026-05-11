---
name: no-reread
description: Use before reading any file — checks if it was already loaded this session to avoid duplicate token spend
---

# Intent

Reading the same file twice in a session doubles the token cost for that file. This skill enforces a "already seen?" check before every Read call.

# Protocol

## Step 1 — Check conversation context first

Before calling Read on any file, scan what's already in context:

- Was this file's content shown in a previous tool result this session?
- Was it included in a system-reminder at session start?
- Did a subagent return its contents?

If yes → **do not re-read**. Use the content already in context.

## Step 2 — Check if the file could have changed

If the file was read earlier in this session, ask: could it have changed since?

- You made edits to it → re-read only the edited section (use grep + offset, not full read)
- No edits were made → the cached version is still valid, use it

## Step 3 — If you must re-read, read targeted

If the file genuinely needs a fresh read (it was edited, or you need a different section), use `lean-read` discipline:
- grep for the specific part you need
- read with offset + limit, not from line 1

# Common Re-read Traps

| Trap | Fix |
|---|---|
| "Let me check that file again" | Search conversation context first |
| Reading a config file at start AND again mid-task | Read once, note the values in your response |
| Subagent reads a file, then main context reads it too | Pass relevant content in the subagent prompt instead |
| Re-reading after making a small edit | Read only the edited function/block, not the whole file |

# What NOT to do

- Do not re-read a file to "confirm" a value you already saw in context
- Do not read a file at the start of a task AND again during implementation
- Do not read the same schema/config at the beginning of multiple subtasks

# Trigger

Apply this skill every time you are about to call Read on any file.
