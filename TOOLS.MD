# Development Tools

## scripts/run-junit-tests.sh

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

## scripts/run-ktlintFormat.sh

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

## scripts/run-lintProject.sh

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

