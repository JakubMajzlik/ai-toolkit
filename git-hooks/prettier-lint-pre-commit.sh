#!/usr/bin/env bash
# Git pre-commit hook: run prettier and lint checks before commit.
#
# Configuration:
# - PRETTIER_SCRIPT: path to prettier format runner
#   Default: scripts/run-prettier-format.sh (if executable)
# - LINT_SCRIPT: path to lint runner
#   Default: scripts/run-prettier-lint.sh (if executable)
#
# Fallbacks:
# - If PRETTIER_SCRIPT is missing, format staged supported files with:
#   1) npx prettier --write
#   2) bunx prettier --write
# - If LINT_SCRIPT is missing, lint with:
#   1) npm run lint
#   2) bun run lint
#
# Optional override example:
#   PRETTIER_SCRIPT=./custom/prettier.sh LINT_SCRIPT=./custom/lint.sh .git/hooks/pre-commit
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

PRETTIER_SCRIPT="${PRETTIER_SCRIPT:-$REPO_ROOT/scripts/run-prettier-format.sh}"
LINT_SCRIPT="${LINT_SCRIPT:-$REPO_ROOT/scripts/run-prettier-lint.sh}"

TMP_DIR="$(mktemp -d)"
STAGED_BEFORE="$TMP_DIR/staged-before.txt"
PARTIAL_STAGED="$TMP_DIR/partial-staged.txt"
trap cleanup EXIT INT TERM

git diff --cached --name-only --diff-filter=ACMR >"$STAGED_BEFORE"

is_prettier_target() {
    case "$1" in
        *.js|*.jsx|*.ts|*.tsx|*.json|*.md|*.yaml|*.yml|*.css|*.scss|*.html)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

collect_prettier_targets() {
    PRETTIER_TARGETS=()
    while IFS= read -r path; do
        [ -z "$path" ] && continue
        is_prettier_target "$path" || continue
        if [ -e "$path" ]; then
            PRETTIER_TARGETS+=("$path")
        fi
    done <"$STAGED_BEFORE"
}

detect_partial_staged_all_staged() {
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

run_prettier_fallback() {
    if [ "${#PRETTIER_TARGETS[@]}" -eq 0 ]; then
        echo "No staged files need prettier formatting"
        return 0
    fi

    detect_partial_staged_all_staged
    if [ -s "$PARTIAL_STAGED" ]; then
        echo "Pre-commit blocked: partially staged files detected; resolve staged hunks first:"
        cat "$PARTIAL_STAGED"
        return 1
    fi

    if command -v npx >/dev/null 2>&1; then
        echo "Running prettier with npx on staged files..."
        npx prettier --write "${PRETTIER_TARGETS[@]}" || return 1
        restage_previously_staged
        return 0
    fi

    if command -v bunx >/dev/null 2>&1; then
        echo "Running prettier with bunx on staged files..."
        bunx prettier --write "${PRETTIER_TARGETS[@]}" || return 1
        restage_previously_staged
        return 0
    fi

    echo "Pre-commit blocked: no prettier runner found (need PRETTIER_SCRIPT, npx, or bunx)"
    return 1
}

run_lint_fallback() {
    if command -v npm >/dev/null 2>&1; then
        echo "Running lint with npm..."
        if npm run lint; then
            return 0
        fi
        echo "npm lint failed, trying bun fallback..."
    fi

    if command -v bun >/dev/null 2>&1; then
        echo "Running lint with bun..."
        bun run lint || return 1
        return 0
    fi

    echo "Pre-commit blocked: no lint runner found (need LINT_SCRIPT, npm, or bun)"
    return 1
}

if [ -x "$PRETTIER_SCRIPT" ]; then
    collect_prettier_targets
    detect_partial_staged_all_staged
    if [ -s "$PARTIAL_STAGED" ]; then
        echo "Pre-commit blocked: partially staged files detected; resolve staged hunks first:"
        cat "$PARTIAL_STAGED"
        exit 1
    fi

    echo "Running prettier format script..."
    if ! "$PRETTIER_SCRIPT"; then
        echo "Pre-commit blocked: prettier format failed"
        exit 1
    fi
    restage_previously_staged
else
    collect_prettier_targets
    if ! run_prettier_fallback; then
        echo "Pre-commit blocked: prettier formatting failed"
        exit 1
    fi
fi

if [ -x "$LINT_SCRIPT" ]; then
    echo "Running lint script..."
    if ! "$LINT_SCRIPT"; then
        echo "Pre-commit blocked: lint script failed"
        exit 1
    fi
else
    if ! run_lint_fallback; then
        echo "Pre-commit blocked: lint failed"
        exit 1
    fi
fi

echo "Pre-commit checks passed"
exit 0
