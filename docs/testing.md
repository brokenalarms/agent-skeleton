# Testing

## Core principles

- At the start of a task, it is always your responsibility to fix broken tests. You should never say "this test is not related to our work, so we'll leave it." Fix it.
- If you are working on something that can be built or run in the environment, a commit should not be made with the build in a broken state; all tests should pass and the build should work.
- Tests should not be updated to cater to broken behavior, unless we are specifically using TDD (break test first, confirm expected failure, then write the feature to fix it).
- Every commit that changes code for a feature or bug fix must be backed by a test covering that change. Exceptions: animations, purely visual changes, and other inherently UI-based fixes that can't be meaningfully asserted in a test.
- When you change something, clean up after yourself. Do not leave dead code with a comment like "this isn't being used anymore but it's harmless." Remove it.

## Writing tests

- Each test should include a brief comment stating: what the issue was and how the test proves the fix works. This prevents tests that only test themselves.
- Tests should have a specific feature-based meaning, and shouldn't just be written to be correct (e.g. `assert 1 == true`).
- Do not write tests that assert specific strings or phrases from prompt templates, `.md` files, or test output. String-based assertions are inherently brittle. Tests should verify behavior and functionality, not pin down prose.
- It is a code smell if you are adding many test fixtures that mock a test world. Tests should exercise real-life conditions from the actual production code, not an elaborate fake environment.

## What to test

- Testing `returncode == 0` is not testing behavior — it only confirms the script didn't crash. Test the actual effect.
- Similarly, testing `result.stdout` reveals nothing but what the logs said. Assert actual file state, data changes, or structured output rather than log strings.
- Regression tests should assert actual state before and after, not just exit codes or stdout. Structure as "record before → run → compare after" with human-readable expected vs actual diffs.

## Running tests

- Don't run the entire suite to validate every change. Run local relevant tests for that module first to avoid time wasted on redundant testing. Only perform a full test suite run if the work is complex or interrelated, or before the final push.
- If you cannot visually build and verify (e.g. Xcode projects), include on the PR a test plan checklist that the reviewer may follow to visually verify the changes in the live app.
