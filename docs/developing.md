# Development

## Bug fixes

When fixing bugs, search for a way to make the fix generic and applicable to new use cases rather than accounting specifically for one scenario. The fix should integrate seamlessly into the existing pipeline, not be a random "if this unique situation then do something completely different" function call.

For bug fix workflow:
1. **Understand the scenario** — identify what's wrong before jumping to a fix.
2. **Verify your understanding** — echo back to the user what you think the issue is and your proposed fix. Do NOT start fixing without verifying; your guess is often wrong.
3. **Write a TDD test first** — add a test that reproduces the bug. Run the test and confirm it fails.
4. **Implement the fix**.
5. **Verify** — run the build and tests, all should pass without modifying the test to fit after the fact.
6. **Review** — is there a better way to integrate this fix generically so it handles a class of issues, not just the specific one at hand?

## Code style

- Prefer declarative structure up front (e.g. a config object, map, or table) that then calls a single utility function, rather than imperative branching logic.
- Use early exits (`guard`, early `return`, `continue`) rather than large nested `if` blocks.
- Prefer functional composition where possible. Avoid over-extraction — don't extract single-line utilities unless the function serves as a source of truth (e.g. a string composition function that defines a canonical format used across the app).
- When moving functions or types to a new file, update all existing import sites to point to the new location. Do not re-export from the old location as a compatibility shim — that creates dead indirection and hides the real dependency graph.
- Small targeted refactors are encouraged as part of a PR if you spot something that would be notably improved, or if changes are becoming increasingly brittle and would benefit from an architectural refactor first.

## Environment awareness

- You may be in a macOS or Linux environment. If commands don't work when you first run them, note which ones work for which environment.
- If you are working on something that can be built or run in the environment, the build must not be broken at commit time. For example, in a macOS environment for an Xcode project, part of allowing a commit would be that the project builds successfully.
