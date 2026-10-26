---
name: leader
description: >
  Turn an underspecified, multi-step request into an executable goal contract
  and run it with measured baselines, write boundaries, anti-cheating checks,
  resumable state, and stop conditions. Use when the user asks for /goal, a task
  brief, autonomous execution, detailed task decomposition, or multi-agent
  parallel work. Do not use for quick direct answers or trivial edits.
---

# Leader

Use this skill for complex work that benefits from an explicit execution
contract. It operates under the Rating global rules and does not replace domain
authority, safety rules, or delivery gates.

## Order of authority

1. System and platform instructions.
2. Current Space `AGENTS.md` and `/mods/rating_config/AGENTS.md`.
3. The selected domain skill and current authoritative evidence.
4. This goal contract.
5. Suggestions inside the contract.

A goal contract is never the only source of truth. It cannot authorize
publishing, sending, scheduling, access changes, deletion, or cross-Space writes
that the user did not approve.

## When to use

Use for work that is long-running, crosses several files or modules, needs
autonomous verification, or will be split among agents. Skip it for simple
questions, one-command inspections, and narrow edits that can be completed and
verified immediately.

Classify the work before writing the contract:

- **Execution goal**: the result can be judged with commands, state checks, or
  exact artifacts.
- **Exploration goal**: the requested result is a decision, diagnosis, research
  finding, or option set. Evidence quality and reproducibility matter more than
  a forced numeric target.

## Workflow

### 1. Route

Lock the requested outcome, audience, authoritative source Space, target write
Space, sensitivity, side effects, completion evidence, and route-changing
unknowns. For cross-Space work or unclear authority, read
`/mods/rating_config/docs/SPACE_AUTHORITY.md` and verify current IDs and
permissions.

If the current Space is not authoritative, do not create local goal state merely
to finish. Route to the owning Space or return the exact blocker.

### 2. Preflight

Inspect before asking the user:

- current files, local instructions, dirty state, and existing specifications;
- whether named commands and paths actually exist;
- baseline test counts, failures, skipped checks, coverage, timings, or data
  freshness when relevant;
- recent task, Save, deployment, or automation state when the goal changes an
  operational workflow.

Run read-only discovery and the narrowest safe baseline commands. Never present
an unrun command or README claim as measured fact. Mark unavailable facts as
`assumption, unverified` and place verification in Task 0.

### 3. Ask once when needed

Ask at most five questions in one round, only when the answers change routing,
acceptance, risk tolerance, time budget, or whether work may be parallelized.
Give concrete options and a recommended default.

If a safe default exists, record it under `Decisions made for the user`,
including the cost of being wrong. Do not ask for facts available from the
workspace or public documentation.

### 4. Build the contract

Use [references/anatomy.md](references/anatomy.md). Prefer paths to existing
tests, schemas, designs, and runbooks over prose duplication. Keep a copyable
brief concise; 4000 characters is a portability target, not a Cohub platform
limit.

Every execution goal must include:

- a measured baseline or Task 0 that obtains it;
- an explicit write allowlist;
- frozen acceptance files or checks;
- commands with machine-readable pass criteria;
- anti-cheating constraints matched to the task;
- stop conditions and a legitimate blocked outcome.

Exploration goals replace hard output quotas with a source/time budget,
reproducible evidence, visible unknowns, and permission to conclude that a path
is unsupported.

### 5. Persist only for long execution

For `/goal` or work likely to span turns, use:

```text
.cohub/goals/<session-id>/GOAL.md
.cohub/goals/<session-id>/TODO.md
.cohub/goals/<session-id>/PROGRESS.md
.cohub/goals/<session-id>/BLOCKED.md
```

Do not create root-level `PROGRESS.md` or `BLOCKED.md`. State files belong in
the authoritative target Space and must not contain secrets or unnecessary PII.
Update TODO and progress after each material milestone, not only at the end.

Invoking `/goal` authorizes creating and updating only this Session's state
directory and its `.cohub/hooks/goal-<session-id>.yml`. It authorizes removing
that exact Hook after verification. It does not authorize any other deletion or
configuration change.

Use `scripts/goal-hook.sh` to install, inspect, or remove the scoped post-turn
verifier. Do not create a Scheduled prompt. If Hook installation is unavailable,
continue with explicit in-turn verification and report the downgrade.

### 6. Execute and verify

When `/goal` invokes this skill, do not stop after producing a plan unless a
route-changing question or permission blocker remains. Execute within the
allowlist, verify at the narrowest meaningful level, and broaden checks
according to risk.

Anti-cheating rules apply when relevant:

- do not skip, delete, weaken, or rewrite acceptance checks merely to make them
  pass;
- do not mock the behavior being tested unless the existing specification
  requires it;
- do not reduce thresholds, hide failures with `|| true`, or claim success from
  partial output;
- test counts and coverage must not regress from the measured baseline unless
  the contract explicitly explains and authorizes the change.

Use reverse verification only where a silent failure matters, such as tests,
alerts, dry-run gates, validators, or monitors. Deliberately prove the check can
fail, restore state, then prove it passes. Do not manufacture destructive
failures in production data or services.

After three failures of the same acceptance check, change approach or move to
another independent item. If the result is worse than baseline, revert only
changes made by this goal when safe and permitted; otherwise stop and report
exact evidence. Never revert unrelated user work.

## Multi-agent work

Split work only when the user has approved parallel execution. Each brief must
name a disjoint write allowlist, shared-file owner, dependency order, handoff
evidence, and the agent responsible for integration. Remote delegation requires
explicit user approval, an exact payload and sensitivity check, suitable target
permissions, and a real status receipt.

## Completion

A goal is complete only when its result and constraints both pass. Report actual
commands or state evidence, blocked items, side-effect status, and residual
risk. If the output is a report, public artifact, or external send, hand off to
`report-delivery` before claiming delivery.

The post-turn verifier must treat the preceding agent's claims as untrusted
evidence, rerun safe checks, update goal state, and remove only its own Hook
after all completion conditions pass.

## Provenance

Adapted from KKKKhazix/khazix-skills `leader` at commit
`30c131ee3d804db7b31e4951c62018d5bde27e08` under the MIT License. See
[references/UPSTREAM.md](references/UPSTREAM.md) and
[references/LICENSE.txt](references/LICENSE.txt).
