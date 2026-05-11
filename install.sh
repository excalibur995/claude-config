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
echo "Done. Restart Claude Code to apply changes."
