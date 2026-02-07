# AI Toolkit

Library of prompts, tools, skills, and templates to help an AI agent (or human) work consistently across projects.

**What’s inside**
1. `codex/skills/`: Reusable skills with structured instructions (e.g., commit message rules, Kotlin test creation).
2. `templates/`: Prompt/context templates (e.g., a `CLAUDE.MD` development context starter).
3. `scripts/`: Local tooling helpers for tests, linting, and formatting.
4. `git-hooks/`: Git hook scripts for local automation (quality checks and other policies).
5. `TOOLS.MD`: Detailed usage docs for the scripts.

**Pre-commit hook**
- Hook script: `git-hooks/ktlint-pre-commit-check.sh`
- Purpose: runs ktlint format and lint checks before commit; blocks commit on failures.
- Fallback behavior: if configured scripts are missing, tries Gradle `ktlintCheck` (if available).
