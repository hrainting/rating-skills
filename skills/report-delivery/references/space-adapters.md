# Space adapters

Defaults when `report-delivery` runs in Rating working Spaces. Always prefer
local domain standards when they are stricter. Adapters change genre, paths, and
evidence; they never weaken redlines.

## context

- Typical outputs: research pages, query notes, onboarding pages, public briefs
- Public HTML: design-skill `article-magazine` or `data-report`, depending on
  density
- Prefer public path `reports/<topic>/<date>/index.html`
- Keep wiki/index/log updates separate from the public package unless requested
- Source footing, authorization, and visible uncertainty are mandatory

## BI-bot

- HTML: design-skill `data-report` + `dashboard` or `enterprise`
- Domain skill owns analysis; `report-delivery` owns the ship gate
- Require object, metric, time window, timezone, denominator, and caveat
  visibility
- Preserve a reproducible SQL/task path
- Feishu is common; use the local sender only after a true dry-run

## studio-bi-bot

- HTML: design-skill `data-report` + `dashboard`
- Follow `docs/report-standard.md` when present
- Prefer public path `reports/studio-bi/<slug>/<date>/index.html` plus optional
  `latest/`
- Require Studio population, signal class, entry-day logic, and local source
  filters
- Label proxy metrics; do not detour into App BI

## Recruiting system

### resume

- Audience is the candidate, recruiter, or hiring manager as specified
- Public links are opt-in; private resume originals, facts, manifests, contact
  data, and user directories never enter public packages
- A generated PDF is not done until export and visual QA pass, and the
  production record is imported/accepted when required
- Redline emphasis: truthfulness, intended audience, no fabricated metrics, and
  no unintended PII leakage

### qiuzhao

- This is the development authority, not the user-facing production runtime
- Product/UI release evidence includes build/test results and the resulting Work
  metadata or runtime verification
- Production publishing targets `resume`; record target Work/Space IDs in the
  receipt
- Do not present local development artifacts as production completion

### post-information

- This Space owns collection and validation, not resume behavior
- Delivery evidence requires source/platform, collection time, validation
  result, coverage/unknowns, API push/import receipt, and catalog reindex
  verification
- Never publish cookies, tokens, raw candidate data, or a giant unreviewed dump

## paper-reader

- Audience is a researcher or operator seeking decision relevance
- Require paper identity, main claim, confidence, and limitation
- Paper claims, agent inference, and speculation must be distinct
- Real paper notes and uploaded PDFs are private unless sharing is explicitly
  authorized; original PDFs never enter public packages by default

## MKT-preparation

- Leave-behind/landing: design-skill `frontend-design` plus a selected product
  DESIGN system
- The artifact must stand alone without Chat history
- Preserve the upstream narrative, source dates, experiment hypothesis, success
  metric, and one primary CTA
- Public link is common; Feishu remains optional and comes after redline

## Game incubator

- The incubator ships material recommendations, incubation plans, or a newly
  registered game Space; it does not ship a game playable itself
- Recommendation evidence: source authority, direct source/public links, why it
  matches, and a remix action
- Space creation receipt: name, slug, Space ID, selected pattern, registry
  update, and first prompt
- Creating a Space requires an explicit user request with enough identifying
  input

## Game project Spaces

- Browser deliverable is a real playable, not a marketing page or screenshot
- Completion evidence: running build, core loop check, desktop/mobile visual QA,
  referenced assets loaded, and exact App/public URL when requested
- Use local game acceptance criteria and update project status files
- For 3D or canvas, verify nonblank pixels and interaction; for multiplayer,
  verify room/join behavior or mark it blocked
- Register meaningful project lifecycle changes back in the incubator registry

## SAG Knowledge

- The product is an authorized sync/retrieval operation, not a public report by
  default
- Require allowlist source, authorization basis, exported item count,
  rejected/skipped count, destination environment, retrieval/citation acceptance
  result, and rollback or retry path
- Internal or restricted is the default sensitivity; never expose SAG
  credentials or unrestricted raw Context Hub data

## comment

- Daily/weekly briefs need collection window, platform/source, sample or
  denominator, ranking rule, deduplication status, and visible limitations
- Public HTML uses design-skill `data-report` or `article-magazine` according to
  density
- Scheduled delivery follows the same dry-run, redline, dated URL, card status,
  and receipt gates

## home

- No authority is defined yet. Use as an inbox or routing entry only
- Do not create a second source of truth here
- Route durable outputs into the owning Space before claiming reusable
  completion

## Legacy, test, and pending-deletion Spaces

- Do not revive, migrate, publish, or mount global mods solely for portfolio
  consistency
- State the lifecycle cue and ask for confirmation before destructive cleanup or
  repurposing
- If the user explicitly requests maintenance, receipt must show the exact
  target and resulting state

## config

- Maintain skills, templates, references, and audits only
- Do not run domain analyses here
- After a meaningful global policy update, verify files and follow the global
  commit/Save gate
