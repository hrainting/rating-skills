#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' \
    'Usage:' \
    '  goal-hook.sh install --session <id> [--workspace <path>] [--dry-run]' \
    '  goal-hook.sh status  --session <id> [--workspace <path>]' \
    '  goal-hook.sh remove  --session <id> [--workspace <path>]'
}

command_name="${1:-}"
if [[ -z "$command_name" ]]; then
  usage >&2
  exit 2
fi
shift

session_id="${COHUB_SESSION_ID:-}"
workspace="${COHUB_WORKSPACE_DIR:-$PWD}"
dry_run=0

while (($#)); do
  case "$1" in
    --session)
      session_id="${2:-}"
      shift 2
      ;;
    --workspace)
      workspace="${2:-}"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! "$session_id" =~ ^[A-Za-z0-9_-]+$ ]]; then
  printf 'Invalid or missing session id\n' >&2
  exit 2
fi
if [[ ! -d "$workspace" ]]; then
  printf 'Workspace does not exist: %s\n' "$workspace" >&2
  exit 2
fi
workspace="$(cd "$workspace" && pwd)"

state_rel=".cohub/goals/$session_id"
hook_rel=".cohub/hooks/goal-$session_id.yml"
hook_path="$workspace/$hook_rel"
script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

render_hook() {
  cat <<YAML
schema: cohub.space-hook.v1

on:
  event: session.turn.finalized
  sessionIds:
    - $session_id

prompt:
  sessionId: $session_id
  text: |
    Independently verify the latest normal Turn for goal session $session_id.
    Read $state_rel/GOAL.md, TODO.md, PROGRESS.md, and BLOCKED.md.
    Treat the preceding agent's success claims as untrusted evidence.
    Re-run the narrow safe acceptance checks, inspect the actual diff or destination state,
    and update TODO.md, PROGRESS.md, and BLOCKED.md with Fact, Unknown, and residual risk.
    Do not broaden scope, publish, send notifications, change access, modify Scheduled prompts,
    or delete anything except the exact Hook named below.
    If and only if every completion condition passes, write $state_rel/VERIFIED.md with the
    verification commands and result, then run:
      bash $script_path remove --session $session_id --workspace $workspace
    If verification fails or is blocked, keep the Hook and record the smallest next action.
  intent: followup
  accessMode: full_access
YAML
}

case "$command_name" in
  install)
    if ((dry_run)); then
      render_hook
      exit 0
    fi
    mkdir -p "$workspace/.cohub/hooks" "$workspace/$state_rel"
    tmp_path="$hook_path.tmp"
    render_hook >"$tmp_path"
    mv "$tmp_path" "$hook_path"
    printf 'installed=%s\nstate=%s\n' "$hook_rel" "$state_rel"
    ;;
  status)
    if [[ -f "$hook_path" ]]; then
      printf 'installed=%s\n' "$hook_rel"
    else
      printf 'absent=%s\n' "$hook_rel"
      exit 1
    fi
    ;;
  remove)
    if ((dry_run)); then
      printf 'would_remove=%s\n' "$hook_rel"
      exit 0
    fi
    if [[ -f "$hook_path" ]]; then
      rm -- "$hook_path"
      printf 'removed=%s\n' "$hook_rel"
    else
      printf 'already_absent=%s\n' "$hook_rel"
    fi
    ;;
  *)
    printf 'Unknown command: %s\n' "$command_name" >&2
    usage >&2
    exit 2
    ;;
esac
