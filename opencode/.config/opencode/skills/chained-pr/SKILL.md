---
name: gentle-ai-chained-pr
description: >
  Split large changes into chained or stacked pull requests that protect reviewer
  focus and stay within Gentle AI's 400-line cognitive review budget. Trigger:
  when a PR would exceed 400 changed lines, when planning chained PRs, stacked
  PRs, or reviewable slices.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

Use this skill when:

- A planned PR is likely to exceed **400 changed lines** (`additions + deletions`).
- An SDD tasks artifact forecasts `400-line budget risk: High` or `Chained PRs recommended: Yes`.
- A reviewer asks to split a PR for cognitive load, review fatigue, or burnout prevention.
- You need chained PRs, stacked PRs, or a feature branch with multiple reviewable slices.
- A change should be reviewed in roughly **60 minutes or less** per PR.

Do not use this skill for small fixes or single-purpose changes that fit comfortably under the review budget.

## Critical Rules

| Rule | Requirement |
|------|-------------|
| Review budget | **MUST split** when a PR exceeds **400 changed lines** (`additions + deletions`), unless it has maintainer-approved `size:exception` |
| Review time | Design each PR for an approximately **≤60-minute** human review |
| Review health | Optimize for sustainable maintainer attention, not just CI compliance |
| Start and finish | Every chained PR MUST state where it starts, where it ends, what came before, and what comes next |
| Autonomy | Every chained PR MUST be understandable and verifiable on its own |
| Scope | One deliverable work unit per PR; do not mix unrelated refactors, features, tests, or docs |
| Dependencies | State what each PR depends on and what follows next |
| Exceptions | Use `size:exception` only when a maintainer agrees the large diff is unavoidable |
| SDD handoff | If SDD forecasts a >400-line workload, honor `delivery_strategy`: ask, auto-chain, or require/record `size:exception` |
| Visual map | Every chained PR MUST include a dependency diagram that marks the current PR |
| Tracker PR | If the team chooses Feature Branch Chain, create a draft tracker PR that lists every child PR and current status |
| Strategy consistency | Once the user picks a chain strategy, follow it for the entire chain — do not mix stacked and feature branch patterns |

The goal is not bureaucracy. The goal is preventing reviewer burnout so maintainers can review with care instead of skimming exhausted. Big PRs create fatigue, hide defects, and slow merge velocity.

## Autonomy Requirements

Each chained PR must function as a complete review unit:

- **CI green**: checks pass for the PR branch in its intended base context.
- **Autonomous scope**: the PR has one clear deliverable outcome.
- **Reasonable rollback**: reverting this PR does not require reverting unrelated work.
- **Verification included**: tests, docs, or manual verification cover this unit.
- **Reviewable alone**: reviewers do not need to read future PRs to understand this one.

If a slice cannot meet these rules, split it differently. A chain is not a dumping ground for partial, unreviewable diffs.

## Choosing the Chain Strategy

When the workload exceeds 400 lines and chained PRs are needed, **ask the user** before proceeding:

```
This work exceeds the 400-line review budget. How do you want to split it?

1. Stacked PRs to main
   Each PR merges to main in order. Fast iteration, fix on the go.
   Best for: speed-first teams, startups, independent slices.

2. Feature Branch Chain (with tracker)
   All PRs merge into a shared branch. Only the tracker merges to main.
   Best for: rollback control, integration testing before main, coordinated releases.

3. size:exception
   Keep it as a single PR with maintainer approval.
   Best for: generated code, migrations, vendor diffs where splitting adds noise.
```

Cache the user's answer for the rest of the session. Do not ask again unless the user changes scope.

This is a **team decision**, not a technical one. Both strategies are valid — they reflect different priorities:

| | Stacked PRs to main | Feature Branch Chain |
|---|---|---|
| Speed | Each slice ships immediately | Waits until the chain is complete |
| Rollback | Revert individual PRs from main | Revert the whole feature branch |
| Risk | Partial features may land in main | Nothing lands until everything is ready |
| Fix flow | Fix on the go in main | Fix on the integration branch |
| Complexity | Simpler — rebase and retarget | Needs tracker PR and branch management |
| Best for | Startups, fast-moving teams | Teams needing coordination and control |

## Chain Boundaries

Every PR in a chain needs explicit boundaries:

| Boundary | What to document |
|----------|------------------|
| Start | The branch, PR, or state this PR builds on |
| End | The finished unit this PR leaves behind |
| Before | Prior PRs reviewers can assume already exist |
| After | Follow-up PRs reviewers should ignore for now |
| Out of scope | Related work intentionally excluded from this review |

## Tracker PR Requirement

For any chain with more than two PRs, create a draft tracker PR before review starts. The tracker PR is not the review surface. It is the map.

It must include:

- every child PR in merge/review order,
- current status for each PR,
- one dependency diagram,
- explicit instruction not to review the aggregate diff,
- `size:exception` if the aggregate diff exceeds 400 changed lines,
- `no-merge` while the chain is incomplete.

## Diagram Requirement

Every child PR must show where it sits in the chain. Mark the current PR with `📍`.

```text
main
 └── #101 Foundation
      └── #102 Work-unit commits
           └── 📍 #103 This PR
                └── #104 Docs
                     └── #105 Tracker
```

Pair the diagram with a status table:

