#!/usr/bin/env bash
# ai/goose/install.sh — Goose AI environment deployment
# Interface: install_ai_goose | backup_ai_goose | status_ai_goose

GOOSE_DIR="${HOME}/.config/goose"
GOOSE_SRC="${DOTFILES_ROOT}/ai/goose"

install_ai_goose() {
  log_info "[ai/goose] deploying..."
  mkdir -p "$GOOSE_DIR"

  # Public subtree
  for sub in skills; do
    local src="${GOOSE_SRC}/public/${sub}"
    [[ -d "$src" ]] || continue
    local dest="${GOOSE_DIR}/${sub}"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      log_debug "[ai/goose] $sub already linked"
    else
      backup_file "$dest"
      [[ "$DRY_RUN" == true ]] || { rm -rf "$dest"; ln -s "$src" "$dest"; }
      log_info "[ai/goose] linked $sub"
    fi
  done

  # Render config from template
  local tmpl="${GOOSE_SRC}/templates/config.yaml.tmpl"
  local dest="${GOOSE_DIR}/config.yaml"
  if [[ -f "$tmpl" ]]; then
    backup_file "$dest"
    render_template "$tmpl" "$dest"
    log_info "[ai/goose] config.yaml rendered"
  fi

  # Render custom_providers from templates
  if [[ -d "${GOOSE_SRC}/templates/custom_providers" ]]; then
    mkdir -p "${GOOSE_DIR}/custom_providers"
    local f
    while IFS= read -r -d '' f; do
      local rel="${f#"${GOOSE_SRC}/templates/custom_providers"/}"
      local dest_f="${GOOSE_DIR}/custom_providers/${rel%.tmpl}"
      render_template "$f" "$dest_f"
    done < <(find "${GOOSE_SRC}/templates/custom_providers" -name '*.tmpl' -print0)
  fi
}

backup_ai_goose() {
  log_info "[ai/goose] capturing from ~/.config/goose/..."
  local pub="${GOOSE_SRC}/public"
  local tmpl_dir="${GOOSE_SRC}/templates"
  mkdir -p "$pub" "$tmpl_dir"

  # Public: skills
  for sub in skills; do
    local src="${GOOSE_DIR}/${sub}"
    [[ -d "$src" && ! -L "$src" ]] || continue
    [[ "$DRY_RUN" == true ]] || rsync -a --delete "${src}/" "${pub}/${sub}/"
  done

  # config.yaml — scrub api keys using python (sed -e with \U not portable on macOS)
  local cfg="${GOOSE_DIR}/config.yaml"
  if [[ -f "$cfg" ]]; then
    [[ "$DRY_RUN" == true ]] || python3 -c "
import re
with open('$cfg') as f: content = f.read()
# Replace sk-* style keys
content = re.sub(r'sk-[A-Za-z0-9_-]{20,}', '\${ALIBABA_API_KEY}', content)
# Replace any remaining bare secrets on key:/token:/secret: lines
content = re.sub(
    r'((?:api_key|token|secret|password)\s*:\s*)([^\n\r]{8,})',
    lambda m: m.group(1) + '\${GOOSE_' + re.sub(r'[^A-Z0-9]','_', m.group(1).split(':')[0].strip().upper()) + '}',
    content
)
with open('${tmpl_dir}/config.yaml.tmpl', 'w') as f: f.write(content)
"
    log_info "[ai/goose] config.yaml.tmpl created"
  fi

  # custom_providers — template api keys
  if [[ -d "${GOOSE_DIR}/custom_providers" ]]; then
    mkdir -p "${tmpl_dir}/custom_providers"
    local f
    while IFS= read -r -d '' f; do
      local rel="${f#"${GOOSE_DIR}/custom_providers"/}"
      [[ "$DRY_RUN" == true ]] || python3 -c "
import re
with open('$f') as fh: content = fh.read()
content = re.sub(r'sk-[A-Za-z0-9_-]{20,}', '\${ALIBABA_API_KEY}', content)
content = re.sub(
    r'((?:api_key|token|secret|password)\s*:\s*)([^\n\r]{8,})',
    lambda m: m.group(1) + '\${GOOSE_' + re.sub(r'[^A-Z0-9]','_', m.group(1).split(':')[0].strip().upper()) + '}',
    content
)
with open('${tmpl_dir}/custom_providers/${rel}.tmpl', 'w') as fh: fh.write(content)
"
    done < <(find "${GOOSE_DIR}/custom_providers" -type f -print0)
    log_info "[ai/goose] custom_providers templated"
  fi
}

status_ai_goose() {
  local p="${GOOSE_DIR}/config.yaml"
  if [[ -f "$p" ]]; then echo "  goose/config.yaml [exists]"
  else echo "  goose/config.yaml [MISSING]"
  fi
}
