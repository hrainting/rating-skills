---
name: tempmail
description: Route authorized disposable-email QA between the private cloudflare_temp_email deployment required for Neta Studio and reusable.email as an optional provider for competitor or other target sites that accept it. Supports mailbox creation, OTP polling, message reads, and attachment metadata without exposing a real inbox.
source: dreamhunter2333/cloudflare_temp_email commit d04c1a865dbfedd1a05feba10046193d3adf22da (source date 2026-07-31) · reusable.email agent-tempmail manifest checked 2026-08-05 · Rating compatibility decision 2026-08-05 · live Neta registration retest 2026-08-05
---

# Temp Mail (临时邮箱)

Create a disposable mailbox, use it in an authorized registration or sign-in flow, poll for a verification code, and complete the flow without exposing a real mailbox. Provider compatibility is target-specific and must be decided before creating an inbox.

## Provider routing

| Target | Provider | Status and rule |
|---|---|---|
| Neta Studio (`neta.art`, `auth.neta.art`, or any `*.neta.art`) | Private `cloudflare_temp_email` deployment | Required. Registration passed on 2026-08-05. |
| Competitor or other authorized QA target | `reusable.email` candidate | Consider first when the target accepts the domain; acceptance and delivery remain unverified until observed for that target. |
| Target known to reject disposable/public domains | Private deployment or a separately approved identity | Do not retry `reusable.email` as though the first rejection were transient. |
| Unknown target | No default assumption | Check dated compatibility evidence or run one explicitly authorized attempt; record success/failure by provider and target. |

**Hard rule:** reusable.email must not be used for Neta Studio registration. The older 2026-08-03 Neta/reusable.email compatibility record is superseded by Rating's 2026-08-05 decision and must not be used for routing.

Do not silently switch providers after a target rejects an address. First distinguish invalid-domain rejection, Turnstile/form failure, and email-delivery timeout; then record the provider/target result before another authorized attempt.

## Providers

### Private provider: Neta-compatible

