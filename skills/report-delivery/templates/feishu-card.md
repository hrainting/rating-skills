# Feishu / Lark report card contract

Do not copy a static JSON skeleton. Build each new card through the current `lark-im` Card workflow.

## Required workflow

1. Read `lark-shared/SKILL.md` and `lark-im/SKILL.md`.
2. Read `lark-im/references/card/lark-im-card-create.md`.
3. Default Card 2.0 (`"schema":"2.0"`).
4. For a report card use: header + one primary conclusion + 1 KPI/summary block + at most 3 supports + one caveat + dated URL button.
5. Pass P0–P7. P0–P3 are blocking.
6. Save payload under the task folder and run a real `--dry-run` before send.
7. Only then send through configured webhook or authenticated lark-cli.

## Content contract

- title
- period_or_context
- primary_claim
- up to 3 supports
- one visible caveat/unknown
- primary button to dated file URL
- optional secondary destinations (max 2)
- sensitivity
- idempotency key for automation

## Receipt status

Exactly one: `sent | dry_run | skipped | blocked | failed`.

- `sent`: include target and message/response receipt when available.
- `dry_run`: include JSON path; no network call.
- `blocked`: missing permission/credential/target; never fake success.
- `failed`: include safe error summary, no secret URL/token.

## Secret rules

- No webhook/token in prompt, source, README, card JSON, logs, receipt, or public uploads.
- Environment variable or authenticated lark-cli only.
- Do not recover credentials from `raw/` mirrors.
- `env -u` is not a dry-run; dotenv can reload `.env`.
