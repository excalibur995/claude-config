---
name: agent-brief
description: Use before spawning any subagent — enforces tight prompts and capped responses to prevent agents from flooding main context
---

# Intent

Subagents are powerful but expensive. A poorly prompted agent explores broadly, reads many files, and returns a wall of text — all of which lands in the main context. This skill enforces discipline on both the prompt sent to the agent and the response received back.

# Rules

## Rule 1 — Give agents a scalpel, not a shovel

Every agent prompt must specify:
1. **Exact files or directories** to look at — not "explore the codebase"
2. **Specific question** to answer — not "understand how X works"
3. **Response format and length cap** — always include "report under 150 words" or equivalent

Bad prompt:
> "Explore the codebase and understand how authentication works, then tell me what files are involved."

Good prompt:
> "Read `src/middlewares/auth.ts` and `src/api/user/routes/user.ts`. Answer in under 100 words: what guard is applied to the user route and where is it defined?"

## Rule 2 — Cap every agent response

Always end the agent prompt with one of:
- "Report in under 150 words."
- "Return only: [specific format]. No explanation."
- "List only the file paths. No content."
- "Answer yes/no with one sentence of reasoning."

## Rule 3 — Do not spawn agents for tasks solvable with one tool call

| Task | Use agent? |
|---|---|
| Find where a function is defined | No — use `grep -rn` directly |
| Read a single known file | No — use Read directly |
| Run a known command | No — use Bash directly |
| Explore 5+ files and synthesize | Yes |
| Research across a large unknown codebase | Yes |
| Run multi-step verification | Yes |

## Rule 4 — Pass context, don't make agents rediscover it

If you already know relevant file paths, function names, or content from earlier in the session, include that in the agent prompt. Agents that have to discover what you already know waste tokens doing redundant work.

## Rule 5 — Use `subagent_type: "Explore"` for read-only tasks

The Explore agent is optimized for targeted lookups. Use it instead of general-purpose when the task is pure research (no writes, no edits).

# Agent Prompt Template

```
Context: [1-2 sentences of what you already know]
Task: [specific question or action]
Scope: look only at [specific files/dirs]
Return: [exact format], under [N] words. Nothing else.
```

# Trigger

Apply this skill every time you are about to call the Agent tool.
