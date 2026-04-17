---
name: create-kotlin-tests
description: Create or update Kotlin tests in Spring Boot projects using strict test conventions (UnitTest/JpaTest/ApiTest/IntegrationTest bases, MockK annotations, coverage-focused cases). Use when asked to write tests, add missing cases, improve coverage, or validate repositories, REST API contracts/auth, or integration flows in Kotlin/Spring Boot.
---

# Create Kotlin Tests

## Workflow

1. Identify the subject under test and pick the correct base class:
   - `UnitTest` for pure unit tests.
   - `JpaTest` for repositories and query behavior.
   - `ApiTest` for REST contracts, authorization, and controller behavior; mock dependencies.
   - `IntegrationTest` for end-to-end or multi-layer flows.
2. For every tested function, create an `inner class` grouping its test cases.
3. Cover test cases to target 100% code coverage for the function:
   - Best-case (happy path)
   - Error scenarios
   - Edge cases
4. Use JUnit for assertions and MockK for mocking.

## Kotlin + Spring Boot Testing Rules

- All tests must extend one of: `UnitTest`, `JpaTest`, `ApiTest`, or `IntegrationTest`.
- Prefer `@Mockk` and `@InjectMockk` in `UnitTest` (MockK already set up there).
- `JpaTest` is primarily for repository tests and query validation.
- `ApiTest` is for REST endpoint contracts, auth behavior, and should mock its dependencies.
- For mocking Spring beans, create a configuration subclass and include it in the test; do not use MockKBean/MockitoBean.
- Do not mock data classes.
- Exception assertions: assert only the exception type, not the message.
- Do not use comments like `// Arrange`, `// Act`, `// Assert`.
- If a test function name is not descriptive enough, add a brief comment on the function describing the test case.

## Output Expectations

- Group tests by function using `inner class`.
- Use clear, consistent naming for test methods; add a short comment only when the name is not self-descriptive.
- Ensure coverage includes best-case, error, and edge cases for each function.
