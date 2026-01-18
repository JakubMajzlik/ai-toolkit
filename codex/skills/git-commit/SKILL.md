---
name: git-commit
description: Construct git commit messages in the format "<type>(<issue number>): subject" and assist with running git commit. Use when a user asks to prepare or execute a commit with this formatted message.
---

# Git Commit Message Format

## Configuration

- Set `JIRA_PROJECT` to a project key (e.g., `ULM`) if issue numbers should be used.
- If `JIRA_PROJECT` is empty or not set, do not include an issue number in the commit message.

## Collect inputs

- Ask for `type` and `subject` if any are missing.
- Enforce `type` as one of: `feat`, `fix`, `chore`, `doc`, `refactor`.
- If `JIRA_PROJECT` is set, ask for `issue number` and validate it matches `<JIRA_PROJECT>-<number>` (e.g., `ULM-123`). If it does not, ask for a corrected issue number.
- Ensure `subject` is a short, imperative phrase and does not end with a period.

## Construct message

- If `JIRA_PROJECT` is set, build: `<type>(<issue number>): subject`.
- If `JIRA_PROJECT` is not set, build: `<type>: subject`.
- Echo the full message back for confirmation before running a commit.

## Run commit (only if asked)

- If the user asks to execute the commit, run `git commit -m "<message>"` in the repo.
- If staged changes are unclear, offer to show `git status` before committing.
