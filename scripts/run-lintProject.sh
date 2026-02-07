#!/usr/bin/env bash
# run-lintProject - run Gradle lintProject and report ktlint/detekt issues
# Usage: ./run-lintProject [gradle args...]
set -u

# Ensure this script is run with bash
if [ -z "${BASH_VERSION:-}" ]; then
    echo "This script requires bash. Run with: bash $0 or ./$(basename "$0")" >&2
    exit 2
fi

# pick gradle wrapper if available
if [ -x ./gradlew ]; then
    GRADLE=./gradlew
elif command -v gradle >/dev/null 2>&1; then
    GRADLE=gradle
else
    echo "No gradle or gradlew found in PATH" >&2
    exit 2
fi

TMP_DIR=$(mktemp -d)
OUT="$TMP_DIR/gradle-output.txt"

# Check whether the `lintProject` task exists in this Gradle project. If not, skip.
# We run the tasks listing quietly and search for the task name. Use wrapper if available.
TASKS_OUT="$TMP_DIR/gradle-tasks.txt"
"$GRADLE" tasks --all >"$TASKS_OUT" 2>/dev/null || true
if ! grep -E -q '(\b|/)lintProject(\b|:)' "$TASKS_OUT"; then
    echo "Task is missing, skipping check"
    rm -rf "$TMP_DIR"
    exit 0
fi

# Run lint task and capture output
"$GRADLE" lintProject "$@" >"$OUT" 2>&1
RC=$?

# Success
if [ $RC -eq 0 ]; then
    echo "OK"
    rm -rf "$TMP_DIR"
    exit 0
fi

# Look for inline lint errors (ktlint/detekt format: path:line[:col] message)
# Match absolute or relative paths ending with .kt/.kts/.java followed by :number
LINT_ERRORS=$(grep -E '^[[:space:]]*/?[^[:space:]]+\.(kt|kts|java):[0-9]+' "$OUT" || true)

# Find ktlint report files referenced in Gradle output
KTREPORTS=$(grep -Eo '[/[:alnum:]._\-]*/build/reports/ktlint/[^[:space:]]+\.txt' "$OUT" || true)

# Find detekt report files (if any)
DETEKT_REPORTS=$(grep -Eo '[/[:alnum:]._\-]*/build/reports/detekt/[^[:space:]]+' "$OUT" || true)

if [ -n "$LINT_ERRORS" ]; then
    echo "Lint errors (ktlint/detekt):"
    echo "$LINT_ERRORS" | sed -E 's/^[[:space:]]*//g' | head -n 500
    echo
fi

if [ -n "$KTREPORTS" ]; then
    echo "KtLint report files found:"
    echo "$KTREPORTS" | sort -u
    echo
    # Show a short preview of each report
    while IFS= read -r rpt; do
        [ -z "$rpt" ] && continue
        if [ -f "$rpt" ]; then
            echo "== $rpt (first 200 lines) =="
            sed -n '1,200p' "$rpt"
            echo
        fi
    done <<< "$KTREPORTS"
fi

if [ -n "$DETEKT_REPORTS" ]; then
    echo "Detekt report files found:"
    echo "$DETEKT_REPORTS" | sort -u
    echo
    while IFS= read -r rpt; do
        [ -z "$rpt" ] && continue
        if [ -f "$rpt" ]; then
            echo "== $rpt (first 200 lines) =="
            sed -n '1,200p' "$rpt"
            echo
        fi
    done <<< "$DETEKT_REPORTS"
fi

# Fallback: if we found nothing useful, show last 200 lines of Gradle output
if [ -z "$LINT_ERRORS" ] && [ -z "$KTREPORTS" ] && [ -z "$DETEKT_REPORTS" ]; then
    echo "Lint failed but no inline errors or report files were detected. Gradle output (last 200 lines):"
    tail -n 200 "$OUT"
    rm -rf "$TMP_DIR"
    exit $RC
fi

rm -rf "$TMP_DIR"
exit $RC
