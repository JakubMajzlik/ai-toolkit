#!/usr/bin/env bash
# Git pre-commit hook: run ktlint format and lint checks before commit.
#
# Configuration:
# - FORMAT_SCRIPT: path to ktlint format runner
#   Default: scripts/run-ktlintFormat.sh
# - LINT_SCRIPT: path to lint check runner
#   Default: scripts/run-lintProject.sh
#
# Optional override example:
#   FORMAT_SCRIPT=./custom/format.sh LINT_SCRIPT=./custom/lint.sh .git/hooks/pre-commit
set -u
set -o pipefail

cleanup() {
    rm -rf "$TMP_DIR"
}

if [ -z "${BASH_VERSION:-}" ]; then
    echo "Pre-commit blocked: bash is required"
    exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT" || exit 1

FORMAT_SCRIPT="${FORMAT_SCRIPT:-$REPO_ROOT/scripts/run-ktlintFormat.sh}"
LINT_SCRIPT="${LINT_SCRIPT:-$REPO_ROOT/scripts/run-lintProject.sh}"

TMP_DIR="$(mktemp -d)"
STAGED_BEFORE="$TMP_DIR/staged-before.txt"
PARTIAL_STAGED="$TMP_DIR/partial-staged.txt"
TASKS_OUT="$TMP_DIR/gradle-tasks.txt"
trap cleanup EXIT INT TERM

# Capture paths that were staged before formatting.
git diff --cached --name-only --diff-filter=ACMR >"$STAGED_BEFORE"

detect_partial_staged_files() {
    : >"$PARTIAL_STAGED"
    while IFS= read -r path; do
        [ -z "$path" ] && continue
        if ! git diff --quiet -- "$path"; then
            echo "$path" >>"$PARTIAL_STAGED"
        fi
    done <"$STAGED_BEFORE"
}

restage_previously_staged() {
    while IFS= read -r path; do
        [ -z "$path" ] && continue
        if [ -e "$path" ]; then
            git add -- "$path"
        else
            git add -u -- "$path"
        fi
    done <"$STAGED_BEFORE"
}

FORMAT_EXISTS=false
LINT_EXISTS=false

if [ -x "$FORMAT_SCRIPT" ]; then
    FORMAT_EXISTS=true
fi

if [ -x "$LINT_SCRIPT" ]; then
    LINT_EXISTS=true
fi

if $FORMAT_EXISTS; then
    detect_partial_staged_files
    if [ -s "$PARTIAL_STAGED" ]; then
        echo "Pre-commit blocked: partially staged files detected; run commit after resolving staged hunks:"
        cat "$PARTIAL_STAGED"
        exit 1
    fi

    echo "Running ktlint format..."
    if ! "$FORMAT_SCRIPT"; then
        echo "Pre-commit blocked: ktlint format failed"
        exit 1
    fi
    restage_previously_staged
fi

if $LINT_EXISTS; then
    echo "Running lintProject..."
    if ! "$LINT_SCRIPT"; then
        echo "Pre-commit blocked: lintProject failed"
        exit 1
    fi
    echo "Pre-commit checks passed"
    exit 0
fi

if [ -x "$REPO_ROOT/gradlew" ]; then
    GRADLE="$REPO_ROOT/gradlew"
elif command -v gradle >/dev/null 2>&1; then
    GRADLE="gradle"
else
    echo "Pre-commit blocked: no gradle or gradlew found for ktlintCheck fallback"
    exit 1
fi

echo "Lint script is missing, trying ktlintCheck..."
"$GRADLE" tasks --all >"$TASKS_OUT" 2>/dev/null || true
if ! grep -E -q '(\b|/)ktlintCheck(\b|:)' "$TASKS_OUT"; then
    echo "ktlintCheck task is missing, skipping check"
    echo "Pre-commit checks passed"
    exit 0
fi

echo "Running ktlintCheck..."
if ! "$GRADLE" ktlintCheck; then
    echo "Pre-commit blocked: ktlintCheck failed"
    exit 1
fi

echo "Pre-commit checks passed"
exit 0
