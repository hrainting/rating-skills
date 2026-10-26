#!/usr/bin/env bash
# cloudflare_temp_email wrapper. Secrets are read from the session environment only.
set -euo pipefail

API="${TEMPMAIL_API_BASE:-https://email-api.313797.xyz}"
DOMAIN="${TEMPMAIL_DOMAIN:-313797.xyz}"
PROXY="${TEMPMAIL_PROXY:-}"
HTTP_TIMEOUT="${TEMPMAIL_HTTP_TIMEOUT:-30}"
MAIL_API_MODE="${TEMPMAIL_MAIL_API_MODE:-auto}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PARSER="$SCRIPT_DIR/parse_mail.py"

CURL=(curl -fsS --connect-timeout 15 --max-time "$HTTP_TIMEOUT")
if [[ -n "$PROXY" ]]; then
  CURL+=(--proxy "$PROXY")
fi

usage() {
  cat >&2 <<'EOF'
usage: tempmail.sh probe
       tempmail.sh create [name] [domain]
       tempmail.sh settings
       tempmail.sh baseline
       tempmail.sh list [limit] [offset]
       tempmail.sh read <message-id>
       tempmail.sh wait [timeout-seconds] [after-message-id]

environment:
  TEMPMAIL_ADMIN_PASSWORD  required by create
  TEMPMAIL_JWT             required by inbox commands
  TEMPMAIL_PROXY           optional curl proxy (for example socks5h://127.0.0.1:40000)
  TEMPMAIL_MAIL_API_MODE    auto (default), parsed, or raw
EOF
  exit 2
}

die() {
  printf 'tempmail: %s\n' "$*" >&2
  exit 2
}

is_uint() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

request() {
  "${CURL[@]}" "$@"
}

require_admin() {
  [[ -n "${TEMPMAIL_ADMIN_PASSWORD:-}" ]] || die 'TEMPMAIL_ADMIN_PASSWORD is required for create'
}

require_jwt() {
  [[ -n "${TEMPMAIL_JWT:-}" ]] || die 'TEMPMAIL_JWT is required for this command'
}

auth_request() {
  require_jwt
  request -H "Authorization: Bearer $TEMPMAIL_JWT" "$@"
}

detect_mail_api() {
  case "$MAIL_API_MODE" in
    parsed|raw)
      return
      ;;
    auto)
      if auth_request "$API/api/parsed_mails?limit=1&offset=0" >/dev/null 2>&1; then
        MAIL_API_MODE=parsed
      else
        MAIL_API_MODE=raw
      fi
      ;;
    *)
      die 'TEMPMAIL_MAIL_API_MODE must be auto, parsed, or raw'
      ;;
  esac
}

list_messages() {
  local limit="$1" offset="$2"
  if [[ "$MAIL_API_MODE" == parsed ]]; then
    auth_request "$API/api/parsed_mails?limit=$limit&offset=$offset"
  else
    auth_request "$API/api/mails?limit=$limit&offset=$offset" | python3 "$PARSER" list
  fi
}

read_message() {
  local id="$1"
  if [[ "$MAIL_API_MODE" == parsed ]]; then
    auth_request "$API/api/parsed_mail/$id"
  else
    auth_request "$API/api/mail/$id" | python3 "$PARSER" one
  fi
}

cmd="${1:-}"
[[ -n "$cmd" ]] || usage
shift || true

case "$cmd" in
  probe)
    (($# == 0)) || usage
    request "$API/open_api/settings"
    ;;

  create)
    (($# <= 2)) || usage
    require_admin
    name="${1:-agent$(date -u +%m%d%H%M%S)$(od -An -N2 -tx2 /dev/urandom | tr -d ' \n')}"
    domain="${2:-$DOMAIN}"
    payload="$(jq -nc --arg name "$name" --arg domain "$domain" '{name:$name,domain:$domain}')"
    request -X POST "$API/admin/new_address" \
      -H "x-admin-auth: $TEMPMAIL_ADMIN_PASSWORD" \
      -H 'Content-Type: application/json' \
      --data-binary "$payload"
    ;;

  settings)
    (($# == 0)) || usage
    auth_request "$API/api/settings"
    ;;

  baseline)
    (($# == 0)) || usage
    detect_mail_api
    list_messages 1 0 | jq -r '.results[0].id // 0'
    ;;

  list)
    (($# <= 2)) || usage
    limit="${1:-20}"
    offset="${2:-0}"
    is_uint "$limit" && ((limit >= 1 && limit <= 100)) || die 'limit must be an integer from 1 to 100'
    is_uint "$offset" || die 'offset must be a non-negative integer'
    detect_mail_api
    list_messages "$limit" "$offset"
    ;;

  read)
    (($# == 1)) || usage
    id="$1"
    is_uint "$id" || die 'message-id must be a non-negative integer'
    detect_mail_api
    read_message "$id"
    ;;

  wait)
    (($# <= 2)) || usage
    timeout="${1:-90}"
    after_id="${2:-0}"
    is_uint "$timeout" && ((timeout >= 1)) || die 'timeout-seconds must be a positive integer'
    is_uint "$after_id" || die 'after-message-id must be a non-negative integer'
    detect_mail_api

    started="$(date +%s)"
    delay=3
    while (( $(date +%s) - started < timeout )); do
      if inbox="$(list_messages 20 0)"; then
        message="$(jq -c --argjson after "$after_id" \
          '[.results[]? | select((.id | tonumber) > $after)] | sort_by(.id | tonumber) | last // empty' \
          <<<"$inbox")"
        if [[ -n "$message" ]]; then
          code="$(jq -r \
            '[.subject // "", .text // "", .html // ""] | join("\n")
             | (capture("(^|[^0-9])(?<code>[0-9]{4,8})([^0-9]|$)")? | .code) // empty' \
            <<<"$message")"
          jq -nc --argjson message "$message" --arg code "$code" \
            '{status:"message",message:($message + (if $code == "" then {} else {verificationCode:$code} end))}'
          exit 0
        fi
      fi
      sleep "$delay"
      ((delay < 10)) && ((delay += 2))
    done

    jq -nc --arg address "${TEMPMAIL_ADDRESS:-}" --argjson after "$after_id" \
      '{status:"timeout",inbox:{address:$address},afterMessageId:$after,message:null}'
    exit 1
    ;;

  *)
    usage
    ;;
esac
