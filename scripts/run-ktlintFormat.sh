#!/usr/bin/env bash
# run-ktlintFormat - run ./gradlew ktlintFormat and print OK on success
# On failure print only the error output (stderr) from the command

set -o pipefail

# pick gradle wrapper if available
if [ -x ./gradlew ]; then
    GRADLE=./gradlew
elif command -v gradle >/dev/null 2>&1; then
    GRADLE=gradle
else
    echo "No gradle or gradlew found in PATH" >&2
    exit 2
fi

GRADLE_CMD="$GRADLE ktlintFormat"

# Run the command, capture stdout and stderr separately
stdout_file=$(mktemp)
stderr_file=$(mktemp)

# Ensure temp files are removed on exit
cleanup() {
  rm -f "$stdout_file" "$stderr_file"
}
trap cleanup EXIT

# Execute the command
if $GRADLE_CMD >"$stdout_file" 2>"$stderr_file"; then
  # Success: print OK to stdout
  echo "OK"
  exit 0
else
  # Failure: print only the stderr (errors) to stdout (as requested "just errors")
  # If stderr is empty for some reason, fallback to printing stdout
  if [ -s "$stderr_file" ]; then
    cat "$stderr_file"
  else
    cat "$stdout_file"
  fi
  exit 1
fi
