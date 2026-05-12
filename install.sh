#!/bin/bash
set -e

DOTDIR="$(cd "$(dirname "$0")" && pwd)"
USERNAME=$(whoami)

# ── Usage ─────────────────────────────────────────────────────────────────────

usage() {
  echo "Usage: ./install.sh [--claude | --cursor | --windsurf | --codex | --all]"
  echo ""
  echo "  --claude     Install Claude Code config (skills, hooks, settings, memory)"
  echo "  --cursor     Deploy token optimization rules + RTK for Cursor"
  echo "  --windsurf   Deploy token optimization rules + RTK for Windsurf"
  echo "  --codex      Deploy token optimization rules + RTK for Codex"
  echo "  --all        Install everything above"
  echo ""
  echo "  Default (no args): --claude"
  exit 0
}

# ── Arg parsing ───────────────────────────────────────────────────────────────

DO_CLAUDE=false
DO_CURSOR=false
DO_WINDSURF=false
DO_CODEX=false

if [ $# -eq 0 ]; then
  DO_CLAUDE=true
else
  for arg in "$@"; do
    case $arg in
      --claude)   DO_CLAUDE=true ;;
      --cursor)   DO_CURSOR=true ;;
      --windsurf) DO_WINDSURF=true ;;
      --codex)    DO_CODEX=true ;;
      --all)      DO_CLAUDE=true; DO_CURSOR=true; DO_WINDSURF=true; DO_CODEX=true ;;
      --help|-h)  usage ;;
      *) echo "Unknown option: $arg"; usage ;;
    esac
  done
fi

# ── Shared dependencies ───────────────────────────────────────────────────────

install_brew_pkg() {
  local pkg=$1
  if ! command -v brew &>/dev/null; then
    echo "⚠ Homebrew not found. Install it from https://brew.sh, then re-run this script."
    exit 1
  fi
  echo "  Installing $pkg via Homebrew..."
  brew install "$pkg"
}

ensure_docs_deps() {
  if ! command -v pandoc &>/dev/null; then
    echo "⚠ pandoc not found — required for convert-doc"
    install_brew_pkg pandoc
  fi
  echo "✓ pandoc ready"

  if ! command -v pdftotext &>/dev/null; then
    echo "⚠ pdftotext not found — required for convert-doc (PDF)"
    install_brew_pkg poppler
  fi
  echo "✓ pdftotext ready"
}

# ── Installers ────────────────────────────────────────────────────────────────

ensure_spreadsheet_deps() {
  local brew_ok=false
  local pipx_ok=false

  command -v brew &>/dev/null && brew_ok=true
  command -v pipx &>/dev/null && pipx_ok=true

  # csvkit (in2csv, csvcut, csvgrep, csvstat)
  if ! command -v in2csv &>/dev/null; then
    echo "⚠ csvkit not found — required for convert-spreadsheet"
    if $brew_ok; then
      echo "  Installing csvkit via Homebrew..."
      brew install csvkit
    else
      echo "  Installing csvkit via pip..."
      pip install --user csvkit
    fi
  fi
  echo "✓ csvkit ready"

  # xlsx2csv (not in brew, use pipx or pip)
  if ! command -v xlsx2csv &>/dev/null; then
    echo "⚠ xlsx2csv not found — required for convert-spreadsheet"
    if ! $pipx_ok; then
      if $brew_ok; then
        echo "  Installing pipx via Homebrew..."
        brew install pipx
        pipx_ok=true
      else
        echo "  Installing pipx via pip..."
        pip install --user pipx
        pipx_ok=true
      fi
    fi
    echo "  Installing xlsx2csv via pipx..."
    pipx install xlsx2csv
  fi
  echo "✓ xlsx2csv ready"

  # ssconvert (gnumeric) — fallback for ods/xls
  if ! command -v ssconvert &>/dev/null; then
    echo "⚠ ssconvert not found — required for convert-spreadsheet (ODS/XLS fallback)"
    if $brew_ok; then
      echo "  Installing gnumeric via Homebrew..."
      brew install gnumeric
    else
      echo "  Installing gnumeric via apt..."
      sudo apt-get install -y gnumeric
    fi
  fi
  echo "✓ ssconvert ready"
}