- API base: `https://email-api.313797.xyz`
- Default domain: `313797.xyz`
- Backend: [`dreamhunter2333/cloudflare_temp_email`](https://github.com/dreamhunter2333/cloudflare_temp_email)
- Mailbox creation: admin API with a session-only admin password
- Inbox access: Address JWT returned by mailbox creation
- Network constraint: direct sandbox traffic is challenged by Cloudflare; a WARP-backed local proxy is required in the tested Cohub environment

Do not put the admin password in this file, a script, command argument, browser profile, task artifact, Save, or response. Supply it only through `TEMPMAIL_ADMIN_PASSWORD` for the process that creates the mailbox.

### Optional provider: reusable.email

- API base: `https://api.reusable.email/v1/agent-tempmail`
- No account or API key is required; inbox creation returns an address and Inbox token.
- Manifest reachability and API contract were checked on 2026-08-05; retention limit reported by the service is 90 days.
- Use only for competitor/other target QA where it is accepted. It is explicitly blocked for Neta Studio.
- Compatibility with any competitor is a dated observation, not a permanent provider guarantee.

## When to use

- A website requires an email OTP or verification link and the user explicitly authorizes a test registration or sign-in.
- A QA flow needs a disposable identity without exposing a real mailbox.
- An authorized competitor registration check can use reusable.email when the target accepts it.
- The user asks for a temporary mailbox, inbox polling, or a verification email readout.

Use `agent-browser` for the website. This skill owns mailbox creation and mail retrieval.

## Safety boundaries

1. **Admin password is restricted**: keep it only in `TEMPMAIL_ADMIN_PASSWORD` for the current process. Unset it immediately after `create` succeeds.
2. **Address JWT is a bearer credential**: keep it only in `TEMPMAIL_JWT` or another session-scoped secret channel. Never persist it in credentials files, code, reports, screenshots, browser state exports, or replies.
3. **Address and OTP are test-account PII**: redact the full address, code, cookies, and session IDs from distributable artifacts.
4. **Create only authorized accounts**: no bulk signup, spam, identity bypass, ban evasion, or use that violates the target site's terms.
5. **No real payment**: a disposable-mail account must not make a real purchase unless the user separately authorizes that exact payment test.
6. **Account creation is an external side effect**: the user must explicitly request or approve the registration. Approval to register does not authorize profile publication, payment, outbound mail, or account deletion.
7. **Keep proxies scoped**: route the mailbox API and target auth flow through WARP when required; do not send Cohub APIs or unrelated traffic through it.
8. **Provider compatibility is dated**: never infer that reusable.email works on Neta or on every competitor. Record the target host, provider, date, and observed outcome.

## Core flow

```text
1. Identify the target host and select a provider from the routing table.
2. Obtain explicit authorization for the registration/account side effect.
3a. Neta/private: start scoped WARP, create -> Address JWT, then unset admin password.
3b. Competitor/reusable: declare TEMPMAIL_TARGET_HOST, create -> Inbox token.
4. Record baseline where supported, then submit the address on the target site.
5. Poll the selected provider -> message + verificationCode.
6. Enter the OTP or open the verification link; verify the target URL/state.
7. Record target/provider/date/outcome and any rejection class.
8. Close the browser and unset mailbox/proxy credentials.
```

## Included wrappers

### Private provider

`scripts/tempmail.sh` is the Neta-compatible wrapper. It prefers the server-side parsed endpoints and automatically falls back to `/api/mails` plus the standard-library MIME parser in `scripts/parse_mail.py` when the deployment returns `404`:

```text
probe                         Public deployment settings and domains
create [name] [domain]        Create mailbox; requires TEMPMAIL_ADMIN_PASSWORD
settings                      Validate TEMPMAIL_JWT and show address settings
baseline                      Print newest message ID, or 0 for an empty inbox
list [limit] [offset]         List parsed messages
read <message-id>             Read one parsed message
wait [timeout] [after-id]     Poll with backoff and extract a 4-8 digit OTP
```

Private-provider environment variables:

```text
TEMPMAIL_API_BASE             Default: https://email-api.313797.xyz
TEMPMAIL_DOMAIN               Default: 313797.xyz
TEMPMAIL_ADMIN_PASSWORD       Required only by create; never persisted
TEMPMAIL_JWT                  Required by settings/baseline/list/read/wait
TEMPMAIL_ADDRESS              Optional; included in timeout diagnostics
TEMPMAIL_PROXY                Optional curl proxy, e.g. socks5h://127.0.0.1:40000
TEMPMAIL_HTTP_TIMEOUT         Per-request timeout in seconds; default 30
TEMPMAIL_MAIL_API_MODE        auto (default), parsed, or raw
```

### reusable.email provider

`scripts/reusable-email.sh` keeps the public provider's Inbox token semantics separate from the private Address JWT API:

```text
manifest                      Read the live service contract without creating an inbox
create [prefix]               Create an inbox; requires TEMPMAIL_TARGET_HOST
baseline                      Print newest message ID, or 0 for an empty inbox
list [limit]                  List messages
read <message-id>             Read one message
source <message-id>           Fetch raw RFC822 source
wait [timeout] [code-only]    Wait up to 60 seconds for a message/OTP
```

```text
TEMPMAIL_TARGET_HOST          Required by create; `neta.art` and subdomains are blocked
REUSABLE_EMAIL_ADDRESS        Required after create for mailbox operations
REUSABLE_EMAIL_TOKEN          Inbox bearer token returned by create
REUSABLE_EMAIL_API_BASE       Optional API override
REUSABLE_EMAIL_PROXY          Optional scoped curl proxy
```

### Private-provider shell example

```bash
SKILL_DIR=/configs/user/.agents/skills/tempmail
export TEMPMAIL_PROXY='socks5h://127.0.0.1:40000'
export TEMPMAIL_ADMIN_PASSWORD='<session-only admin password>'

mailbox_json="$(bash "$SKILL_DIR/scripts/tempmail.sh" create)"
export TEMPMAIL_ADDRESS="$(jq -r '.address' <<<"$mailbox_json")"
export TEMPMAIL_JWT="$(jq -r '.jwt' <<<"$mailbox_json")"
unset TEMPMAIL_ADMIN_PASSWORD mailbox_json

baseline="$(bash "$SKILL_DIR/scripts/tempmail.sh" baseline)"
# Submit $TEMPMAIL_ADDRESS on the target website now.
bash "$SKILL_DIR/scripts/tempmail.sh" wait 90 "$baseline"
```

### reusable.email competitor shell example

```bash
SKILL_DIR=/configs/user/.agents/skills/tempmail
export TEMPMAIL_TARGET_HOST='competitor.example'

mailbox_json="$(bash "$SKILL_DIR/scripts/reusable-email.sh" create competitor-qa)"
export REUSABLE_EMAIL_ADDRESS="$(jq -r '.inbox.address' <<<"$mailbox_json")"
export REUSABLE_EMAIL_TOKEN="$(jq -r '.token' <<<"$mailbox_json")"
unset mailbox_json

# Submit $REUSABLE_EMAIL_ADDRESS only to the declared, authorized target.
bash "$SKILL_DIR/scripts/reusable-email.sh" wait 60 true
```

Do not add `set -x` around either flow. Avoid passing admin passwords, Address JWTs, or Inbox tokens as positional arguments because process listings can expose them.

## Private-provider API contract

The contract was checked against upstream commit `d04c1a8`. Live deployment checks on 2026-08-05 verified `/open_api/settings`, `/admin/new_address`, `/api/settings`, `/api/mails`, and `/api/mail/<id>`. The deployment returned `404` for the newer `/api/parsed_*` endpoints, so the wrapper's raw MIME fallback is part of the tested path.

### Public settings

```http
GET /open_api/settings
```

Use this to verify reachability and discover `domains`/`defaultDomains`. It needs neither admin auth nor Address JWT, but Cloudflare may still challenge a direct sandbox IP.

### Create a mailbox

```http
POST /admin/new_address
x-admin-auth: <admin password>
Content-Type: application/json

{"name":"agent...","domain":"313797.xyz"}
```

Observed deployment response:

```json
{"address":"<redacted>@313797.xyz","jwt":"<redacted>","password":null}
```

Newer upstream builds may also return `address_id`; callers must treat it as optional. The admin password is sent directly as `x-admin-auth`. `/open_api/admin_login` is a frontend password check and is not required for this API call.

### Validate an Address JWT

```http
GET /api/settings
Authorization: Bearer <Address JWT>
```

A valid response includes `address` and `send_balance`. A `401` means the JWT is wrong, expired, or belongs to a different deployment.

### List and read parsed mail

```http
GET /api/parsed_mails?limit=20&offset=0
GET /api/parsed_mail/<id>
Authorization: Bearer <Address JWT>
```

Parsed messages include `sender`, `subject`, `text`, `html`, and attachment metadata. Attachment bytes are not included. On this deployment the wrapper falls back to `/api/mails` and `/api/mail/<id>`, parses the RFC822 `raw` payload with Python's standard `email` package, removes `raw` from its output, and preserves the same parsed shape.

## reusable.email API contract

The live manifest checked on 2026-08-05 advertises:

```http
POST /inboxes                                      # no auth; returns address + token
GET  /inboxes/{address}/messages                   # Authorization: Inbox <token>
POST /inboxes/{address}/wait                       # Authorization: Inbox <token>
GET  /inboxes/{address}/messages/{id}              # Authorization: Inbox <token>
GET  /inboxes/{address}/messages/{id}/source       # Authorization: Inbox <token>
```

The service reports `retentionDays: 90`, `maxWaitSeconds: 60`, `maxListLimit: 100`, and no outbound email. The manifest was checked without creating an inbox in this review; create/wait behavior remains based on the earlier tested contract until a target-specific authorized run is performed.

## Neta registration path

**Provider requirement:** use `scripts/tempmail.sh` with the private deployment. Do not use `scripts/reusable-email.sh` or an `@reusable.email` address.

The observed Neta flow is:

```text
neta.art -> Get started -> Continue with email -> enter address -> Sign in
-> Turnstile -> email OTP -> "No account found, create a new one?"
-> Continue -> /world/new
```

Operational sequence:

1. Verify the WARP proxy before creating the inbox:

```bash
curl -fsS --proxy "$TEMPMAIL_PROXY" https://www.cloudflare.com/cdn-cgi/trace \
  | grep -E '^(warp|colo)='
bash scripts/tempmail.sh probe | jq '{domains,defaultDomains}'
```

2. Create the mailbox, export the Address JWT, unset the admin password, and record `baseline`.
3. Launch real headed Chrome through the same proxy. In a sandbox without a desktop, run headed Chrome on Xvfb with WebGL available. The tested Chrome-for-Testing environment also required suppressing the automation-only Blink feature so the headed browser exposed its normal capabilities:

```bash
DISPLAY=:99 agent-browser --session neta-register \
  --proxy "$TEMPMAIL_PROXY" --headed \
  --args "--no-sandbox,--disable-dev-shm-usage,--disable-blink-features=AutomationControlled,--use-gl=angle,--use-angle=swiftshader,--enable-unsafe-swiftshader" \
  open https://neta.art
```

Before submitting, verify the browser is visible, `navigator.webdriver` is false, and a canvas can obtain a WebGL context. In the successful 2026-08-05 run, WebGL reported Chrome's bundled SwiftShader renderer.

4. Submit the disposable address, wait for the Turnstile checkbox, and interact with it once. A successful challenge automatically advances to the six-digit OTP page.
5. Poll immediately:

```bash
bash scripts/tempmail.sh wait 90 "$baseline"
```

6. Enter `message.verificationCode`, choose `Continue` when Logto offers account creation, and verify the final URL is `https://neta.art/world/new` (or the current equivalent first-world route).

### Turnstile constraints observed in Cohub

| Environment | Result |
|---|---|
| Direct data-center IP + Chrome | Turnstile failed |
| WARP + headless Chrome, including UA changes | Turnstile failed |
| WARP + headed Chrome, but `webdriver=true` and WebGL unavailable | Failed with Turnstile `600010` |
| WARP + headed Chrome + WebGL + `webdriver=false` | Passed; advanced to OTP |

For rootless headed mode, the tested workaround was to extract matching `xvfb` and `x11-xkb-utils` Debian packages into user space. Debian's Xvfb may exec the hard-coded `/usr/bin/xkbcomp`; when that path is unavailable, an audited `LD_PRELOAD` `execve` redirect can point exactly `/usr/bin/xkbcomp` to the extracted binary. Match the complete path string, including its null terminator, rather than using a brittle character offset.

Treat this as an environment workaround, not a CAPTCHA bypass guarantee. Never use CAPTCHA-solving services or attempt to defeat a site's access controls.

## Polling and OTP extraction

- Record a baseline message ID before triggering the email so an old message is never mistaken for the current OTP.
- Start at 3 seconds and back off to 10 seconds.
- Never poll faster than once per second.
- Respect `429`; wait and retry.
- Neta OTPs observed in testing were six digits and valid for 10 minutes. On 2026-08-05 the message from `notify.neta.art` was present on the first poll. The wrapper accepts 4-8 digit codes because other services differ.
- A timeout often means the website never sent the message because form validation or Turnstile failed. Inspect the page before creating another mailbox.

## Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| Neta rejects or does not proceed with `@reusable.email` | Provider is incompatible with the target | Stop; use the private provider on the next explicitly authorized Neta attempt and record reusable.email as rejected |
| A competitor rejects `@reusable.email` before sending | Domain/provider policy, not inbox latency | Record target/provider/date as rejected; do not poll or repeatedly resubmit the same address |
| `403` with `Just a moment...` from the private mailbox API | Cloudflare managed challenge on the direct sandbox IP | Use a verified WARP-backed local proxy and set `TEMPMAIL_PROXY` |
| `401` from `/admin/new_address` | Missing or wrong `x-admin-auth` | Re-supply `TEMPMAIL_ADMIN_PASSWORD` through the session environment; do not persist it |
| `401 InvalidAddressCredentialMsg` | Wrong/expired Address JWT or wrong header | Use `Authorization: Bearer`, validate with `settings`, recreate only when necessary |
| `wait` times out | Message not sent, Turnstile/form failure, or delayed delivery | Inspect target page state, keep the same inbox, then retry after a new baseline |
| Turnstile fails under WARP | Browser is headless, `navigator.webdriver` is true, WebGL is unavailable, or the display is broken | Use the tested headed/Xvfb flags; verify no `--headless`, `webdriver=false`, visible state, and a non-null WebGL context |
| Xvfb reports missing `xkbcomp` | Rootless package extraction left a hard-coded path unresolved | Use the exact-path `execve` redirect described above or a working system Xvfb |
| Cohub/AI calls fail while WARP is active | Proxy was applied globally | Scope proxy flags to the mailbox API and Neta browser only |

## Delivery notes

- Mailbox credentials and browser auth state are `restricted`.
- A screenshot used as evidence must hide the full email address, OTP, JWT, cookies, and session IDs.
- Registration success proves only that the flow was executable for that target/provider/date. It does not prove product value, cross-provider deliverability, retention, or payment success.
- Competitor compatibility evidence must name the target host and provider. Do not generalize one competitor's acceptance of reusable.email to Neta or to other competitors.

