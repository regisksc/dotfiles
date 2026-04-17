#!/usr/bin/env bash
# ai/install.sh — AI environment orchestrator
# Sources all AI tool sub-installers and exposes:
#   install_ai | backup_ai | status_ai

source "${DOTFILES_ROOT}/ai/claude/install.sh"
source "${DOTFILES_ROOT}/ai/opencode/install.sh"
source "${DOTFILES_ROOT}/ai/goose/install.sh"
source "${DOTFILES_ROOT}/ai/cursor/install.sh"
source "${DOTFILES_ROOT}/ai/qwen/install.sh"
source "${DOTFILES_ROOT}/ai/antigravity/install.sh"

install_ai() {
  install_ai_claude
  install_ai_opencode
  install_ai_goose
  install_ai_cursor
  install_ai_qwen
  install_ai_antigravity
}

backup_ai() {
  backup_ai_claude
  backup_ai_opencode
  backup_ai_goose
  backup_ai_cursor
  backup_ai_qwen
  backup_ai_antigravity
}

status_ai() {
  echo "=== Claude ==="       && status_ai_claude
  echo "=== Opencode ==="     && status_ai_opencode
  echo "=== Goose ==="        && status_ai_goose
  echo "=== Cursor ==="       && status_ai_cursor
  echo "=== Qwen ==="         && status_ai_qwen
  echo "=== Antigravity ==="  && status_ai_antigravity
}
