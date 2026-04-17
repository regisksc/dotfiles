#!/usr/bin/env bash
# agents/install.sh — ~/.agents/skills + ~/.agent-stack repos
# Interface: install_agents | backup_agents | status_agents

_AGENTS_DIR="${DOTFILES_ROOT}/agents"
AGENTS_DIR="${HOME}/.agents"
AGENT_STACK_DIR="${HOME}/.agent-stack/src"

install_agents() {
  log_info "[agents] deploying..."
  _agents_deploy_skills
  _agents_clone_stack
}

backup_agents() {
  log_info "[agents] capturing ~/.agents/skills/..."
  local dest="${_AGENTS_DIR}/skills"
  mkdir -p "$dest"
  if [[ -d "${AGENTS_DIR}/skills" && ! -L "${AGENTS_DIR}/skills" ]]; then
    [[ "$DRY_RUN" == true ]] || rsync -a --delete "${AGENTS_DIR}/skills/" "${dest}/"
    log_info "[agents] captured $(ls "$dest" | wc -l | tr -d ' ') skills"
  fi
  log_info "[agents] agent-stack repos already recorded in agent-stack-repos.txt"
}

status_agents() {
  local skills_count
  skills_count="$(ls "${AGENTS_DIR}/skills/" 2>/dev/null | wc -l | tr -d ' ')"
  echo "  ~/.agents/skills: ${skills_count} skills"
  local repo
  while read -r repo _; do
    [[ -z "$repo" || "$repo" == \#* ]] && continue
    local p="${AGENT_STACK_DIR}/${repo}"
    if [[ -d "$p" ]]; then echo "  agent-stack/$repo [present]"
    else                   echo "  agent-stack/$repo [MISSING]"
    fi
  done < "${_AGENTS_DIR}/agent-stack-repos.txt"
}

_agents_deploy_skills() {
  local src="${_AGENTS_DIR}/skills"
  local dest="${AGENTS_DIR}/skills"
  [[ -d "$src" ]] || { log_warn "[agents] no skills/ in repo"; return 0; }
  mkdir -p "${AGENTS_DIR}"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    log_debug "[agents] skills already linked"
  else
    backup_file "$dest"
    [[ "$DRY_RUN" == true ]] || { rm -rf "$dest"; ln -s "$src" "$dest"; }
    log_action "symlink" "$dest" "prev" "$src" "" "ok" "rm $dest"
    log_info "[agents] linked skills ($(ls "$src" | wc -l | tr -d ' ') entries)"
  fi
}

_agents_clone_stack() {
  local manifest="${_AGENTS_DIR}/agent-stack-repos.txt"
  [[ -f "$manifest" ]] || return 0
  mkdir -p "${AGENT_STACK_DIR}"
  local name url
  while read -r name url; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    local dest="${AGENT_STACK_DIR}/${name}"
    if [[ -d "$dest" ]]; then
      log_debug "[agents] agent-stack/$name already present"
    else
      log_info "[agents] cloning agent-stack/$name..."
      [[ "$DRY_RUN" == true ]] || git clone "$url" "$dest"
    fi
  done < "$manifest"
}
