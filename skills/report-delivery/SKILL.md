---
name: report-delivery
description: >
  Report redline delivery. Use when a report, brief, HTML page, research note,
  resume packet, paper readout, or marketing leave-behind is ready to ship and
  needs design-system UI (for HTML), pre-ship self-check, repair, a public URL, and optionally a Feishu card;
  or when another skill needs a publishable delivery receipt.
---

# Report Redline Delivery

Leading word: **redline**.

A draft is not a delivery. This skill turns a finished-looking artifact into a shippable package by forcing one pre-ship self-check, one repair loop, a real public URL, and a receipt.

Use after content exists. Do not replace domain analysis skills.

## When to use

- BI / Studio HTML reports
- Context Hub research pages
- resume packets
- paper-reader briefs
- MKT one-pagers / leave-behinds
- any request that ends with “给链接 / 发群 / 飞书卡片 / 可公开访问”

## SOP

### 1. Lock the delivery contract

Write:

- audience
- primary claim (one sentence)
- artifact type: `html_report` | `markdown_brief` | `packet`
- public link required: yes/no
- Feishu card required: yes/no
- dated archive required: yes/no (default yes for recurring/public reports)
- sensitivity class: `public` | `internal` | `restricted`

Completion: all fields explicit. If sensitivity is `restricted`, public publish is blocked unless the user overrides in writing.

### 2. Assemble the package in a work folder

Build or copy the content package into a task/work folder. Public storage receives only the final upload in step 5.

Required package pieces:

- content/data payload ready for a UI shell (numbers, claims, tables, caveats)
- source/task path that can regenerate or explain the artifact
- method/limitations notes for evidence-bearing reports

Do **not** treat a bare markdown dump or ad-hoc unstyled HTML as the final browser report when an HTML page will be shipped.

Completion: `content_dir` exists with the facts locked.

### 2b. Design-system UI shell (required for HTML reports)

When the shippable artifact is a **browser HTML report / leave-behind / research page / dashboard-like brief**, build the visual page through the **design-skill** Open Design stack. Rating is generally unsatisfied with raw auto-generated report chrome.

#### Mount

Prefer local mod:

```text
/mods/design-skill/
```

If missing in this Space, add the `design-skill` mod or execute via that Space and copy the artifact back.

#### Required reads (in order)

1. `/mods/design-skill/.agents/skills/open-design-workflow/SKILL.md`
2. `/mods/design-skill/references/open-design/ROUTER.md` (if route unclear)
3. One skill SKILL.md — default routes:
   - data / BI / Studio weekly-style report → `references/open-design/skills/data-report/SKILL.md`
   - long-form research brief → `article-magazine`
   - pitch / review deck → `deck-swiss-international` or `deck-guizang-editorial`
   - marketing leave-behind / landing → `frontend-design`
4. One visual contract DESIGN.md — defaults:
   - analytics/ops → `design-systems/dashboard` or `enterprise`
   - clean product → `default` / `linear-app` / `clean`
   - editorial → `paper` / `warm-editorial`
5. Before ship: `/mods/design-skill/.agents/skills/ui-polish-final-pass/SKILL.md` when available

#### Rules

- Keep template visual signature; put **real** content/data in (no lorem).
- Single-file or small folder HTML with **relative** assets; Chart.js/ECharts via CDN is OK.
- Chart parents need explicit height (see data-report skill) to avoid resize loops.
- Run Open Design alignment / P0 checks; revise before redline if layout is sloppy.
- Domain analysis skills still own numbers; design-skill owns the UI shell.
- If design-skill is unavailable, mark receipt `design_system: blocked` and either mount it or get user override — do not silently ship ugly default HTML as “done”.

Completion: `candidate_dir` contains designed `index.html` + short note of skill + DESIGN system used.

### 3. Pre-ship self-check (author mode off)

**执行口令（必须按字面执行）：**

> 假装你是没写过这篇、还偏挑刺的读者/对接人，用会拒稿的标准把报告读一遍。

这不是普通的“检查有没有写完”，而是一次独立的交付判断：

1. 先不要修改，完整读一遍；不要用作者意图替报告辩解。
2. 假设读者看不到聊天记录，只能看到这份交付物。
3. 先给总判定：`SEND`（可交付）/ `REVISE`（需返修）/ `BLOCKED`（缺数据、权限或确认）。
4. 每个拒稿理由必须写清：**读者会卡在哪里 → 报告中的证据/位置 → 怎么修**。
5. 只有修完并复读通过，才能把 `REVISE` 改成 `SEND`。

至少回答以下拒稿问题：

- 标题和首屏承诺的内容，正文真的交付了吗？
- 主结论能否被证据直接支撑，还是只是作者的解释？
- 一个不了解上下文的人，会在哪个数字、图表、术语或行动建议处追问？
- 哪个未知、限制或替代解释被写得太轻，可能误导决策？
- 如果现在把它发给老板、协作方或外部读者，最可能因为什么被退回？

