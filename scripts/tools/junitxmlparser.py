#!/usr/bin/env python3
"""Parse JUnit XML test result files and extract failure information."""
import sys
import re


def decode_xml_entities(text):
    """Decode common XML/HTML entities."""
    text = text.replace('&lt;', '<')
    text = text.replace('&gt;', '>')
    text = text.replace('&quot;', '"')
    text = text.replace('&apos;', "'")
    # Decode hex entities like &#x27;
    text = re.sub(r'&#x([0-9A-Fa-f]+);', lambda m: chr(int(m.group(1), 16)), text)
    # Decode decimal entities like &#39;
    text = re.sub(r'&#(\d+);', lambda m: chr(int(m.group(1))), text)
    text = text.replace('&amp;', '&')
    return text


def parse_test_failures(xml_file):
    """Parse XML test results and print failures."""
    with open(xml_file, 'r', encoding='utf-8') as f:
        xml = f.read()

    # Find all testcase elements with failure or error child elements
    pattern = r'<testcase([^>]*)>(?:.*?)<(failure|error)\b([^>]*)>(.*?)</(?:failure|error)>'
    matches = re.finditer(pattern, xml, re.DOTALL)

    for match in matches:
        attrs = match.group(1)
        failure_type = match.group(2)
        meta = match.group(3)
        content = match.group(4)

        # Extract testcase attributes
        name_match = re.search(r'name="([^"]+)"', attrs)
        classname_match = re.search(r'classname="([^"]+)"', attrs)
        msg_match = re.search(r'message="([^"]*)"', meta)

        name = name_match.group(1) if name_match else ""
        classname = classname_match.group(1) if classname_match else ""
        msg = msg_match.group(1) if msg_match else ""

        # Clean content
        content = content.strip()

        # Decode entities
        msg = decode_xml_entities(msg)
        content = decode_xml_entities(content)

        # Print failure information
        print(f"{classname}#{name}: {failure_type}: {msg}")

        # Print content (limited to 200 lines)
        lines = content.split('\n')
        max_lines = min(len(lines), 200)
        for i in range(max_lines):
            print(lines[i])
        print()


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: xmlparser.py <test-result.xml>", file=sys.stderr)
        sys.exit(1)

    parse_test_failures(sys.argv[1])
