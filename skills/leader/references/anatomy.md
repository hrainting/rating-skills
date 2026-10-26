# Goal Contract Anatomy

Use six compact sections. Change detail according to risk; do not force a large contract onto a small task.

## 1. Purpose and precedence

State:

- why the work matters and what should be true afterward;
- whether this is an execution or exploration goal;
- which requirement wins when speed, completeness, correctness, privacy, and availability conflict;
- the governing `AGENTS.md`, domain skill, and existing specification paths.

The contract is subordinate to platform instructions, Space authority, privacy, and side-effect gates.

## 2. Decisions made for the user

Record each consequential default that was not explicitly provided:

```text
question -> chosen default (assumption) | cost if wrong
```

Ask the user instead when the choice changes authority, publication, external sends, destructive operations, access, scheduling, or a major product direction.

## 3. Boundaries

Name the authoritative source Space and target write Space. List allowed paths and allowed operational targets. Everything else is read-only.

Freeze the judge: existing tests, schemas, fixtures, CI configuration, metric definitions, redline checks, and production state used for acceptance. If one must change, make that a separately justified task rather than silently changing the test to fit the implementation.

Name tempting adjacent work that is out of scope. Put discovered issues in `BLOCKED.md`; do not fix them incidentally.

## 4. Baseline and Task 0

Include measured values with the command, source, and date. Examples:

- test/pass/fail/skip counts;
- coverage or latency;
- current file, schema, or deployment state;
- data window, denominator, freshness, and signal class;
- recent automation run and delivery status.

Task 0 reruns these checks. Missing commands, placeholder checks, stale paths, or materially different numbers are blockers for affected tasks. After Task 0, write no more than ten lines to `PROGRESS.md`: understood outcome, planned order, and largest risk.

## 5. Tasks and checks

For each task include:

- result to achieve;
- where to start and why it is ordered there;
- relevant constraints and their consequence;
- exact acceptance command or state query;
- machine-readable pass condition;
- reverse verification only when silent failure is a material risk.

For exploration goals, replace forced metrics with a time/source budget. Each conclusion needs a dated source or reproducible procedure. A well-evidenced dead end is a valid result.

## 6. Completion and stop conditions

Require both:

- the requested outcome is demonstrated;
- the write, safety, privacy, and non-regression constraints pass.

Include:

- actual verification evidence, not only a success statement;
- `BLOCKED.md`, even if it says `none`;
- side-effect status and residual risk;
- a finite time, attempt, or source budget;
- a blocked completion path that states what is missing and the smallest next decision.

Do not let the executor grade itself from prose alone. The manager or post-turn verifier reruns the narrow acceptance checks and records the result.
