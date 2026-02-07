#!/usr/bin/env bash
# run-junit-tests.sh - run Gradle tests and print minimal JUnit summary
# Usage: ./scripts/run-junit-tests.sh [gradle test args...]
set -u

if [ -z "${BASH_VERSION:-}" ]; then
    echo "ERROR bash is required"
    exit 2
fi

if [ -x ./gradlew ]; then
    GRADLE=./gradlew
elif command -v gradle >/dev/null 2>&1; then
    GRADLE=gradle
else
    echo "ERROR no gradle or gradlew found"
    exit 2
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR python3 not found"
    exit 2
fi

TMP_DIR=$(mktemp -d)
OUT="$TMP_DIR/gradle-output.txt"
MARKER="$TMP_DIR/marker"
XML_LIST="$TMP_DIR/xml-files.txt"
touch "$MARKER"
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

"$GRADLE" test "$@" >"$OUT" 2>&1
GRADLE_EXIT=$?

find . -type f -path '*/build/test-results/*/*.xml' -newer "$MARKER" | sort >"$XML_LIST"

if [ ! -s "$XML_LIST" ]; then
    echo "FAIL failed=0 passed=0"
    echo "ERROR gradle#execution: no test result xml generated"
    tail -n 120 "$OUT" | sed '/^[[:space:]]*$/d' | tail -n 4
    exit 2
fi

python3 - "$XML_LIST" <<'PY'
import html
import re
import sys
import xml.etree.ElementTree as ET


def clean(text: str) -> str:
    return html.unescape(text or "")


def squash(text: str) -> str:
    text = text.strip()
    if not text:
        return "<unavailable>"
    return " ".join(text.split())


def extract_assert_diff(message: str, body: str):
    source = "\n".join([part for part in [message, body] if part]).strip()
    if not source:
        return ("<unavailable>", "<unavailable>")

    patterns = [
        r"expected:\s*<(.+?)>\s*but was:\s*<(.+?)>",
        r"expected:\s*(.+?)\s*but was:\s*(.+)",
        r"Expected\s*:?\s*(.+?)\n+Actual\s*:?\s*(.+)",
    ]
    for pattern in patterns:
        match = re.search(pattern, source, re.IGNORECASE | re.DOTALL)
        if match:
            return (squash(match.group(1)), squash(match.group(2)))

    lines = [line.strip() for line in source.splitlines() if line.strip()]
    expected = lines[0] if len(lines) >= 1 else "<unavailable>"
    actual = lines[1] if len(lines) >= 2 else "<unavailable>"
    return (squash(expected), squash(actual))


def extract_frames(text: str):
    lines = text.splitlines()
    frames = []
    for line in lines:
        striped = line.strip()
        if striped.startswith("at "):
            frames.append(striped)
        if len(frames) == 4:
            break
    if frames:
        return frames
    fallback = [line.strip() for line in lines if line.strip()]
    return fallback[:4]


def testcase_id(case):
    classname = case.attrib.get("classname", "").strip()
    name = case.attrib.get("name", "").strip()
    if classname and name:
        return f"{classname}#{name}"
    if classname:
        return f"{classname}#<unknown>"
    if name:
        return f"<unknown>#{name}"
    return "<unknown>#<unknown>"


def main():
    if len(sys.argv) != 2:
        print("FAIL failed=0 passed=0")
        print("ERROR parser#xml: invalid parser invocation")
        return 2

    xml_list_file = sys.argv[1]
    try:
        with open(xml_list_file, "r", encoding="utf-8") as handle:
            files = [line.strip() for line in handle if line.strip()]
    except Exception as exc:
        print("FAIL failed=0 passed=0")
        print(f"ERROR parser#xml: unable to read xml file list: {exc}")
        return 2

    passed = 0
    failed = 0
    assert_blocks = []
    error_blocks = []
    parser_error = False

    for file_path in files:
        try:
            tree = ET.parse(file_path)
        except Exception as exc:
            parser_error = True
            error_blocks.append((f"parser#xml({file_path})", squash(str(exc)), []))
            continue

        root = tree.getroot()
        for case in root.iter("testcase"):
            test_id = testcase_id(case)
            failure = case.find("failure")
            error = case.find("error")

            if failure is not None:
                failed += 1
                message = clean(failure.attrib.get("message", ""))
                body = clean(failure.text or "")
                expected, actual = extract_assert_diff(message, body)
                assert_blocks.append((test_id, expected, actual))
                continue

            if error is not None:
                failed += 1
                message = squash(clean(error.attrib.get("message", "")))
                body = clean(error.text or "")
                if message == "<unavailable>":
                    first = [line.strip() for line in body.splitlines() if line.strip()]
                    message = squash(first[0]) if first else "<unavailable>"
                error_blocks.append((test_id, message, extract_frames(body)))
                continue

            passed += 1

    if failed == 0 and not parser_error:
        print(f"OK {passed}")
        return 0

    print(f"FAIL failed={failed} passed={passed}")

    for test_id, expected, actual in assert_blocks:
        print(f"ASSERT {test_id}")
        print(f"expected: {expected}")
        print(f"actual: {actual}")

    for test_id, message, frames in error_blocks:
        print(f"ERROR {test_id}: {message}")
        for frame in frames[:4]:
            print(frame)

    if parser_error:
        return 2
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
PY

PARSER_EXIT=$?
if [ $PARSER_EXIT -eq 0 ]; then
    exit 0
fi
if [ $PARSER_EXIT -eq 1 ]; then
    exit 1
fi

if [ $GRADLE_EXIT -ne 0 ]; then
    exit 2
fi
exit 2
