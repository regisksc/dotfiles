#!/usr/bin/env bash
# ai/qwen/install.sh — Qwen AI environment deployment
# Interface: install_ai_qwen | backup_ai_qwen | status_ai_qwen

QWEN_DIR="${HOME}/.qwen"
QWEN_SRC="${DOTFILES_ROOT}/ai/qwen"

_PUBLIC_DIRS=(skills rules)
_PUBLIC_FILES=(QWEN.md output-language.md)
_TEMPLATE_FILES=(settings.json)     # may contain API keys — scrubbed on backup
_IGNORE=(oauth_creds.json debug tmp projects installation_id todos)

install_ai_qwen() {
  log_info "[ai/qwen] deploying..."
  mkdir -p "$QWEN_DIR"

  local sub
  for sub in "${_PUBLIC_DIRS[@]}"; do
    local src="${QWEN_SRC}/public/${sub}"
    [[ -d "$src" ]] || continue
    local dest="${QWEN_DIR}/${sub}"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      log_debug "[ai/qwen] $sub already linked"
    else
      backup_file "$dest"
      [[ "$DRY_RUN" == true ]] || { rm -rf "$dest"; ln -s "$src" "$dest"; }
      log_action "symlink" "$dest" "prev" "$src" "" "ok" "rm $dest"
      log_info "[ai/qwen] linked $sub"
    fi
  done

  local f
  for f in "${_PUBLIC_FILES[@]}"; do
    local src="${QWEN_SRC}/public/${f}"
    [[ -f "$src" ]] && create_symlink "$src" "${QWEN_DIR}/${f}"
  done

  # Render templated files (secrets substituted from .env.local)
  for f in "${_TEMPLATE_FILES[@]}"; do
    local tmpl="${QWEN_SRC}/templates/${f}.tmpl"
    [[ -f "$tmpl" ]] || continue
    backup_file "${QWEN_DIR}/${f}"
    render_template "$tmpl" "${QWEN_DIR}/${f}"
    log_info "[ai/qwen] rendered $f"
  done
}

backup_ai_qwen() {
  log_info "[ai/qwen] capturing from ~/.qwen/..."
  local pub="${QWEN_SRC}/public"
  local tmpl_dir="${QWEN_SRC}/templates"
  mkdir -p "$pub" "$tmpl_dir"

  local sub
  for sub in "${_PUBLIC_DIRS[@]}"; do
    local src="${QWEN_DIR}/${sub}"
    [[ -d "$src" && ! -L "$src" ]] || continue
    [[ "$DRY_RUN" == true ]] || rsync -a --delete "${src}/" "${pub}/${sub}/"
    log_info "[ai/qwen] captured $sub"
  done

  local f
  for f in "${_PUBLIC_FILES[@]}"; do
    local src="${QWEN_DIR}/${f}"
    [[ -f "$src" && ! -L "$src" ]] || continue
    [[ "$DRY_RUN" == true ]] || cp "$src" "${pub}/${f}"
    log_info "[ai/qwen] captured $f"
  done

  # Template out settings.json — scrub API keys
  for f in "${_TEMPLATE_FILES[@]}"; do
    local src="${QWEN_DIR}/${f}"
    [[ -f "$src" ]] || continue
    log_info "[ai/qwen] templating $f..."
    [[ "$DRY_RUN" == true ]] || python3 -c "
import json, re, sys
with open('$src') as fh:
    try: d = json.load(fh)
    except: sys.exit(0)
def scrub(obj, key=''):
    if isinstance(obj, dict): return {k: scrub(v, k) for k,v in obj.items()}
    if isinstance(obj, list): return [scrub(i, key) for i in obj]
    if isinstance(obj, str) and re.search(r'sk-[A-Za-z0-9_-]{20,}', obj): return '\${ALIBABA_API_KEY}'
    if isinstance(obj, str) and re.search(r'(key|token|secret)', key, re.I) and len(obj) > 8:
        return '\${QWEN_' + re.sub(r'[^A-Z0-9]','_', key.upper()) + '}'
    return obj
print(json.dumps(scrub(d), indent=2))
" > "${tmpl_dir}/${f}.tmpl" 2>/dev/null || cp "$src" "${tmpl_dir}/${f}.tmpl"
  done
}

status_ai_qwen() {
  local items=("${_PUBLIC_DIRS[@]}" "${_PUBLIC_FILES[@]}")
  local item
  for item in "${items[@]}"; do
    local p="${QWEN_DIR}/${item}"
    if [[ -L "$p" ]];   then echo "  qwen/$item → $(readlink "$p") [symlink]"
    elif [[ -e "$p" ]]; then echo "  qwen/$item [exists]"
    else                     echo "  qwen/$item [MISSING]"
    fi
  done
}
