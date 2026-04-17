# AI Toolkit

Library of prompts, tools, skills, and templates to help an AI agent (or human) work consistently across projects.

**What's inside**
1. `skills/`: Reusable skills with structured instructions (e.g., commit message rules, Kotlin test creation).
2. `agents/`: Agent definitions for various AI tools (e.g., Cursor, Codex).
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

## Development Tools

### scripts/run-junit-tests.sh

Runs Gradle JUnit tests and prints minimal output.

**Syntax:**
```bash
./scripts/run-junit-tests.sh [gradle test arguments...]
```

**Arguments:** All arguments are passed directly to `gradlew test` (or `gradle test` if wrapper is missing)

**Common examples:**
```bash
./scripts/run-junit-tests.sh
./scripts/run-junit-tests.sh --tests "com.example.MyTest"
./scripts/run-junit-tests.sh -p submodule --tests "*IntegrationTest"
```

**Output:**
- Success: `OK <total_tests>`
- Failure/Error:
  - Summary: `FAIL failed=<failed_count> passed=<passed_count>`
  - Assertion failures: `ASSERT <class>#<test>`, then `expected:` and `actual:` lines
  - Errors: `ERROR <class>#<test>: <message>`, then up to 4 stacktrace frames

**Exit codes:** 0 = success, 1 = test failures/errors, 2 = tooling/runtime issue

---

### scripts/run-ktlintFormat.sh

Formats Kotlin code using ktlint.

**Syntax:**
```bash
./scripts/run-ktlintFormat.sh
```

**Output:**
- Success: prints "OK"
- Failure: prints error messages

**Exit codes:** 0 = success, 1 = formatting errors, 2 = gradle not found

---

### scripts/run-lintProject.sh

Runs ktlint and detekt code quality checks.

**Syntax:**
```bash
./scripts/run-lintProject.sh [gradle arguments...]
```

**Arguments:** All arguments are passed directly to `gradlew lintProject`

**Output:**
- Success: prints "OK"
- Failure: prints lint errors with file paths and line numbers
- Missing task: prints "Task is missing, skipping check"

**Exit codes:** 0 = success or task missing, non-zero = lint errors found
