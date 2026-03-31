# Testing

## Core principles

- At the start of a task, it is always your responsibility to fix broken tests. You should never say "this test is not related to our work, so we'll leave it." Fix it.
- If you are working on something that can be built or run in the environment, a commit should not be made with the build in a broken state; all tests should pass and the build should work.
- Tests should not be updated to cater to broken behavior, unless we are specifically using TDD (break test first, confirm expected failure, then write the feature to fix it).
- Every commit that changes code for a feature or bug fix must be backed by a test covering that change. Exceptions: animations, purely visual changes, and other inherently UI-based fixes that can't be meaningfully asserted in a test.
- Test behavioral logic — code with branching, state, algorithms, or business rules. Don't write tests for static content, markup, configuration, or simple data changes where a build check is sufficient.
- When you change something, clean up after yourself. Do not leave dead code with a comment like "this isn't being used anymore but it's harmless." Remove it.
- Never skip a failing test. There is no justification for moving on with a test in a broken state — not scope, not time, not relevance. If a test is failing, fix it before doing anything else. Do not disable it, mark it as expected-failure, or defer it to a follow-up.
- If you can take a human out of the test loop and test changes yourself, so much the better. Use `playwright` or the equivalent for your project to visually verify the changes.

## Test doubles

- Each module MUST have exactly one file for shared test doubles (e.g. `test_helpers_test.go`, `__mocks__/`, `conftest.py`). Never duplicate stub types across test files within the same module or recreate a stub that exists in another module's test helpers. If a stub needs a new field or method, update the canonical definition — do not fork a local copy.
- If multiple modules need the same test double, promote it to an exported helper in a dedicated test utilities file or package. Do not duplicate stubs across modules.
- When adding a method to an interface, never just add a no-op stub to make the build pass. The new method exists because something calls it — write a test that exercises that call site through the real implementation. A stub that compiles but never runs is not test coverage.
- When fixing an error-handling gap, search for ALL call sites of the affected function — apply the fix everywhere, not just the first site found. Needing the same fix in multiple places is symptomatic of forked logic; extract the shared behavior behind a helper function or compose it into a single code path.

## Writing tests

- Each test should include a brief comment stating: what the issue was and how the test proves the fix works. This prevents tests that only test themselves.
- Tests should have a specific feature-based meaning, and shouldn't just be written to be correct (e.g. `assert 1 == true`).
- Do not write tests that assert specific strings or phrases from prompt templates, `.md` files, or test output. String-based assertions are inherently brittle. Tests should verify behavior and functionality, not pin down prose.
- Test effects, not implementation. Never assert on code names, string literals in source, enum member names, or internal structure. Test that the behavior works: calling the function produces the right result, the UI shows the right state, the API returnt he right response. A test that checks "no command starts with 'activate'" is testing how the code looks, not what it does.
- It is a code smell if you are adding many test fixtures that mock a test world. Tests should exercise real-life conditions from the actual production code, not an elaborate fake environment.
- Do not write tests that mock the exact behavior they claim to verify. A test that stubs a callback to return true and then checks the callback was called proves nothing. Tests must exercise the real code path and verify observable outcomes.
- When porting or rewriting functionality to a new language or framework, the existing test suite is the acceptance criteria. Port every existing test — it must fail against stubs, then pass against the new implementation. New code without equivalent test coverage for the behavior it replaces is not complete.

## What to test

- Testing `returncode == 0` is not testing behavior — it only confirms the script didn't crash. Test the actual effect.
- Similarly, testing `result.stdout` reveals nothing but what the logs said. Assert actual file state, data changes, or structured output rather than log strings.
- Regression tests should assert actual state before and after, not just exit codes or stdout. Structure as "record before → run → compare after" with human-readable expected vs actual diffs.
- **Prove causality by isolating the variable.** When a test claims that a specific attribute or property causes a behavior change, it must follow a two-phase structure:
  1. **Base case (without the variable):** Assert the behavior is absent. This establishes that the test fixture alone does not produce the behavior.
  2. **Test case (with the variable):** Add only the variable under test and assert the behavior is now present.

  The delta between these two assertions is the proof. If a test only asserts the end state, it proves nothing — the behavior could be caused by any part of the fixture, not the variable the test claims to be testing. Skip the base case only when the fixture inherently has a single variable (e.g., a pure function with one input, or an element with a single attribute).

  Before modifying existing filters or rules, ensure there are tests documenting WHY they exist so regressions are caught. Tests should explain the reasoning behind each rule (e.g., "elementsFromPoint filters popups — this test proves it"), not just assert behavior.

## Test granularity

- Unit tests are the building block — prefer them for verifying logic. Integration/end-to-end tests are expensive and should only run when significant UI changes have been made, not as routine verification for non-UI work.
- However, a thin layer of integration tests that step through the main flow end-to-end is essential for detecting regressions that unit tests miss in isolation. These should cover the critical paths through the system — not every edge case, but enough that a broken flow is caught before it ships.

## Running tests

- Don't run the entire suite to validate every change. Run local relevant tests for that module first to avoid time wasted on redundant testing. Only perform a full test suite run if the work is complex or interrelated, or before the final push.
- Always run tests in fast-fail mode with minimal output. Only show output for failing tests — passing test noise wastes context.
- If you cannot visually build and verify (e.g. Xcode projects), include on the PR a test plan checklist that the reviewer may follow to visually verify the changes in the live app.
