# Redline quality bar

Picky-reader checklist (交付红线). Genre can add bars; it cannot remove these.

## Universal redlines

| ID | Redline | Fail if |
|---|---|---|
| R1 | Promise match | Title/hero overclaims or mismatches body |
| R2 | Primary claim | No one-sentence takeaway without scrolling scavenger hunt |
| R3 | Evidence | Key claims lack number, example, quote, or source footing |
| R4 | Uncertainty | Caveats absent, hidden, or contradicted by confident tone |
| R5 | Navigation | Sections unlabelled; reader cannot skim structure |
| R6 | Visual integrity | Blank charts, overlapping text, broken images, unreadable contrast |
| R7 | Privacy | Secrets, tokens, credentials, or unnecessary raw UUIDs/PII |
| R8 | Actionability | Pure description where the job implied a decision/next step |

## Evidence-bearing reports (BI / Studio / research)

Also require:

| ID | Bar |
|---|---|
| E1 | Explicit time window + timezone/cutoff |
| E2 | Explicit population/denominator |
| E3 | Signal class on soft metrics: observed / proxy / unknown |
| E4 | At least one alternative explanation for causal claims |
| E5 | Method/limitations section reachable from the report |

## HTML reports

| ID | Bar |
|---|---|
| H1 | Main entry is a file URL ending in `.html` |
| H2 | Assets use relative paths |
| H3 | Filters, if any, affect only their local chart/table |
| H4 | No obvious JS console-breaking string escaping issues in names |

## Briefs / resume / paper / MKT packets

| ID | Bar |
|---|---|
| B1 | Audience-specific framing in first screen/section |
| B2 | Claims are portable without private chat context |
| B3 | “So what” is explicit for the named audience |

## Scoring

- `PASS`: would not send back for this reason
- `FAIL`: would reject or demand revision
- `N/A`: genre genuinely does not need it

Ship only when every non-N/A redline is PASS.

## Designed HTML reports (Rating default)

When shipping browser HTML for Rating, also require:

| ID | Bar |
|---|---|
| D1 | Built via design-skill Open Design route (not ad-hoc unstyled HTML) |
| D2 | Named skill + DESIGN system recorded (e.g. data-report + dashboard) |
| D3 | Real content only; no lorem/placeholder charts |
| D4 | Alignment/P0 layout checks passed (shared container, readable hierarchy) |
| D5 | Charts have bounded height containers when using Chart.js/ECharts |

Fail D1–D2 unless user explicitly overrides design-system requirement in writing.

