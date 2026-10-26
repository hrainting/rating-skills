#!/usr/bin/env bash
# reusable.email wrapper for authorized non-Neta QA targets.
set -euo pipefail

API="${REUSABLE_EMAIL_API_BASE:-https://api.reusable.email/v1/agent-tempmail}"
ADDRESS="${REUSABLE_EMAIL_ADDRESS:-}"
TOKEN="${REUSABLE_EMAIL_TOKEN:-}"
PROXY="${REUSABLE_EMAIL_PROXY:-}"
HTTP_TIMEOUT="${REUSABLE_EMAIL_HTTP_TIMEOUT:-30}"

CURL=(curl -fsS --connect-timeout 15)
if [[ -n "$PROXY" ]]; then
  CURL+=(--proxy "$PROXY")
fi

usage() {
  cat >&2 <<'EOF'
usage: reusable-email.sh manifest
       reusable-email.sh create [prefix]
       reusable-email.sh baseline
       reusable-email.sh list [limit]
       reusable-email.sh read <message-id>
       reusable-email.sh source <message-id>
       reusable-email.sh wait [timeout-seconds] [code-only]

environment:
  TEMPMAIL_TARGET_HOST          required by create; Neta domains are blocked
  REUSABLE_EMAIL_ADDRESS        required by mailbox commands
  REUSABLE_EMAIL_TOKEN          required by mailbox commands
  REUSABLE_EMAIL_API_BASE       optional API override
  REUSABLE_EMAIL_PROXY          optional scoped curl proxy
  REUSABLE_EMAIL_HTTP_TIMEOUT   default request timeout; default 30 seconds
EOF
  exit 2
}

die() {
  printf 'reusable-email: %s\n' "$*" >&2
  exit 2
}

is_uint() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

request() {
  "${CURL[@]}" --max-time "$HTTP_TIMEOUT" "$@"
}

encode() {
  jq -rn --arg value "$1" '$value | @uri'
}

require_target() {
  local host="${TEMPMAIL_TARGET_HOST:-}"
  [[ -n "$host" ]] || die 'TEMPMAIL_TARGET_HOST is required before creating a reusable.email inbox'
  host="${host#*://}"
  host="${host%%/*}"
  host="${host%%:*}"
  host="${host%.}"
  host="${host,,}"
  [[ -n "$host" ]] || die 'TEMPMAIL_TARGET_HOST does not contain a valid host'
  if [[ "$host" == "neta.art" || "$host" == *.neta.art ]]; then
    die 'reusable.email is blocked for Neta Studio; use the private tempmail.sh provider'
  fi
}

require_inbox() {
  [[ -n "$ADDRESS" ]] || die 'REUSABLE_EMAIL_ADDRESS is required for this command'
  [[ -n "$TOKEN" ]] || die 'REUSABLE_EMAIL_TOKEN is required for this command'
}

inbox_request() {
  require_inbox
  request -H "Authorization: Inbox $TOKEN" "$@"
}

cmd="${1:-}"
[[ -n "$cmd" ]] || usage
shift || true

case "$cmd" in
  manifest)
    (($# == 0)) || usage
    request "$API"
    ;;

  create)
    (($# <= 1)) || usage
    require_target
    prefix="${1:-competitor-qa}"
    payload="$(jq -nc --arg prefix "$prefix" '{prefix:$prefix}')"
    request -X POST "$API/inboxes" \
      -H 'Content-Type: application/json' \
      --data-binary "$payload"
    ;;

  baseline)
    (($# == 0)) || usage
    inbox_request "$API/inboxes/$(encode "$ADDRESS")/messages?limit=100" \
      | jq -r '[.messages[]?.id] | max // 0'
    ;;

  list)
    (($# <= 1)) || usage
    limit="${1:-20}"
    is_uint "$limit" && ((limit >= 1 && limit <= 100)) \
      || die 'limit must be an integer from 1 to 100'
    inbox_request "$API/inboxes/$(encode "$ADDRESS")/messages?limit=$limit"
    ;;

  read|source)
    (($# == 1)) || usage
    id="$1"
    is_uint "$id" || die 'message-id must be a non-negative integer'
    suffix=""
    [[ "$cmd" == "source" ]] && suffix="/source"
    inbox_request "$API/inboxes/$(encode "$ADDRESS")/messages/$id$suffix"
    ;;

  wait)
    (($# <= 2)) || usage
    timeout="${1:-60}"
    code_only="${2:-true}"
    is_uint "$timeout" && ((timeout >= 1 && timeout <= 60)) \
      || die 'timeout-seconds must be an integer from 1 to 60'
    [[ "$code_only" == "true" || "$code_only" == "false" ]] \
      || die 'code-only must be true or false'
    require_inbox
    payload="$(jq -nc --argjson codeOnly "$code_only" --argjson timeoutSeconds "$timeout" \
      '{codeOnly:$codeOnly,timeoutSeconds:$timeoutSeconds}')"
    "${CURL[@]}" --max-time "$((timeout + 10))" \
      -X POST "$API/inboxes/$(encode "$ADDRESS")/wait" \
      -H "Authorization: Inbox $TOKEN" \
      -H 'Content-Type: application/json' \
      --data-binary "$payload"
    ;;

  *)
    usage
    ;;
esac
