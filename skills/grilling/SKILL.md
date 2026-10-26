---
name: grilling
description: >
  Stress-test a plan, decision, or idea through a dependency-aware interview.
  Use when the user asks to be grilled, wants assumptions challenged before
  action, or unresolved human decisions block substantive work. Do not invoke
  for trivial requests or merely to delay work that can be safely executed.
---

# Grilling

Leading word: **grill**.

This skill elicits and records human decisions. It does not execute the
resulting plan.

Follow the current and global `AGENTS.md` rules. For cross-Space work or unclear
authority, read `/mods/rating_config/docs/SPACE_AUTHORITY.md` before the
interview. Grilling never overrides Space authority, privacy boundaries,
side-effect gates, domain rules, or delivery requirements. When `leader` is
active, this interview may feed its goal contract; it does not replace that
contract.

## 1. Frame The Decision Tree

Name the requested outcome and the part that needs stress-testing. Map it as a
**decision tree**: each human decision branches into the decisions that depend
on it.

Keep the tree inside the agreed scope. Do not reopen a settled branch unless a
later answer or new evidence invalidates it. The user may stop the interview or
narrow its scope at any time.

## 2. Resolve Facts Before Asking

Finding facts is the agent's job. Inspect the authoritative workspace, tools,
primary documentation, and current state before asking the user.

When a fact needs separate investigation, use a background sub-agent if one is
available. Otherwise perform the lookup directly. A running or unavailable
investigation is an unsettled prerequisite: hold only the downstream questions,
and continue with independent decisions.

Do not send restricted content, PII, credentials, or unnecessary internal
identifiers to an external search provider or another Space. Mark facts that
cannot be verified as unknown. Human choices remain decisions: present them to
the user and wait rather than choosing silently.

## 3. Choose The Interview Mode

- **Round mode (default):** ask the currently available frontier as one numbered
  round, capped at five questions per response.
- **Single mode:** ask one frontier question per response. Use it when the user
  requests one-at-a-time questioning or switches away from rounds.

The user can switch modes without losing the current tree. Mode changes affect
pacing, not which branches must be resolved.

## 4. Ask The Frontier

The **frontier** contains decisions whose prerequisites are settled. Questions
in the same round must be independent: if one answer could change how another
question is asked, put the dependent question in a later round.

Prioritize decisions that change routing, acceptance, risk tolerance, write
boundaries, side effects, or implementation direction. For each question,
provide a concrete recommended answer with its assumptions and main tradeoff. A
recommendation informs the choice; it never counts as the user's answer.

Use this fixed shape:

```markdown
### Round <N>

**Q1 - <question title>** <question body or materially different options>

**Recommendation:** <recommended answer, assumptions, and main tradeoff>
```

Number questions within the round so the user can answer by number. Do not ask
for information already available from the environment.

## 5. Recompute After Every Answer

Record the user's decision, rationale, constraints, and unresolved uncertainty.
Recompute the frontier from the answers rather than following a prewritten
questionnaire.

If an answer or newly discovered fact invalidates an earlier question, say so,
mark that branch reopened, and ask the corrected question. Distinguish
`settled`, `open`, `blocked`, `reopened`, and `out_of_scope`; do not silently
discard a branch.

## 6. Persist Only When Needed

A short interview may remain in the conversation. Persist decision state when
the session is likely to cross turns or compaction, when another operator must
reuse it, or when the user requests a durable record.

Write only in the authoritative target Space after routing confirms the
boundary. The task contract must include the file write; otherwise ask before
creating state.

- If a `leader` goal is active, use its existing `.cohub/goals/<session-id>/`
  state instead of creating a parallel store.
- Otherwise use `.cohub/grilling/<session-id>/DECISIONS.md`.

Record the outcome, interview mode, branches and dependencies, branch status,
user decisions and rationale, evidence pointers, rejected alternatives, and
visible unknowns. Do not persist secrets or unnecessary PII. Never create task
state in the `config` source Space unless the task itself is config maintenance.

## Completion Gate

When the frontier is empty, or when the user asks to stop:

1. Summarize settled decisions, rejected alternatives, constraints, and open or
   blocked branches.
2. State honestly whether the full scoped frontier is empty or the interview
   stopped early.
3. Ask the user to confirm that shared understanding has been reached.

Do not act on the result before that confirmation. Confirmation only resumes
work already authorized by the original request; it does not authorize
publishing, sending, scheduling, access changes, deletion, or cross-Space
writes.

## Failure Conditions

The run is off track if it asks the user for discoverable facts, batches
dependent questions, treats recommendations as decisions, expands beyond the
agreed outcome, loses branches without marking them, invokes grilling for a
trivial executable request, or starts implementation before confirmation.
