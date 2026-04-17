---
name: git-commit
description: Construct git commit messages in the format "<type>: <issue-number> <description>" and assist with running git commit. Use when a user asks to prepare or execute a commit with this formatted message.
---

# Git Commit Message Format

## Collect inputs

- Ask for `type` and `description` if any are missing.
- Enforce `type` as one of: `feat`, `fix`, `chore`, `doc`, `refactor`, `test`, `ci`, `revert`.
- `issue-number` is optional. Include it only if the user explicitly asks for it or already provided it. Do not ask the user for an issue number.
- Ensure `description` is short and one line.

## Construct message

- If `issue-number` is provided, build: `<type>: <issue-number> <description>`.
- If `issue-number` is not provided, build: `<type>: <description>`.
- Echo the full message back for confirmation before running a commit.

## Run commit (only if asked)

- If the user asks to execute the commit, run `git commit -m "<message>"` in the repo.
- If staged changes are unclear, offer to show `git status` before committing.
