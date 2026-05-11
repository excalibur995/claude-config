# Claude Config

Personal Claude Code configuration — skills, hooks, global memory, and plugin settings.

---

## New machine setup

### Prerequisites

- [Claude Code](https://claude.ai/code) installed and logged in
- Git configured (`git config --global user.name` and `user.email`)
- Homebrew (Mac) — install from https://brew.sh if missing

### Install

```bash
git clone https://github.com/excalibur995/claude-config.git ~/claude-config
cd ~/claude-config && ./install.sh
```

The script installs `pandoc` and `poppler` via Homebrew automatically if they're missing, then sets up all Claude config files.

Restart Claude Code after install.

---

## What gets installed

| Item | Location |
|---|---|
| Custom skills | `~/.claude/skills/` (symlinked) |
| Global instructions | `~/.claude/CLAUDE.md`, `~/.claude/RTK.md` |
| Hooks | `~/.claude/hooks/` |
| Plugin settings | `~/.claude/settings.json` |
| Global memory | `~/.claude/projects/-Users-<username>/memory/` |
| pandoc | system — DOCX/HTML/XML/RST/LATEX conversion |
| pdftotext | system — PDF text extraction |

---

## Skills included

| Skill | What it does |
|---|---|
| `lean-read` | Grep before reading; use offset+limit, never full-file reads |
| `lean-explore` | Use find/grep chains before opening any file |
| `output-filter` | Cap large command output before it enters context |
| `no-reread` | Skip re-reading files already loaded this session |
| `agent-brief` | Tight subagent prompts with capped responses |
| `convert-doc` | Convert DOCX/HTML/PDF to markdown before reading |

Skills are applied automatically by Claude based on context — no manual invocation needed.

---

## Syncing changes

After editing skills or config on any machine:

```bash
cd ~/claude-config
git add .
git commit -m "your message"
git push
```

On the other machine:

```bash
cd ~/claude-config
git pull && ./install.sh
```

---

## Adding a new skill

```bash
mkdir ~/.claude/skills/your-skill-name
# write ~/.claude/skills/your-skill-name/SKILL.md
```

Sync to repo:

```bash
cp -r ~/.claude/skills/your-skill-name ~/claude-config/skills/
cd ~/claude-config && git add . && git commit -m "add skill: your-skill-name" && git push
```
