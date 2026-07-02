---
name: adversarial-review
description: Use when the user requests an adversarial review, red-team review, "devil's advocate" verification, or an independent verification pass before archiving an OpenSpec change.
author: LIDR.co
version: 1.0.0
---

# adversarial-review Skill

Act as an **independent adversarial reviewer**: assume gaps, flaws, or unsafe behavior may exist until you've argued against them with evidence.

This skill is meant for the **verification window** of spec-driven development (after implementation, **before** archiving), when the human runs a **different agent or session** than the one that implemented the change.

**Do not** prescribe which agent, model, or IDE to use. That's the human's decision.

## Inputs

- Optional user context (same style as `show-spec-working`):
  - Direct ticket id in the text (e.g. `SCRUM-10`)
  - Feature or change name
  - Endpoint(s)
  - Frontend route(s)
  - **Pull request**: URL, or host owner/repo and number (e.g. `https://github.com/org/repo/pull/42` or `owner/repo#42`)
- If missing, infer it from the current session (active change, branch, or OpenSpec folder).

Resolve scope in this order: explicit ticket or change name → PR if given → current active work.

## Mindset (adversarial review)

Drawn from common red-team / adversarial practice:

- **Try to break the system**, not just confirm the happy paths.
- **Look for incorrect assumptions** about data shape, timing, ordering, authorization, idempotency, and error handling.
- **Trace composition and boundary-crossing risks**: pieces that look fine in isolation but fail together (multi-file, API plus UI, retries plus side effects).
- **Treat the diff as incomplete context**: missing tests, missing negative cases, or spec misalignment can hide problems.
- **Calibrate depth to risk**: authentication, payments, PII, privilege boundaries, and data mutation deserve stricter scrutiny.

## Workflow

### Step 1 — Load the spec side first

1. Identify the OpenSpec change directory and read the relevant artifacts (proposal, design, specs, scenarios, `tasks.md`).
2. Extract the **acceptance criteria and explicit non-goals**. List what must be true for it to count as "done".
3. Note anything **underspecified** (ambiguous acceptance, missing error cases, missing security constraints).

### Step 2 — Load the implementation side

1. If a **PR** was provided, treat it as the primary implementation surface:
   - Read the PR description and review the full scope of the diff (not just the default file order).
   - Map **files and changes** to spec sections and tasks.
2. If there's no PR: use `git diff` against the merge base or the branch associated with the change, per the project's convention.

### Step 3 — Adversarial pass (refute, don't rubber-stamp)

For each acceptance criterion or scenario:

1. State how the implementation **could still fail** even if the author believed it passed (bad input, partial failure, double submission, stale cache, wrong role, race condition, empty state, oversized payload).
2. Review **negative and abuse cases** where relevant (validation bypass strings, IDOR-style access patterns, replay, conflict handling).
3. Review **tests and verification artifacts**: do they actually **prove** the criterion, or only the happy path?
4. Record **spec-vs-code discrepancies** (the spec says X, the code does Y) as top-level findings.

### Step 4 — Severity and recommendations

Classify each finding:

- **Blocker**: incorrect behavior, security/privacy issue, or spec violation that should stop archiving.
- **Major**: likely bug or significant gap; requires a fix or spec update before archiving.
- **Minor**: clarity, maintainability, or low-risk gap; can remain as a follow-up.
- **Question / assumption**: needs confirmation from the human or the author.

For each finding, state whether the fix belongs in **code**, **tests**, **OpenSpec artifacts** (scenarios, specs, tasks), or **documentation**.

### Step 5 — Verdict

End with a clear verdict:

- **PASS (adversarial)**: no blockers or majors; minors optionally listed.
- **PASS WITH GAPS**: only minors, but recorded.
- **FAIL**: at least one unresolved blocker or major.

## Output format

Use this structure in the chat:

```markdown
## Adversarial review

**Scope**: <ticket / change / PR>
**Sources**: <list spec paths + PR or diff reference>

### Spec and task alignment
- ...

### Findings

| Severity | Area | Finding | Evidence | Suggested fix (code / spec / tests) |
|----------|------|---------|----------|--------------------------------------|
| Blocker / Major / Minor | | | | |

### Verdict
PASS | PASS WITH GAPS | FAIL

### Recommended next steps (before archive)
- ...
```

## Guardrails

- **Don't** praise the implementation to "balance" the criticism, unless a strength **directly mitigates a documented risk**.
- **Don't** skip reading the OpenSpec artifacts when they exist in the repo.
- If you can't access the PR or the diff, say so and list exactly what's needed to continue.

## Wrap-up

Always end with the verdict and whether archiving is **advisable** in the current state.
