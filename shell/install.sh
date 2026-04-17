#!/usr/bin/env bash
# shell/install.sh — zsh + oh-my-zsh + powerlevel10k deployment
# Interface: install_shell | backup_shell | status_shell

_SHELL_DIR="${DOTFILES_ROOT}/shell"

install_shell() {
  log_info "[shell] deploying..."
  _shell_install_omz
  _shell_clone_plugins
  _shell_deploy_zshrc
  _shell_deploy_p10k
}

backup_shell() {
  log_info "[shell] capturing from machine..."
  local tmpl_dir="${_SHELL_DIR}/templates"
  mkdir -p "$tmpl_dir"

  # .zshrc — template out secrets
  if [[ -f ~/.zshrc && ! -L ~/.zshrc ]]; then
    log_info "[shell] templating .zshrc..."
    [[ "$DRY_RUN" == true ]] || python3 -c "
import re
with open('$HOME/.zshrc') as f: content = f.read()
content = re.sub(r'(ANTHROPIC_API_KEY=\")([^\"]+)(\")', r'\1\${ANTHROPIC_API_KEY}\3', content)
content = re.sub(r'(OPENAI_API_KEY=\")([^\"]+)(\")', r'\1\${OPENAI_API_KEY}\3', content)
content = re.sub(r'(ALIBABA_API_KEY=\")([^\"]+)(\")', r'\1\${ALIBABA_API_KEY}\3', content)
content = re.sub(r'(IAP_APPLE_KEY_ID=\")([^\"]+)(\")', r'\1\${IAP_APPLE_KEY_ID}\3', content)
content = re.sub(r'(IAP_APPLE_ISSUER_ID=\")([^\"]+)(\")', r'\1\${IAP_APPLE_ISSUER_ID}\3', content)
content = re.sub(r'sk-[A-Za-z0-9_-]{20,}', '\${API_KEY_REDACTED}', content)
with open('${tmpl_dir}/.zshrc.tmpl', 'w') as f: f.write(content)
print('ok')
" && log_info "[shell] .zshrc.tmpl updated"
  fi

  # .p10k.zsh — safe to copy directly
  if [[ -f ~/.p10k.zsh ]]; then
    [[ "$DRY_RUN" == true ]] || cp ~/.p10k.zsh "${_SHELL_DIR}/files/.p10k.zsh"
    log_info "[shell] .p10k.zsh captured"
  fi
}

status_shell() {
  _status_symlink "${HOME}/.zshrc"
  _status_symlink "${HOME}/.p10k.zsh"
  echo "  oh-my-zsh: $([ -d ~/.oh-my-zsh ] && echo installed || echo MISSING)"
}

# --- internal -----------------------------------------------------------

_shell_install_omz() {
  if [[ -d ~/.oh-my-zsh ]]; then
    log_info "[shell] oh-my-zsh already installed"; return 0
  fi
  log_info "[shell] installing oh-my-zsh..."
  [[ "$DRY_RUN" == true ]] && { log_info "[dry-run] would install oh-my-zsh"; return 0; }
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

_shell_clone_plugins() {
  local manifest="${_SHELL_DIR}/oh-my-zsh-plugins.txt"
  [[ -f "$manifest" ]] || return 0
  local name url dest
  while read -r name url; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    if [[ "$name" == theme:* ]]; then
      dest="${HOME}/.oh-my-zsh/custom/themes/${name#theme:}"
    else
      dest="${HOME}/.oh-my-zsh/custom/plugins/${name}"
    fi
    if [[ -d "$dest" ]]; then
      log_debug "[shell] $name already present"
    else
      log_info "[shell] cloning $name..."
      [[ "$DRY_RUN" == true ]] || git clone --depth=1 "$url" "$dest"
    fi
  done < "$manifest"
}

_shell_deploy_zshrc() {
  local tmpl="${_SHELL_DIR}/templates/.zshrc.tmpl"
  local dest="${HOME}/.zshrc"
  if [[ -f "$tmpl" ]]; then
    backup_file "$dest"
    render_template "$tmpl" "$dest"
    log_info "[shell] .zshrc rendered from template"
  else
    log_warn "[shell] no .zshrc.tmpl found — skipping"
  fi
}

_shell_deploy_p10k() {
  local src="${_SHELL_DIR}/files/.p10k.zsh"
  [[ -f "$src" ]] && create_symlink "$src" "${HOME}/.p10k.zsh"
}
