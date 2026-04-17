#!/bin/bash
# Auto-syncs graphify and mempalace to project-specific local Obsidian vault
# Triggered automatically on SessionStart by Claude/OpenCode

PROJECT_NAME=$(basename "$PWD")
ROOT_VAULT="$HOME/macbookm2pro-root"
AGGREGATOR_DIR="$ROOT_VAULT/AI-Memories/$PROJECT_NAME"

# 1. Setup isolated un-tracked Obsidian Vault locally
if [ -d ".git" ] || [ -f "pubspec.yaml" ] || [ -f "package.json" ]; then
  mkdir -p .ai-vault/knowledge
  
  # Ignore locally via .git/info/exclude WITHOUT touching .gitignore
  if [ -d ".git" ]; then
    mkdir -p .git/info
    touch .git/info/exclude
    if ! grep -q "^.ai-vault" .git/info/exclude; then
      echo -e "\n# AI Memory Vault" >> .git/info/exclude
      echo ".ai-vault/" >> .git/info/exclude
    fi
  fi

  # Create tracking symlink to Global Root Vault Aggregator
  mkdir -p "$ROOT_VAULT/AI-Memories"
  # Attempt symlink; if Obsidian ignores it, notes can still be directly written by the AI instructions.
  ln -sfn "$PWD/.ai-vault" "$AGGREGATOR_DIR"

  # 2. Mine new notes into system-wide memory cache seamlessly
  if command -v mempalace &> /dev/null; then
    mempalace mine .ai-vault >/dev/null 2>&1 &
  elif [ -f "$HOME/.local/bin/mempalace" ]; then
    $HOME/.local/bin/mempalace mine .ai-vault >/dev/null 2>&1 &
  fi

  # 3. Synchronize Graphify auto-updates directly into the .ai-vault
  if command -v graphify &> /dev/null; then
    graphify . --obsidian --obsidian-dir .ai-vault --update >/dev/null 2>&1 &
  elif [ -f "$HOME/.local/bin/graphify" ]; then
    $HOME/.local/bin/graphify . --obsidian --obsidian-dir .ai-vault --update >/dev/null 2>&1 &
  fi
fi