| PR | Scope | Status |
|----|-------|--------|
| #101 | Foundation | ✅ Passing |
| #102 | Work-unit commits | 🟡 Open |
| #103 | This PR | 📍 Review here |
| #104 | Docs | ⚪ Pending |
| #105 | Tracker | 🟡 Draft |

## SDD Integration

When SDD planning produces tasks that may exceed 400 changed lines:

1. Treat the `Review Workload Forecast` as a hard planning signal.
2. Follow the cached `delivery_strategy` before `sdd-apply` writes code.
3. Convert suggested work units into PR slices.
4. Keep each slice autonomous: tests/docs included, CI green, clear rollback.
5. Do not let one `sdd-apply` batch silently grow into a burnout-sized PR.

## Feature Branch Chain

Use this when the user chooses option 2: all PRs integrate in a shared branch before landing in `main`.

```text
main
 └── feat/my-feature              # tracker PR targets main
      ├── feat/my-feature-01-core # PR targets feat/my-feature
      ├── feat/my-feature-02-cli  # PR targets feat/my-feature
      └── feat/my-feature-03-docs # PR targets feat/my-feature
```

### Steps

1. Create the feature/tracker branch from `main`.
2. Open the tracker PR from the feature branch to `main` — mark it draft with `no-merge`.
3. Create each child branch from the feature branch.
4. **Every child PR MUST target the feature/tracker branch** — never `main`.
5. Merge child PRs into the feature branch as they pass review.
6. Only merge the tracker PR into `main` after all children are merged and integrated.

### Common mistake: child PR targeting main

If you chose this strategy, no child PR should target `main` — otherwise it bypasses the tracker and lands in `main` before the chain is complete.

```text
# WRONG — child bypasses tracker
main ← #101 (base: main) ← #102 ← #103

# CORRECT — all children flow through the tracker branch
main ← tracker (#105)
         ├── #101 (base: tracker branch)
         ├── #102 (base: tracker branch)
         └── #103 (base: tracker branch)
```

### Tracker PR Expectations

The tracker PR is a **chain map**, not the review surface. Keep it draft/no-merge until the child PRs are reviewed and integrated.

- Reviewers should review the child PRs, where each slice stays within the 400-line budget.
- The tracker PR may exceed 400 changed lines because it aggregates the full feature branch by design.
- If the tracker PR exceeds the budget, request/obtain maintainer-applied `size:exception` and document why the aggregate diff is unavoidable.

## Stacked PRs to Main

Use this when each PR can land in `main` in order.

```text
main <- PR 1: foundation
          └── PR 2: feature slice built on PR 1
                └── PR 3: docs/tests built on PR 2
```

### Steps

1. Create PR 1 from `main`.
2. Create PR 2 from PR 1's branch and target it to PR 1's branch.
3. After PR 1 merges, rebase PR 2 on `main` and retarget it to `main`.
4. Repeat until the stack is merged.

## Chain Context Section

Insert this extra section into the existing `.github/PULL_REQUEST_TEMPLATE.md` body. Do **not** replace the repository PR template; the linked issue, PR type, summary, changes, test plan, automated checks, and contributor checklist sections are still required.

```markdown
## Chain Context

| Field | Value |
|-------|-------|
| Chain | <feature or stack name> |
| Tracker PR | <#NNN or "Not needed"> |
| Position | <N of total> |
| Base | `<target branch>` |
| Depends on | <PR/issue/link or "None"> |
| Follow-up | <next PR or "None"> |
| Review budget | <changed lines> / 400 |
| Starts at | <branch, PR, or state this builds on> |
| Ends with | <standalone result delivered by this PR> |

### Chain Overview

```text
main
 └── #NNN Previous PR
      └── 📍 #NNN This PR
           └── #NNN Next PR
                └── #NNN Tracker
```

### Chain Status

| PR | Scope | Status |
|----|-------|--------|
| #NNN | <scope> | <status> |
| #NNN | <scope> | 📍 This PR |

## Scope

- <What this PR includes>
- <What this PR intentionally excludes>

## Autonomy

- [ ] CI is expected to pass for this PR branch
- [ ] This PR has one deliverable scope
- [ ] This PR can be rolled back without unrelated changes
- [ ] Tests, docs, or manual verification cover this unit

## Review Notes

- Review this PR in isolation.
- Do not review dependent PR changes here.
- If this exceeds 400 changed lines, request/obtain maintainer-applied `size:exception` and document the rationale.

## Test Plan

- <command or manual verification>
```

## Commands

```bash
# Check PR size before asking for review
gh pr view <PR_NUMBER> --json additions,deletions,changedFiles,title,url

# Create a chained PR targeting a feature branch
gh pr create --base feat/my-feature --title "feat(scope): focused slice" --body-file pr-body.md

# Create a stacked PR targeting the previous branch
gh pr create --base feat/my-feature-01-core --title "feat(scope): next focused slice" --body-file pr-body.md
```

## Reviewer Guidance

- If a PR exceeds 400 changed lines without `size:exception`, ask for a split.
- Recommend chained PRs when the work must integrate before `main`.
- Recommend stacked PRs when each slice can merge independently.
- Prefer clear dependency notes over clever branch gymnastics.
- Push for autonomy: green CI, clear rollback, and tests or docs for the unit under review.
- Protect reviewer energy. If the chain forces reviewers to reconstruct hidden context, ask for clearer boundaries.
