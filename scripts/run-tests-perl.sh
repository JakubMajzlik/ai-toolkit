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
RC=$?

# All tests passed
if [ $RC -eq 0 ]; then
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
    exit $RC
fi

echo "Failed tests and reasons:"
# Parse XML results with a small perl parser to extract failing testcases
# Use find ... -print0 piped to while/read to avoid bash-only process substitution/mapfile
find . -type f -path '*/build/test-results/test/*.xml' -print0 | while IFS= read -r -d '' f; do
    # write a small perl parser to a temp file to avoid complex inline quoting that can be
    # misinterpreted when the script is invoked with a different shell
    PARSER="$TMP_DIR/parse_failures.pl"
    cat >"$PARSER" <<'PERL'
#!/usr/bin/env perl
use strict;
use warnings;
local $/ = undef;
my $file = shift @ARGV;
my $xml = do { local @ARGV = ($file); local $/ = undef; <> };
while ($xml =~ /<testcase([^>]*)>(?:.*?)<(failure|error)\b([^>]*)>(.*?)<\/(?:failure|error)>/sg) {
    my ($attrs, $type, $meta, $content) = ($1, $2, $3, $4);
    my ($name, $classname, $msg) = ("", "", "");
    $name = $1 if $attrs =~ /name="([^"]+)"/;
    $classname = $1 if $attrs =~ /classname="([^"]+)"/;
    $msg = $1 if $meta =~ /message="([^"]*)"/;
    $content =~ s/^\s+|\s+$//g;
    # Decode common XML/HTML entities so messages show raw characters like '<' and '>' instead of '&lt;' and '&gt;'
    for my $s ($msg, $content) {
        $s =~ s/&lt;/</g;
        $s =~ s/&gt;/>/g;
        $s =~ s/&quot;/"/g;
        $s =~ s/&apos;/\x27/g;
        $s =~ s/&#x([0-9A-Fa-f]+);/chr(hex($1))/eg;
        $s =~ s/&#([0-9]+);/chr($1)/eg;
        $s =~ s/&amp;/&/g;
    }
    print "$classname#$name: $type: $msg\n";
    my @lines = split /\n/, $content;
    my $max = @lines < 200 ? @lines : 200;
    for my $i (0..($max-1)) { print $lines[$i] . "\n" if defined $lines[$i]; }
    print "\n";
}
PERL
    chmod 0700 "$PARSER"
    perl "$PARSER" "$f"
done
rm -f "$TMP_DIR/parse_failures.pl"

rm -rf "$TMP_DIR"
exit $RC