#!/usr/bin/env bash
# ai/claude/install.sh — Claude Code environment deployment
# Interface: install_ai_claude | backup_ai_claude | status_ai_claude
#
# Layout:
#   public/   → symlinked into ~/.claude/
#   templates/ → rendered into ~/.claude/ from .env.local vars

CLAUDE_DIR="${HOME}/.claude"
CLAUDE_SRC="${DOTFILES_ROOT}/ai/claude"

install_ai_claude() {
  log_info "[ai/claude] deploying..."
  mkdir -p "$CLAUDE_DIR"

  # Deploy public subtrees via symlinks
  local sub
  for sub in skills hooks agents get-shit-done context-mode homunculus; do
    local src="${CLAUDE_SRC}/public/${sub}"
    [[ -d "$src" ]] || continue
    local dest="${CLAUDE_DIR}/${sub}"
    # Symlink the whole directory (not contents) so new files auto-appear
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      log_debug "[ai/claude] $sub already linked"
    else
      backup_file "$dest"
      [[ "$DRY_RUN" == true ]] || { rm -rf "$dest"; ln -s "$src" "$dest"; }
      log_action "symlink" "$dest" "prev" "$src" "" "ok" "rm $dest"
      log_info "[ai/claude] linked $sub"
    fi
  done

  # Render settings.json from template
  local tmpl="${CLAUDE_SRC}/templates/settings.json.tmpl"
  local dest_cfg="${CLAUDE_DIR}/settings.json"
  if [[ -f "$tmpl" ]]; then
    backup_file "$dest_cfg"
    render_template "$tmpl" "$dest_cfg"
    log_info "[ai/claude] settings.json rendered"
  else
    log_warn "[ai/claude] no settings.json.tmpl — skipping"
  fi
}

backup_ai_claude() {
  log_info "[ai/claude] capturing from ~/.claude/..."
  local pub="${CLAUDE_SRC}/public"
  mkdir -p "$pub"

  # Copy directory trees that are safe to commit publicly
  local sub
  for sub in skills hooks agents get-shit-done context-mode homunculus; do
    local src="${CLAUDE_DIR}/${sub}"
    [[ -d "$src" ]] || continue
    # Skip if already a symlink back to repo
    [[ -L "$src" ]] && continue
    log_info "[ai/claude] capturing $sub..."
    [[ "$DRY_RUN" == true ]] || rsync -a --delete \
      --exclude='sessions/' --exclude='*.db' --exclude='*.db-shm' --exclude='*.db-wal' \
      "${src}/" "${pub}/${sub}/"
  done

  # Create settings.json template (strip env/secret keys)
  local cfg="${CLAUDE_DIR}/settings.json"
  local tmpl="${CLAUDE_SRC}/templates/settings.json.tmpl"
  if [[ -f "$cfg" ]]; then
    log_info "[ai/claude] generating settings.json.tmpl..."
    [[ "$DRY_RUN" == true ]] || \
      python3 -c "
import json, sys
with open('$cfg') as f: d = json.load(f)
# Strip env vars (may contain API keys) — leave as placeholder
if 'env' in d:
    d['env'] = {k: '\${' + k + '}' for k in d['env']}
print(json.dumps(d, indent=2))
" > "$tmpl" 2>/dev/null || cp "$cfg" "$tmpl"
  fi
}

status_ai_claude() {
  local sub
  for sub in skills hooks agents get-shit-done settings.json; do
    local p="${CLAUDE_DIR}/${sub}"
    if [[ -L "$p" ]]; then
      echo "  ~/.claude/$sub → $(readlink "$p") [symlink]"
    elif [[ -e "$p" ]]; then
      echo "  ~/.claude/$sub [exists, not linked]"
    else
      echo "  ~/.claude/$sub [MISSING]"
    fi
  done
}
