---
name: jira-ticket-implementer
description: Implement a Jira ticket end to end by reading the ticket through Jira Rovo MCP, aligning on scope, planning the work, implementing the changes, reviewing them, and finishing with lint and formatting. Use when Codex is asked to work from a Jira issue or ticket id, especially when the workflow should require user approval after a brief task summary and again after an implementation plan before code changes begin.
---

# Jira Ticket Implementer

Execute this workflow when the task should be driven by a Jira ticket and the user wants explicit checkpoints before planning and implementation.

## Configuration

Define these settings at the start of the task and mention the effective values briefly to the user:

- `review_pass_limit`: Maximum number of review rounds. Default to `3`.
- `ticket_id`: Jira ticket id provided by the user. If missing, ask for it before doing ticket-specific work.

If the user gives a different review-pass limit, use it. Otherwise keep the default.

## Workflow

1. Resolve the Jira ticket id.
2. Read the ticket with Jira Rovo MCP.
3. Summarize the requested work and confirm scope with the user.
4. Inspect the codebase as needed and create an implementation plan.
5. Ask the user to approve the plan.
6. Implement the approved plan.
7. Run code review passes and fix findings.
8. Run lint and formatting.
9. Report what changed, what was verified, and any remaining risks.

Do not skip the summary approval or the plan approval.

## Resolve The Ticket

If the user already supplied a ticket id, use it.

If the ticket id is missing, ask only for the ticket id and wait.

If Jira Rovo MCP is unavailable, say so plainly and stop instead of guessing ticket contents.

## Read And Summarize

Read the ticket using Jira Rovo MCP. Capture at least:

- ticket key
- title
- description
- acceptance criteria
- linked context that materially affects implementation

Then provide a brief summary that focuses on:

- the user-visible or system-visible change
- constraints, assumptions, and unknowns
- likely code areas to inspect

If the ticket is ambiguous, call that out before planning. Ask for user approval of the summary before moving on.

## Plan The Work

After the user approves the summary, inspect the codebase enough to create a grounded plan. Read only the files needed to understand the impacted area.

The plan should be short and implementation-oriented. Include:

- files or modules likely to change
- major code changes
- tests or validation to run
- migration, rollout, or compatibility concerns when relevant

Ask the user to approve the plan before making edits.

## Implement

After plan approval, make the code changes. Stay within the approved scope unless new information forces a change. If the implementation reveals a material mismatch with the approved plan, pause and resync with the user before continuing.

Add or update tests when the task warrants it.

## Review Loop

After implementation, run a review loop with a maximum of `review_pass_limit` rounds.

For each round:

1. Run a code review pass.
2. Fix valid findings.
3. Re-review if findings were fixed and the pass limit has not been reached.

Prefer using a subagent for code review only when subagents are allowed in the current environment and the user requested a workflow that includes delegated review. Otherwise perform the review locally.

Keep each review pass focused on:

- correctness bugs
- regressions
- missing edge cases
- weak or missing tests
- maintainability issues that materially affect the change

Stop early if a review pass finds no actionable issues.

If the review still finds unresolved issues when the pass limit is reached, report them clearly in the final handoff.

## Final Validation

After the review loop completes:

1. Run the relevant lint command.
2. Run the relevant formatting command.
3. Run focused tests when available and appropriate.

If lint, formatting, or tests cannot run, explain why and note the gap in the final response.

## Response Pattern

Use this interaction pattern:

1. Request the ticket id if it was not supplied.
2. Present a brief summary and ask for approval.
3. Present a concise plan and ask for approval.
4. Implement after approval.
5. Summarize implementation, review results, and validation at the end.

Keep updates concise between checkpoints so the user can track progress without losing momentum.