Use `references/quality-bar.md` and fill `templates/self-review.md`.

Score each redline `PASS` / `FAIL` / `N/A`:

1. Promise match — title/hero matches actual content
2. Primary claim — one clear takeaway above the fold
3. Evidence — key claims have numbers, examples, or sources
4. Uncertainty — unknowns/caveats visible, not buried
5. Navigation — reader can move without getting lost
6. Visual integrity — no obvious blank charts, clipped text, broken layout
7. Privacy — no secrets, tokens, raw credentials; UUIDs minimized
8. Actionability — next step or decision implication exists when the genre needs it

Completion: self-review file contains the first-pass verdict, concrete rejection reasons, every redline score, and repair tickets. `SEND` requires open FAIL = 0.

### 4. Repair loop

For every `FAIL`:

- fix the artifact, or
- downgrade the claim, or
- mark blocked with a concrete missing input

Then re-read only the failed redlines.

Stop when:

- all non-N/A redlines are PASS, or
- blocked on missing user input / data / permission

Max loops: 2 full repair cycles unless the user asks to continue.

Completion: zero open FAIL tickets or an explicit blocker list.

### 5. Publish public URL

If public link required, publish with `cohub public` (skill `public-files`). Do not copy into the `/public` filesystem or build URLs from `PUBLIC_URL_PREFIX`: that is the legacy `public.cohub.run` path, separate from current public storage.

1. Re-check sensitivity and package contents first. Uploads are permanent and cannot be deleted.
2. Upload the final folder to a dedicated destination, never the public root:
   - dated archive: `cohub public upload <content_dir> reports/<slug>/<YYYY-MM-DD>`
   - optional latest: `cohub public upload <content_dir> reports/<slug>/latest --overwrite`
3. Take the URL from the upload output, or run `cohub public url reports/<slug>/<YYYY-MM-DD>/index.html`.
4. Open the exact file URL and confirm the page and its assets load. A prefix is not a browsable directory.

Never pass `--overwrite` on a dated path. When the user wants a live App link (versions, visibility, view stats), publish with skill `cohub-apps` instead.

Completion: clickable file URL recorded. No secrets published.

### 6. Optional Feishu card

Only if requested or clearly part of the job.

Before any card build/send, read the current Lark skills when mounted:

- `/workspace/.agents/skills/lark-shared/SKILL.md`
- `/workspace/.agents/skills/lark-im/SKILL.md`
- `/workspace/.agents/skills/lark-im/references/card/lark-im-card-create.md`

Default to Card 2.0 and pass P0–P7. Legacy Card 1.0 builders may remain for compatibility, but must be recorded as `legacy_card_v1` and are migration debt.

**Safety order:** build → explicit `--dry-run` → inspect JSON/no secrets → send. Do not use `env -u` as a substitute for dry-run because dotenv may reload `.env`. Never hand-write/copy a static card payload for a new card.

Card rules:

- lead with the primary claim, not a metric dump
- include window/audience if relevant
- buttons for destinations; avoid duplicating raw URLs in body and buttons
- at least one button to the dated public URL
- dry-run card JSON when webhook is missing; do not fake “sent”

Template: `templates/feishu-card.md`.  
Local send scripts may exist per Space; use them only when present and configured.

Completion: `sent` with target/message id when available, or `dry_run` with JSON path, or `skipped/blocked/failed` with reason. Never claim sent from HTTP 200 alone when the response body signals an application error.

### 7. Delivery receipt

Return `templates/delivery-receipt.md`:

- public URL(s)
- Feishu status
- redline scoreboard
- repairs made
- residual risks / unknowns
- design system / template used (or blocked/override)
- regenerate path

Completion: receipt is the final chat answer. “HTML exists” alone is not success.

## Space adapters

Read `references/space-adapters.md` for Context / BI-bot / studio-bi-bot / resume / paper-reader / MKT defaults.  
Adapters change paths and genre expectations. They do not weaken redlines.

## Guardrails

- Content generation stays with the domain skill; this skill ships and stress-tests.
- Prefer repairing claims over decorating weak evidence.
- Dated URLs beat mutable latest URLs for anything shared externally.
- If `cohub public` is unavailable or the upload fails, stop and report the blocker.
- Never print webhook secrets or database credentials.

## Pointers

- quality bar: `references/quality-bar.md`
- adapters: `references/space-adapters.md`
- self-review template: `templates/self-review.md`
- receipt template: `templates/delivery-receipt.md`
- public file publish: `/mods/cohub_base/.agents/skills/public-files/SKILL.md`
- App publish: `/mods/cohub_base/.agents/skills/cohub-apps/SKILL.md`




