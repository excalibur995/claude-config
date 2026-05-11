---
name: Token-saving skills — auto-apply
description: Five custom skills installed globally to save tokens; must be applied automatically without user prompting
type: feedback
---

User has installed 5 custom global skills under `~/.claude/skills/` specifically to save tokens. Apply them automatically — the user should never have to ask.

**Why:** Token cost is a priority. These skills exist precisely so the user doesn't have to police behavior manually.

**How to apply:** Before any of the following actions, invoke the corresponding skill via the Skill tool:

| Action | Skill to invoke |
|---|---|
| About to call Read on any file | `lean-read` + `no-reread` |
| Starting a task that requires exploring unknown code | `lean-explore` |
| About to run a Bash command with potentially large output | `output-filter` |
| About to call the Agent tool | `agent-brief` |

Skills are already installed — just invoke them. No setup needed.
