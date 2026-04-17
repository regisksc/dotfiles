#!/usr/bin/env bash
# progress.sh — machine-readable progress journal for LLM handoff.
#
# Appends JSONL entries to state/progress.jsonl so that a fresh LLM
# session can read PROGRESS.md + this file and know exactly where we are.

progress_mark() {
  local step="$1" status="$2" note="${3:-}"
  local f="${STATE_DIR}/progress.jsonl"
  mkdir -p "$STATE_DIR"
  printf '{"ts":"%s","step":"%s","status":"%s","mode":"%s","os":"%s","machine":"%s","dry_run":%s,"note":"%s"}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$step" "$status" "${MODE:-unknown}" \
    "${OS:-unknown}" "${MACHINE_NAME:-unknown}" "${DRY_RUN:-false}" "$note" \
    >> "$f"
}
