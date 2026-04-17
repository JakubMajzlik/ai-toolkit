## Security Review Policy

This file defines the mandatory review baseline for the `security-reviewer` subagent.

The reviewer must use this file as an enforcement policy, not as background reading. When the code, config, or design under review conflicts with this policy, the reviewer should raise a finding unless there is explicit project-approved justification.

## 1. Scope and Evidence Rules

### 1.1 Mandatory Baselines

The reviewer must assess relevant changes against:

- OWASP Top 10 (2021)
- OWASP API Security Top 10 (2023) for API-facing systems
- The secure delivery expectations reflected in the project's feature and release guidance

### 1.2 Evidence Standard

- Treat only code, configuration, tests, scripts, IaC, and explicit documentation in the reviewed change set or nearby codebase as evidence.
- Do not assume a control exists because it is common, desirable, or mentioned in a ticket.
- If a required control cannot be verified from available evidence, call it out as a blind spot or likely gap instead of marking it satisfied.
- Distinguish implementation bugs from design gaps, operational assumptions, and missing verification evidence.

### 1.3 Review Mindset

- Prefer concrete, exploitable findings over generic advice.
- Flag risky defaults, bypasses, and missing controls even when there is no confirmed exploit path yet.
- Consider misuse, abuse, denial-of-service, and cross-boundary behavior, not just happy-path correctness.

## 2. Secure Design and Delivery

### 2.1 Threat Modeling and Security Requirements

- Security-sensitive features should show evidence that threats, misuse cases, and abuse cases were considered.
- For larger or higher-risk changes, expect lightweight threat modeling or design reasoning around trust boundaries, privileged actions, data flows, and failure modes.
- Security requirements should be derived from feature behavior, threat model assumptions, and applicable OWASP categories.

### 2.2 Secure Design Principles

The reviewer should look for and favor:

- Least privilege
- Defense in depth
- Fail secure / deny by default
- Separation of duties
- Privacy by design and privacy by default
- Segregation of application tiers, tenants, and sensitive components
- Resource limitation to reduce abuse and denial-of-service impact

### 2.3 Verification Expectations

- Security controls should be covered by tests where practical, especially for authorization, validation, authentication, misuse handling, and high-risk flows.
- High-risk modules should receive deeper review than low-risk code.
- Residual risk and unsupported assumptions should be made explicit.

## 3. Identity, Authentication, and Access Control

### 3.1 Authentication

- Never ship default credentials.
- Authentication should be centralized where the architecture provides an IdP or token issuer.
- Authentication flows, password reset, registration, and session establishment must resist account enumeration and brute-force abuse.
- Rate limiting, progressive delay, lockout strategy, or equivalent abuse resistance should exist for login-like endpoints when relevant.

### 3.2 Authorization

- Every sensitive operation must perform server-side authorization.
- Do not trust client-supplied roles, tenant identifiers, ownership flags, or permission claims without verification.
- Use deny-by-default behavior.
- Prefer centralized, reusable authorization logic over scattered ad hoc checks.
- Check for IDOR and cross-tenant access risks whenever identifiers or resource references are exposed.

### 3.3 Sessions and Tokens

- Session identifiers and tokens must be high-entropy, validated, and protected from leakage.
- Invalidate sessions or tokens on logout, expiry, and other relevant lifecycle events.
- Avoid long-lived credentials unless explicitly justified.
- Never accept unsecured JWTs or equivalent unsigned tokens.
- Token consumers must validate integrity and claims, not just parse the payload.
- Sensitive tokens, credentials, and API keys must not appear in URLs or query parameters.

## 4. Input, Output, and Injection Safety

### 4.1 Input Validation

- Treat all external input as untrusted, including headers, cookies, bodies, query params, URLs, files, and messages from other services.
- Validate type, length, format, range, and allowed values at the server boundary.
- Prefer strong typing and allowlists over regex-only or deny-list-based defenses.
- Reject unexpected content and oversized requests.

### 4.2 Injection Prevention

- Prevent SQL, NoSQL, shell, LDAP, template, path, deserialization, expression-language, XML, and command injection where relevant.
- Use parameterized queries and safe APIs instead of building interpreter input with string concatenation.
- Never let untrusted input control query structure, command structure, file paths, or system targets without strict mediation.

### 4.3 Output and Error Handling

- Encode or escape output for its target context to prevent XSS and related injection issues.
- Error responses must not expose stack traces, internal topology, secrets, or sensitive implementation details.
- For APIs and services, return accurate status codes and generic client-safe error messages.

## 5. Data Protection, Secrets, and Cryptography

### 5.1 Sensitive Data Handling

- Minimize collection, storage, and exposure of sensitive data.
- Sensitive data must be protected in transit and at rest where applicable.
- Disable or limit caching for responses containing sensitive data when appropriate.
- Logs, metrics, analytics, and error payloads must not leak sensitive data.

### 5.2 Secrets Handling

