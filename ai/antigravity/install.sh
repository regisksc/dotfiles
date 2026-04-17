#!/usr/bin/env bash
# ai/antigravity/install.sh — Antigravity (Gemini) environment deployment
# Manages two locations:
#   ~/.gemini/antigravity/   (main app config)
#   ~/.gemini/               (root: GEMINI.md, skills, settings)
# Interface: install_ai_antigravity | backup_ai_antigravity | status_ai_antigravity

ANTIGRAVITY_DIR="${HOME}/.gemini/antigravity"
GEMINI_DIR="${HOME}/.gemini"
AG_SRC="${DOTFILES_ROOT}/ai/antigravity"

_AG_PUBLIC_DIRS=(skills hooks agents get-shit-done)
_AG_TEMPLATE_FILES=(settings.json mcp_config.json)
_GEMINI_PUBLIC_FILES=(GEMINI.md)
_GEMINI_PUBLIC_DIRS=(skills)
_GEMINI_TEMPLATE_FILES=(settings.json)

install_ai_antigravity() {
  log_info "[ai/antigravity] deploying..."
  mkdir -p "$ANTIGRAVITY_DIR" "$GEMINI_DIR"

  # ~/.gemini/antigravity/ — public dirs
  local sub
  for sub in "${_AG_PUBLIC_DIRS[@]}"; do
    local src="${AG_SRC}/public/antigravity/${sub}"
    [[ -d "$src" ]] || continue
    local dest="${ANTIGRAVITY_DIR}/${sub}"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      log_debug "[ai/antigravity] $sub already linked"
    else
      backup_file "$dest"
      [[ "$DRY_RUN" == true ]] || { rm -rf "$dest"; ln -s "$src" "$dest"; }
      log_action "symlink" "$dest" "prev" "$src" "" "ok" "rm $dest"
      log_info "[ai/antigravity] linked antigravity/$sub"
    fi
  done

  # ~/.gemini/antigravity/ — templates
  local f
  for f in "${_AG_TEMPLATE_FILES[@]}"; do
    local tmpl="${AG_SRC}/templates/antigravity/${f}.tmpl"
    [[ -f "$tmpl" ]] || continue
    backup_file "${ANTIGRAVITY_DIR}/${f}"
    render_template "$tmpl" "${ANTIGRAVITY_DIR}/${f}"
    log_info "[ai/antigravity] rendered antigravity/$f"
  done

  # ~/.gemini/ root — public files
  for f in "${_GEMINI_PUBLIC_FILES[@]}"; do
    local src="${AG_SRC}/public/gemini/${f}"
    [[ -f "$src" ]] && create_symlink "$src" "${GEMINI_DIR}/${f}"
  done

  # ~/.gemini/ root — public dirs
  for sub in "${_GEMINI_PUBLIC_DIRS[@]}"; do
    local src="${AG_SRC}/public/gemini/${sub}"
    [[ -d "$src" ]] || continue
    local dest="${GEMINI_DIR}/${sub}"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      log_debug "[ai/antigravity] gemini/$sub already linked"
    else
      backup_file "$dest"
      [[ "$DRY_RUN" == true ]] || { rm -rf "$dest"; ln -s "$src" "$dest"; }
      log_info "[ai/antigravity] linked gemini/$sub"
    fi
  done

  # ~/.gemini/ root — templates
  for f in "${_GEMINI_TEMPLATE_FILES[@]}"; do
    local tmpl="${AG_SRC}/templates/gemini/${f}.tmpl"
    [[ -f "$tmpl" ]] || continue
    backup_file "${GEMINI_DIR}/${f}"
    render_template "$tmpl" "${GEMINI_DIR}/${f}"
    log_info "[ai/antigravity] rendered gemini/$f"
  done
}

