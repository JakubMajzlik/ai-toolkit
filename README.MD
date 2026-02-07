# AI Toolkit

Library of prompts, tools, skills, and templates to help an AI agent (or human) work consistently across projects.

**What’s inside**
1. `codex/skills/`: Reusable skills with structured instructions (e.g., commit message rules, Kotlin test creation).
2. `templates/`: Prompt/context templates (e.g., a `CLAUDE.MD` development context starter).
3. `scripts/`: Local tooling helpers for tests, linting, and formatting.
4. `git-hooks/`: Git hook scripts for local automation (quality checks and other policies).
5. `TOOLS.MD`: Detailed usage docs for the scripts.

## Pre-commit hooks

### KtLint
- Hook script: `git-hooks/ktlint-pre-commit-check.sh`
- Purpose: runs ktlint format and lint checks before commit; blocks commit on failures.
- Fallback behavior: if configured scripts are missing, tries Gradle `ktlintCheck` (if available).

### Prettier and Lint
- Hook script: `git-hooks/prettier-lint-pre-commit.sh`
- Purpose: runs prettier formatting and lint checks before commit; blocks commit on failures.
- Configuration:
  - `PRETTIER_SCRIPT` (default: `scripts/run-prettier-format.sh` if executable)
  - `LINT_SCRIPT` (default: `scripts/run-prettier-lint.sh` if executable)
- Fallback behavior:
  - formatting fallback: staged supported files via `npx prettier --write`, then `bunx prettier --write`
  - lint fallback: `npm run lint`, then `bun run lint`
