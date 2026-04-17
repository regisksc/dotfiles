#!/usr/bin/env bash
# ai/cursor/install.sh — Cursor AI environment deployment
# Interface: install_ai_cursor | backup_ai_cursor | status_ai_cursor

CURSOR_DIR="${HOME}/.cursor"
CURSOR_SRC="${DOTFILES_ROOT}/ai/cursor"

_PUBLIC_DIRS=(skills rules)
_PUBLIC_DIRS_SEPARATE=(skills-cursor)
_TEMPLATE_FILES=(mcp.json argv.json cli-config.json)

install_ai_cursor() {
  log_info "[ai/cursor] deploying..."
  mkdir -p "$CURSOR_DIR"

  local sub
  for sub in "${_PUBLIC_DIRS[@]}"; do
    local src="${CURSOR_SRC}/public/${sub}"
    [[ -d "$src" ]] || continue
    local dest="${CURSOR_DIR}/${sub}"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      log_debug "[ai/cursor] $sub already linked"
    else
      backup_file "$dest"
      [[ "$DRY_RUN" == true ]] || { rm -rf "$dest"; ln -s "$src" "$dest"; }
      log_action "symlink" "$dest" "prev" "$src" "" "ok" "rm $dest"
      log_info "[ai/cursor] linked $sub"
    fi
  done

  # Render templates
  local f
  for f in "${_TEMPLATE_FILES[@]}"; do
    local tmpl="${CURSOR_SRC}/templates/${f}.tmpl"
    [[ -f "$tmpl" ]] || continue
    local dest="${CURSOR_DIR}/${f}"
    backup_file "$dest"
    render_template "$tmpl" "$dest"
    log_info "[ai/cursor] rendered $f"
  done
}

backup_ai_cursor() {
  log_info "[ai/cursor] capturing from ~/.cursor/..."
  local pub="${CURSOR_SRC}/public"
  local tmpl_dir="${CURSOR_SRC}/templates"
  mkdir -p "$pub" "$tmpl_dir"

  local sub
  for sub in "${_PUBLIC_DIRS[@]}" "${_PUBLIC_DIRS_SEPARATE[@]}"; do
    local src="${CURSOR_DIR}/${sub}"
    [[ -d "$src" && ! -L "$src" ]] || continue
    [[ "$DRY_RUN" == true ]] || rsync -a --delete "${src}/" "${pub}/${sub}/"
    log_info "[ai/cursor] captured $sub"
  done

  local f
  for f in "${_TEMPLATE_FILES[@]}"; do
    local src="${CURSOR_DIR}/${f}"
    [[ -f "$src" ]] || continue
    log_info "[ai/cursor] templating $f..."
    [[ "$DRY_RUN" == true ]] || \
      python3 -c "
import json, re, sys
with open('$src') as fh:
    try: d = json.load(fh)
    except: sys.exit(0)
def scrub(obj, key=''):
    if isinstance(obj, dict): return {k: scrub(v, k) for k,v in obj.items()}
    if isinstance(obj, list): return [scrub(i, key) for i in obj]
    if isinstance(obj, str) and re.search(r'(key|token|secret|api)', key, re.I) and len(obj) > 8:
        return '\${CURSOR_' + re.sub(r'[^A-Z0-9]','_', key.upper()) + '}'
    return obj
print(json.dumps(scrub(d), indent=2))
" > "${tmpl_dir}/${f}.tmpl" 2>/dev/null || cp "$src" "${tmpl_dir}/${f}.tmpl"
  done
}

status_ai_cursor() {
  local sub
  for sub in "${_PUBLIC_DIRS[@]}" mcp.json; do
    local p="${CURSOR_DIR}/${sub}"
    if [[ -L "$p" ]];   then echo "  cursor/$sub → $(readlink "$p") [symlink]"
    elif [[ -e "$p" ]]; then echo "  cursor/$sub [exists]"
    else                     echo "  cursor/$sub [MISSING]"
    fi
  done
}