backup_ai_antigravity() {
  log_info "[ai/antigravity] capturing from ~/.gemini/antigravity/ and ~/.gemini/..."
  local pub_ag="${AG_SRC}/public/antigravity"
  local pub_g="${AG_SRC}/public/gemini"
  local tmpl_ag="${AG_SRC}/templates/antigravity"
  local tmpl_g="${AG_SRC}/templates/gemini"
  mkdir -p "$pub_ag" "$pub_g" "$tmpl_ag" "$tmpl_g"

  # antigravity/ public dirs
  local sub
  for sub in "${_AG_PUBLIC_DIRS[@]}"; do
    local src="${ANTIGRAVITY_DIR}/${sub}"
    [[ -d "$src" && ! -L "$src" ]] || continue
    [[ "$DRY_RUN" == true ]] || rsync -a --delete "${src}/" "${pub_ag}/${sub}/"
    log_info "[ai/antigravity] captured antigravity/$sub"
  done

  # antigravity/ templates
  local f
  for f in "${_AG_TEMPLATE_FILES[@]}"; do
    local src="${ANTIGRAVITY_DIR}/${f}"
    [[ -f "$src" ]] || continue
    log_info "[ai/antigravity] templating antigravity/$f..."
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
        return '\${AG_' + re.sub(r'[^A-Z0-9]','_', key.upper()) + '}'
    return obj
print(json.dumps(scrub(d), indent=2))
" > "${tmpl_ag}/${f}.tmpl" 2>/dev/null || cp "$src" "${tmpl_ag}/${f}.tmpl"
  done

  # ~/.gemini/ root public files
  for f in "${_GEMINI_PUBLIC_FILES[@]}"; do
    local src="${GEMINI_DIR}/${f}"
    [[ -f "$src" && ! -L "$src" ]] || continue
    [[ "$DRY_RUN" == true ]] || cp "$src" "${pub_g}/${f}"
    log_info "[ai/antigravity] captured gemini/$f"
  done

  # ~/.gemini/ root public dirs
  for sub in "${_GEMINI_PUBLIC_DIRS[@]}"; do
    local src="${GEMINI_DIR}/${sub}"
    [[ -d "$src" && ! -L "$src" ]] || continue
    [[ "$DRY_RUN" == true ]] || rsync -a --delete "${src}/" "${pub_g}/${sub}/"
    log_info "[ai/antigravity] captured gemini/$sub"
  done

  # ~/.gemini/ root templates
  for f in "${_GEMINI_TEMPLATE_FILES[@]}"; do
    local src="${GEMINI_DIR}/${f}"
    [[ -f "$src" ]] || continue
    log_info "[ai/antigravity] templating gemini/$f..."
    [[ "$DRY_RUN" == true ]] || \
      python3 -c "
import json, re, sys
with open('$src') as fh:
    try: d = json.load(fh.read() if hasattr(fh,'read') else fh)
    except: import shutil; shutil.copy('$src','${tmpl_g}/${f}.tmpl'); sys.exit(0)
def scrub(obj, key=''):
    if isinstance(obj, dict): return {k: scrub(v, k) for k,v in obj.items()}
    if isinstance(obj, list): return [scrub(i, key) for i in obj]
    if isinstance(obj, str) and re.search(r'(key|token|secret|api)', key, re.I) and len(obj) > 8:
        return '\${GEMINI_' + re.sub(r'[^A-Z0-9]','_', key.upper()) + '}'
    return obj
print(json.dumps(scrub(d), indent=2))
" > "${tmpl_g}/${f}.tmpl" 2>/dev/null || cp "$src" "${tmpl_g}/${f}.tmpl"
  done
}

status_ai_antigravity() {
  echo "  antigravity dir: ${ANTIGRAVITY_DIR}"
  local sub
  for sub in "${_AG_PUBLIC_DIRS[@]}" settings.json; do
    local p="${ANTIGRAVITY_DIR}/${sub}"
    if [[ -L "$p" ]];   then echo "    $sub → $(readlink "$p") [symlink]"
    elif [[ -e "$p" ]]; then echo "    $sub [exists]"
    else                     echo "    $sub [MISSING]"
    fi
  done
  echo "  gemini root: ${GEMINI_DIR}"
  for sub in GEMINI.md skills settings.json; do
    local p="${GEMINI_DIR}/${sub}"
    if [[ -L "$p" ]];   then echo "    $sub → $(readlink "$p") [symlink]"
    elif [[ -e "$p" ]]; then echo "    $sub [exists]"
    else                     echo "    $sub [MISSING]"
    fi
  done
}
