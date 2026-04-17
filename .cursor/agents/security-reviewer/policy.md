## Security Review Policy

This file defines the project security policies that the `security-reviewer` subagent must enforce.

Update this file whenever your team's security requirements change. The subagent should treat the items below as mandatory review criteria unless a policy explicitly says otherwise.

### 1. Secrets and Credentials

- Never hardcode secrets, API keys, tokens, passwords, private keys, or connection strings in source code, tests, fixtures, logs, or documentation.
- Secrets must come from approved secret stores or environment variables.
- Example placeholder values must be obviously fake.

### 2. Authentication and Authorization

- Every sensitive action must have explicit authentication and authorization checks.
- Do not trust client-supplied roles, tenant IDs, ownership flags, or permission claims without server-side verification.
- Follow deny-by-default behavior for access control.

### 3. Input Validation and Output Handling

- Validate and normalize all untrusted input at system boundaries.
- Prefer allowlists and typed parsing over fragile string checks.
- Encode or escape output for the target context to prevent injection vulnerabilities.

### 4. Data Protection

- Minimize collection, storage, and exposure of sensitive data.
- Sensitive data must be encrypted in transit and at rest when applicable.
- Logs, metrics, analytics events, and error messages must not expose sensitive data.

### 5. Dependency and Supply Chain Safety

- New dependencies must be justified and kept minimal.
- Avoid unmaintained, suspicious, or overly permissive packages when safer alternatives exist.
- Do not disable integrity, TLS, signature, or lockfile protections without a clear reason.

### 6. Secure Defaults and Configuration

- Default configurations must be safe for production-like use.
- Debug, admin, test-only, and bypass behavior must be disabled by default.
- Security-relevant configuration must fail closed when missing or invalid.

### 7. Common Application Security Checks

- Prevent SQL, NoSQL, shell, template, path traversal, deserialization, SSRF, XSS, CSRF, and command injection risks where relevant.
- Use parameterized queries and safe APIs instead of string concatenation for interpreters.
- File system and network access must be constrained to intended targets.

### 8. Session and Token Handling

- Tokens, cookies, and session identifiers must be protected from leakage and misuse.
- Use secure cookie settings where applicable.
- Avoid long-lived credentials unless explicitly required and documented.

### 9. Security Logging and Error Handling

- Log security-relevant events when useful for detection and auditing.
- Error messages should help operators without leaking internal details to untrusted users.
- Failures in security controls should be visible and actionable.

### 10. Review Severity Guidance

- Critical: clear exploitable issue, broken authorization, exposed secret, or severe data exposure.
- High: likely vulnerability or major policy violation with meaningful impact.
- Medium: risky pattern, incomplete control, or missing defense that could become exploitable.
- Low: defense-in-depth gap, hygiene issue, or unclear security assumption.

### 11. Required Review Output

For each review, the subagent should:

1. Cite which policy section applies.
2. Explain the concrete risk.
3. State whether the issue is confirmed, likely, or needs clarification.
4. Suggest the safest practical remediation.
