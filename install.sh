#!/bin/bash
set -e

DOTDIR="$(cd "$(dirname "$0")" && pwd)"
USERNAME=$(whoami)
GLOBAL_MEM="$HOME/.claude/projects/-Users-$USERNAME/memory"

echo "Installing Claude config for: $USERNAME"
echo ""

# ── Dependencies ─────────────────────────────────────────────────────────────

install_brew_pkg() {
  local pkg=$1
  if ! command -v brew &>/dev/null; then
    echo "⚠ Homebrew not found. Install it from https://brew.sh, then re-run this script."
    exit 1
  fi
  echo "  Installing $pkg via Homebrew..."
  brew install "$pkg"
}

# pandoc
if ! command -v pandoc &>/dev/null; then
  echo "⚠ pandoc not found — required for convert-doc skill (DOCX/HTML/XML/RST/LATEX)"
  install_brew_pkg pandoc
fi
echo "✓ pandoc ready"

# pdftotext (part of poppler)
if ! command -v pdftotext &>/dev/null; then
  echo "⚠ pdftotext not found — required for convert-doc skill (PDF)"
  install_brew_pkg poppler
fi
echo "✓ pdftotext ready"

echo ""

# ── Claude config ─────────────────────────────────────────────────────────────

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

# ── Other AI tools — rules deployment ─────────────────────────────────────────

deploy_rules() {
  local tool=$1
  local dest=$2
  local src=$3
  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "✓ $tool rules deployed → $dest"
  fi
}

# Cursor — global rules (applies to all projects)
deploy_rules "Cursor" "$HOME/.cursor/rules/token-optimization.mdc" "$DOTDIR/rules/cursor-rules.mdc"

# Windsurf — global rules
deploy_rules "Windsurf" "$HOME/.windsurf/rules/token-optimization.md" "$DOTDIR/rules/windsurf-rules.md"

# Codex — global AGENTS.md (OpenAI Codex reads this)
deploy_rules "Codex" "$HOME/.codex/AGENTS.md" "$DOTDIR/rules/codex-rules.md"

# RTK init for each tool (if rtk is installed)
if command -v rtk &>/dev/null; then
  echo ""
  echo "Initializing RTK for other AI tools..."
  rtk init -g --agent cursor  2>/dev/null && echo "✓ RTK → Cursor" || echo "⚠ RTK Cursor init skipped"
  rtk init -g --agent windsurf 2>/dev/null && echo "✓ RTK → Windsurf" || echo "⚠ RTK Windsurf init skipped"
  rtk init -g --codex          2>/dev/null && echo "✓ RTK → Codex" || echo "⚠ RTK Codex init skipped"
else
  echo "⚠ rtk not found — skipping RTK init for Cursor/Windsurf/Codex"
  echo "  Install RTK from https://github.com/rtk-ai/rtk then re-run install.sh"
fi

echo ""
echo "Done. Restart Claude Code, Cursor, and Windsurf to apply changes."