- Never hardcode secrets, keys, passwords, tokens, or connection strings in code, config committed to the repo, fixtures, or docs.
- Secrets configured by infrastructure should use approved secret-management mechanisms such as Kubernetes Secrets where applicable.
- End-user-configurable secrets should use an approved secret store such as HashiCorp Vault where available.
- Legacy systems that cannot use the standard secret store must encrypt stored secrets with established symmetric cryptography and keep keys outside the unsecured store.
- Do not invent custom secret storage or custom cryptographic mechanisms.
- Review for rotation, revocation, auditability, and least-privilege access to secrets where visible from the code or config.

### 5.3 Approved Cryptographic Practice

- Use established libraries and approved algorithms; do not implement custom cryptographic primitives.
- Avoid deprecated or weak algorithms such as MD5 and SHA-1 for security-sensitive use.
- For password hashing, prefer Argon2id; if unavailable, scrypt; bcrypt or PBKDF2 only when justified by platform constraints.
- General-purpose fast hashes like SHA-2 and SHA-3 are not acceptable for password storage by themselves.
- Password hashing must include unique salts; peppers, if used, must be stored separately from the data store in approved secret management.
- Keys, IVs, salts, nonces, and random tokens must come from cryptographically secure randomness.

## 6. API and Service Communication

### 6.1 REST and HTTP APIs

- Non-public APIs must authenticate and authorize every endpoint.
- Anonymous access is prohibited unless explicitly intended and safe.
- Use HTTPS for REST communication outside trusted platform boundaries; stronger mutual authentication should be considered for highly privileged service communication.
- Apply method allowlists and reject unsupported methods.
- Set appropriate request size limits.
- Configure CORS narrowly; disable it when cross-origin access is not needed.
- Management or admin endpoints must not be internet-exposed by default and should be separately protected.
- Include appropriate security headers when relevant to the interface.

### 6.2 Server-to-Server and Messaging

- Treat internal service communication as hostile by default; internal does not mean trusted.
- For RabbitMQ and similar messaging systems, require strong authentication, least-privilege permissions, and encrypted transport.
- Management interfaces for brokers and infrastructure should be restricted to internal/admin access in production.
- Message payloads, broker credentials, and backups must be protected appropriately.
- Network access to brokers and internal services should be restricted by policy, firewall rules, or network policy where applicable.

### 6.3 SSRF and Outbound Requests

- Any feature that fetches remote resources based on input must validate scheme, host, port, and destination against an allowlist.
- Do not rely on deny lists or weak regex filters for SSRF defense.
- Avoid returning raw fetched responses directly to the client.
- Disable unsafe redirect-following when not required.
- Consider internal-network reachability, localhost access, DNS rebinding, and TOCTOU risks.

## 7. Secure Configuration, Dependencies, and Supply Chain

### 7.1 Secure Defaults

- Default configuration must be the safest practical production-like configuration.
- Debug, admin, test-only, and bypass features must be disabled by default.
- Missing or invalid security configuration should fail closed when feasible.
- Remove unused features, sample apps, default accounts, unnecessary services, and stale integration points.

### 7.2 Dependencies and Components

- New dependencies must be justified, minimal, and sourced from trusted registries over secure transport.
- Prefer signed or otherwise integrity-protected packages when supported.
- Remove unused dependencies and components.
- Flag outdated, unsupported, or vulnerable dependencies and runtimes when evidence is present.
- Expect component inventory and vulnerability scanning practices such as SBOM/SCA to be part of secure delivery, and call out missing evidence where relevant.

### 7.3 Build and Delivery Integrity

- Code and configuration changes should pass through peer review and automated security checks.
- Build and deployment processes should preserve artifact integrity.
- Do not disable lockfile, signature, TLS, or integrity protections without explicit justification.
- CI/CD and deployment configuration should enforce appropriate segregation of duties and change control when visible from the codebase.

## 8. Logging, Monitoring, and Operations

### 8.1 Security Logging

- Log authentication failures, authorization failures, validation failures, and other security-relevant events where doing so helps detection and response.
- Logs should be structured where practical and protected against tampering and injection.
- High-value or security-sensitive actions should have an audit trail when applicable.

### 8.2 Monitoring and Incident Support

- Critical security events should be monitorable and, where appropriate, alertable.
- The system should expose enough evidence for investigation without disclosing sensitive data to untrusted users.
- Review whether operational hardening, patching, and secure update practices are supported by the implementation.

## 9. Findings and Severity

### 9.1 Severity Guidance

- Critical: clear exploitable issue, broken authorization, exposed secret, integrity failure, or severe sensitive-data exposure.
- High: likely exploitable vulnerability, strong policy violation, or missing control with meaningful impact.
- Medium: risky pattern, incomplete mitigation, or missing defense that could become exploitable.
- Low: defense-in-depth gap, hygiene issue, or unclear assumption with limited direct impact.

### 9.2 Required Review Output

For each finding, include:

1. Title
2. Severity
3. Policy section(s) implicated
4. Evidence
5. Whether the issue is confirmed, likely, or needs clarification
6. Concrete risk explanation
7. Safest practical remediation

If no issues are found, the review must still state:

1. What was reviewed
2. Which policy areas were checked
3. What could not be verified from the available evidence
4. Any residual risk or missing tests
