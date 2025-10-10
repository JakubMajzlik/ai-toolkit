# Development Tools

## scripts/run-tests.sh

Runs Gradle tests and reports failures.

**Syntax:**
```bash
./scripts/run-tests.sh [gradle test arguments...]
```

**Arguments:** All arguments are passed directly to `gradlew test`

**Common examples:**
```bash
./scripts/run-tests.sh
./scripts/run-tests.sh --tests "com.example.MyTest"
./scripts/run-tests.sh --tests "com.example.MyTest.myTestMethod"
./scripts/run-tests.sh --tests "*IntegrationTest"
./scripts/run-tests.sh --tests "com.example.package.*"
```

**Output:**
- Success: prints "OK"
- Failure: prints Kotlin compilation errors and/or test failures with stack traces

**Exit codes:** 0 = success, non-zero = failure

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

---

## scripts/tools/junitxmlparser.py

Parses JUnit XML test results and extracts failures.

**Syntax:**
```bash
python3 scripts/tools/junitxmlparser.py <test-result.xml>
```

**Output:** Formatted test failures with class name, method name, and stack traces

**Note:** Used internally by run-tests.sh
