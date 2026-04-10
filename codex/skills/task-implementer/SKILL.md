---
name: task-implementer
description: Implement a user-provided coding task through explicit discovery, approval, execution, validation, and review checkpoints. Use when Codex should first gather minimal context with an explorer subagent, confirm a brief task summary with the user, build and approve an implementation plan, execute the work with a worker subagent, run lint and formatting, and finish with bounded code review loops before reporting the result.
---

# Task Implementer

Execute this workflow when the user wants implementation work with explicit checkpoints before planning and coding.

## Configuration

Define these settings at the start of the task and mention the effective values briefly to the user:

- `review_pass_limit`: Maximum number of review-and-fix rounds. Default to `3`.
- `task_request`: The current user task. If the task is too vague to summarize responsibly, ask one targeted question before starting exploration.

If the user provides a different `review_pass_limit`, use it. Otherwise keep the default.

## Workflow

1. Capture the task request and any hard constraints.
2. Spawn an `explorer` subagent to collect only the minimum context needed to understand the task.
3. Create a brief summary of the requested work, assumptions, and likely impact.
4. Ask the user to approve that summary before doing deeper investigation.
5. Spawn an `explorer` subagent to gather all context needed for implementation after summary approval.
6. Build a concise implementation plan grounded in the codebase.
7. Ask the user to approve the plan before making edits.
8. Spawn a `worker` subagent to implement the approved plan.
9. Run relevant lint, formatting, and focused validation commands.
10. Run a review loop with the `reviewer` subagent and fix actionable findings.
11. Finish with a brief summary of what changed, what was verified, and any remaining risks.

Do not skip the summary approval or the plan approval.

## Minimal Exploration

Start with the smallest useful read of the codebase.

Spawn an `explorer` subagent and ask it for:

- the most likely files or modules involved
- any immediate ambiguities or missing requirements
- the minimum facts needed to explain the task back to the user correctly

Do not ask the first explorer for a full implementation plan. Its job is to reduce ambiguity fast.

After the explorer returns, write a short summary that covers:

- the change the user appears to want
- the main affected area
- assumptions, risks, or missing details that could change implementation

Ask the user to approve that summary before continuing. If the user corrects the summary, treat that correction as the new source of truth.

## Deep Exploration And Planning

After summary approval, spawn an `explorer` subagent for a deeper pass.

Ask it to gather:

- all relevant files and modules
- existing patterns to follow
- tests or validation paths that should change
- edge cases, dependencies, migration concerns, or compatibility risks

Then build a short implementation plan that includes:

- files or modules expected to change
- major code or behavior changes
- tests and validation commands to run
- noteworthy risks or follow-up checks

Ask the user to approve the plan before any edits are made.

## Implementation

After plan approval, spawn a `worker` subagent to implement the task.

The worker should:

- stay within the approved scope
- follow existing project conventions
- add or update tests when appropriate
- report any material mismatch between the approved plan and the code it finds

If implementation reveals a meaningful scope change, pause and resync with the user before continuing.

## Validation

After implementation, run the relevant formatting and lint commands for the impacted area.

Also run focused tests or checks when they are available and appropriate to the task.

If multiple validation commands are relevant, prefer this order:

1. formatting
2. lint
3. focused tests

If a command cannot run, explain why and carry that gap into the final handoff.

## Review Loop

After validation, run a review loop with the `reviewer` subagent for up to `review_pass_limit` rounds.

For each round:

1. Spawn the `reviewer` subagent to inspect the diff and changed files for:
   - correctness bugs
   - regressions
   - edge cases
   - weak or missing tests
   - consistency with surrounding code
2. Fix actionable findings with the `worker` subagent.
3. Re-run the relevant validation commands if fixes were made.
4. Re-run review if actionable findings were fixed and the pass limit has not been reached.

Stop early if a review pass finds no actionable issues.

If the pass limit is reached and relevant concerns remain, report them clearly in the final response.

## Subagent Guidance

Use subagents intentionally:

- `explorer` for minimal context gathering
- `explorer` for deep codebase investigation
- `reviewer` for dedicated code review passes
- `worker` for implementation and review fixes

Keep prompts narrow and artifact-driven. Ask each subagent only for the information or work needed in that phase.

Do not duplicate the same investigation locally unless a subagent result is clearly incomplete or inconsistent.

## Response Pattern

Use this interaction pattern:

1. Present a brief summary and ask for approval.
2. Present a concise plan and ask for approval.
3. Implement after approval.
4. Report validation and review-loop results.
5. End with a brief summary of what was done.

Keep intermediary updates short between checkpoints so the user can track progress without losing momentum.