install_claude() {
  echo "── Claude Code ──────────────────────────────────────────────────────────────"
  GLOBAL_MEM="$HOME/.claude/projects/-Users-$USERNAME/memory"

  ensure_docs_deps
  ensure_spreadsheet_deps
  echo ""

  rm -rf ~/.claude/skills
  ln -sf "$DOTDIR/skills" ~/.claude/skills
  echo "✓ Skills linked"

  cp "$DOTDIR/CLAUDE.md" ~/.claude/CLAUDE.md
  cp "$DOTDIR/RTK.md" ~/.claude/RTK.md
  echo "✓ CLAUDE.md and RTK.md copied"

  mkdir -p ~/.claude/hooks
  cp -r "$DOTDIR/hooks/." ~/.claude/hooks/
  chmod +x ~/.claude/hooks/*.sh 2>/dev/null || true
  echo "✓ Hooks installed"

  cp "$DOTDIR/settings.json" ~/.claude/settings.json
  echo "✓ Settings applied"

  mkdir -p "$GLOBAL_MEM"
  cp -r "$DOTDIR/global-memory/." "$GLOBAL_MEM/"
  echo "✓ Global memory installed"

  echo ""
  echo "Restart Claude Code to apply changes."
}

install_cursor() {
  echo "── Cursor ───────────────────────────────────────────────────────────────────"
  mkdir -p "$HOME/.cursor/rules"
  cp "$DOTDIR/rules/cursor-rules.mdc" "$HOME/.cursor/rules/token-optimization.mdc"
  echo "✓ Rules deployed → ~/.cursor/rules/token-optimization.mdc"

  if command -v rtk &>/dev/null; then
    rtk init -g --agent cursor 2>/dev/null && echo "✓ RTK initialized for Cursor" || echo "⚠ RTK Cursor init failed"
  else
    echo "⚠ rtk not found — install from https://github.com/rtk-ai/rtk then re-run"
  fi

  echo ""
  echo "Restart Cursor to apply changes."
}

install_windsurf() {
  echo "── Windsurf ─────────────────────────────────────────────────────────────────"
  mkdir -p "$HOME/.windsurf/rules"
  cp "$DOTDIR/rules/windsurf-rules.md" "$HOME/.windsurf/rules/token-optimization.md"
  echo "✓ Rules deployed → ~/.windsurf/rules/token-optimization.md"

  if command -v rtk &>/dev/null; then
    rtk init -g --agent windsurf 2>/dev/null && echo "✓ RTK initialized for Windsurf" || echo "⚠ RTK Windsurf init failed"
  else
    echo "⚠ rtk not found — install from https://github.com/rtk-ai/rtk then re-run"
  fi

  echo ""
  echo "Restart Windsurf to apply changes."
}

install_codex() {
  echo "── Codex ────────────────────────────────────────────────────────────────────"
  mkdir -p "$HOME/.codex"
  cp "$DOTDIR/rules/codex-rules.md" "$HOME/.codex/AGENTS.md"
  echo "✓ Rules deployed → ~/.codex/AGENTS.md"

  if command -v rtk &>/dev/null; then
    rtk init -g --codex 2>/dev/null && echo "✓ RTK initialized for Codex" || echo "⚠ RTK Codex init failed"
  else
    echo "⚠ rtk not found — install from https://github.com/rtk-ai/rtk then re-run"
  fi

  echo ""
  echo "Codex will pick up AGENTS.md automatically on next run."
}

# ── Run ───────────────────────────────────────────────────────────────────────

echo "Claude config installer — user: $USERNAME"
echo ""

$DO_CLAUDE   && install_claude
$DO_CURSOR   && install_cursor
$DO_WINDSURF && install_windsurf
$DO_CODEX    && install_codex
