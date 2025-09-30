#!/usr/bin/env bash
# run-tests.sh - run Gradle tests and report failures
# Usage: ./run-tests.sh [gradle test args...]
set -u

# Ensure this script is run with bash (not plain sh); running with `sh script` can mis-parse
# the embedded single-quoted Perl block and produce confusing errors. If you invoked with
# `sh` please run with `bash` or `./run-tests.sh`.
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

# Run tests and capture output
"$GRADLE" test "$@" >"$OUT" 2>&1
ERROR_CODE=$?

# All tests passed
if [ $ERROR_CODE -eq 0 ]; then
    echo "OK"
    rm -rf "$TMP_DIR"
    exit 0
fi

# Collect Kotlin compilation errors (lines starting with `e:` produced by kotlinc)
# Example line: "e: file:///path/to/File.kt:12:34 Unresolved reference 'Icons'"
COMPILE_ERRORS=$(grep -E '^[[:space:]]*e:' "$OUT" || true)
if [ -n "$COMPILE_ERRORS" ]; then
    echo "Kotlin compilation errors:"
    # Normalize paths (remove leading 'e: ' and optional 'file://' scheme) and print up to 200 lines
    echo "$COMPILE_ERRORS" | sed -E \
        -e 's/^[[:space:]]*e:[[:space:]]*file:\/\/+//g' \
        -e 's/^[[:space:]]*e:[[:space:]]*//g' | head -n 200
    echo
fi

# Find XML test result files (may be multiple modules)
# If no XML results are present, dump gradle output for diagnosis
if ! find . -type f -path '*/build/test-results/test/*.xml' -print -quit | grep -q .; then
    echo "Tests failed but no test result XML files were found."
    if [ -n "$COMPILE_ERRORS" ]; then
        echo "(Compilation errors were detected above; full Gradle output follows - last 200 lines):"
    else
        echo "Gradle output (last 200 lines):"
    fi
    tail -n 200 "$OUT"
    rm -rf "$TMP_DIR"
    exit $ERROR_CODE
fi

echo "Failed tests and reasons:"
# Parse XML results with Python parser to extract failing testcases
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARSER="$SCRIPT_DIR/tools/junitxmlparser.py"

if [ ! -f "$PARSER" ]; then
    echo "Error: XML parser not found at $PARSER" >&2
    rm -rf "$TMP_DIR"
    exit 2
fi

find . -type f -path '*/build/test-results/test/*.xml' -print0 | while IFS= read -r -d '' f; do
    python3 "$PARSER" "$f"
done

rm -rf "$TMP_DIR"
exit $ERROR_CODE