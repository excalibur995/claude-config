#!/bin/bash
set -e

DOTDIR="$(cd "$(dirname "$0")" && pwd)"
USERNAME=$(whoami)
GLOBAL_MEM="$HOME/.claude/projects/-Users-$USERNAME/memory"

echo "Installing Claude config for: $USERNAME"

# Skills
rm -rf ~/.claude/skills
ln -sf "$DOTDIR/skills" ~/.claude/skills
echo "✓ Skills linked"

# Global instructions
cp "$DOTDIR/CLAUDE.md" ~/.claude/CLAUDE.md
cp "$DOTDIR/RTK.md" ~/.claude/RTK.md
echo "✓ CLAUDE.md and RTK.md copied"

# Hooks
mkdir -p ~/.claude/hooks
cp -r "$DOTDIR/hooks/." ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh 2>/dev/null || true
echo "✓ Hooks installed"

# Settings
cp "$DOTDIR/settings.json" ~/.claude/settings.json
echo "✓ Settings applied"

# Global memory
mkdir -p "$GLOBAL_MEM"
cp -r "$DOTDIR/global-memory/." "$GLOBAL_MEM/"
echo "✓ Global memory installed"

echo ""
echo "Done. Restart Claude Code to apply changes."
