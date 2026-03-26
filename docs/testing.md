# Testing

## Core principles

- At the start of a task, it is always your responsibility to fix broken tests. You should never say "this test is not related to our work, so we'll leave it." Fix it.
- If you are working on something that can be built or run in the environment, a commit should not be made with the build in a broken state; all tests should pass and the build should work.
- Tests should not be updated to cater to broken behavior, unless we are specifically using TDD (break test first, confirm expected failure, then write the feature to fix it).
- Every commit that changes code for a feature or bug fix must be backed by a test covering that change. Exceptions: animations, purely visual changes, and other inherently UI-based fixes that can't be meaningfully asserted in a test.
- When you change something, clean up after yourself. Do not leave dead code with a comment like "this isn't being used anymore but it's harmless." Remove it.
- Never skip a failing test. There is no justification for moving on with a test in a broken state — not scope, not time, not relevance. If a test is failing, fix it before doing anything else. Do not disable it, mark it as expected-failure, or defer it to a follow-up.
- If you can take a human out of the test loop and test changes yourself, so much the better. Use `playwright` or the equivalent for your project to visually verify the changes.

## Writing tests

- Each test should include a brief comment stating: what the issue was and how the test proves the fix works. This prevents tests that only test themselves.
- Tests should have a specific feature-based meaning, and shouldn't just be written to be correct (e.g. `assert 1 == true`).
- Do not write tests that assert specific strings or phrases from prompt templates, `.md` files, or test output. String-based assertions are inherently brittle. Tests should verify behavior and functionality, not pin down prose.
- It is a code smell if you are adding many test fixtures that mock a test world. Tests should exercise real-life conditions from the actual production code, not an elaborate fake environment.

## What to test

- Testing `returncode == 0` is not testing behavior — it only confirms the script didn't crash. Test the actual effect.
- Similarly, testing `result.stdout` reveals nothing but what the logs said. Assert actual file state, data changes, or structured output rather than log strings.
- Regression tests should assert actual state before and after, not just exit codes or stdout. Structure as "record before → run → compare after" with human-readable expected vs actual diffs.
- **Prove causality by isolating the variable.** When a test claims that a specific attribute or property causes a behavior change, it must follow a two-phase structure:
  1. **Base case (without the variable):** Assert the behavior is absent. This establishes that the test fixture alone does not produce the behavior.
  2. **Test case (with the variable):** Add only the variable under test and assert the behavior is now present.

  The delta between these two assertions is the proof. If a test only asserts the end state, it proves nothing — the behavior could be caused by any part of the fixture, not the variable the test claims to be testing. Skip the base case only when the fixture inherently has a single variable (e.g., a pure function with one input, or an element with a single attribute).

  Before modifying existing filters or rules, ensure there are tests documenting WHY they exist so regressions are caught. Tests should explain the reasoning behind each rule (e.g., "elementsFromPoint filters popups — this test proves it"), not just assert behavior.

## Running tests

- Don't run the entire suite to validate every change. Run local relevant tests for that module first to avoid time wasted on redundant testing. Only perform a full test suite run if the work is complex or interrelated, or before the final push.
- If you cannot visually build and verify (e.g. Xcode projects), include on the PR a test plan checklist that the reviewer may follow to visually verify the changes in the live app.
