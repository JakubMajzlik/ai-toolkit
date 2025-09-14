#!/usr/bin/env bash
# run-ktlintFormat - run ./gradlew ktlintFormat and print OK on success
# On failure print only the error output (stderr) from the command

set -o pipefail

GRADLE_CMD="./gradlew ktlintFormat"

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
