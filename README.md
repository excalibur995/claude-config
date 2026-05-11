# Claude Config

Personal Claude Code configuration — skills, hooks, global memory, and plugin settings.

## First-time setup (any machine)

```bash
git clone https://github.com/excalibur995/claude-config.git ~/claude-config
cd ~/claude-config && ./install.sh
```

Restart Claude Code after install.

## What gets installed

| Item | Location |
|---|---|
| Custom skills | `~/.claude/skills/` |
| Global instructions | `~/.claude/CLAUDE.md`, `~/.claude/RTK.md` |
| Hooks | `~/.claude/hooks/` |
| Plugin settings | `~/.claude/settings.json` |
| Global memory | `~/.claude/projects/-Users-<username>/memory/` |

## Syncing changes

After adding or editing skills/config on any machine:

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

## Adding a new skill

```bash
mkdir ~/.claude/skills/your-skill-name
# create SKILL.md with frontmatter (name, description) and instructions
```

Then sync to repo:

```bash
cp -r ~/.claude/skills/your-skill-name ~/claude-config/skills/
cd ~/claude-config && git add . && git commit -m "add skill: your-skill-name" && git push
```
