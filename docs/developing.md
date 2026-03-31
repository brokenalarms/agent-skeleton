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

## Module encapsulation

Modules are sealed boundaries. Each module exposes public functions that take only what they need as parameters and return results. A module cannot reach back out into the calling context — it has no reference to the orchestrator, no handle to a shared state object, no way to call into other modules unless the orchestrator explicitly passes a dependency as a parameter.

**No god objects.** A struct that holds the world (config, logger, clients, state) and gets passed everywhere is the most common way encapsulation breaks down. When every function is a method on a `Manager` or `Context` that contains everything, any method can call any other method, access any field, and mutate any state. There are no boundaries — it's all `m.something()`. This defeats the purpose of separating code into modules.

The fix is not to pass smaller interfaces of the same god object (that treats the symptom). The fix is:
- **Functions take what they need as parameters.** `Push` doesn't need a Manager — it needs a working directory, a branch name, and a way to run commands. Pass those directly.
- **Functions return results, not side effects.** The caller decides what to do with the result. The function doesn't reach into shared state to record it.
- **Package privacy is the encapsulation boundary.** Private functions within a module compose into public functions. The public functions are the module's API. Nothing outside the module can call the private functions or access private state.
- **State is data that flows through parameters**, not something owned by a struct that everything hangs off of. A thin adapter can hold config and delegate to the module's functions if needed, but the functions themselves don't depend on it.

```
// Wrong: god object where everything can call everything
type Manager struct { workDir, branch string; gh GitHubClient; logger Logger; ... }
func (m *Manager) Ship() { m.Push(); m.CreatePR(); m.AwaitCI() }
func (m *Manager) Push() { m.Rebase(); m.Squash(); m.ForcePush() }

// Right: functions that compose, taking only what they need
func ship(runner CmdRunner, gh GitHubAPI, opts ShipOpts) (ShipResult, error) {
    push(runner, opts.WorkDir, opts.Branch, opts.BaseRef)
    createPR(gh, opts.PRTitle, opts.PRBody)
}
func push(runner CmdRunner, workDir, branch, baseRef string) error {
    rebase(runner, workDir, baseRef)
    squash(runner, workDir, baseRef, branch)
}
```

## Orchestrator pattern

The orchestrator is the only place where modules meet. It sequences named function calls that read as a narrative: init → get task → prepare → execute → verify → finalize. Each step is a call into a module, passing in what it needs, getting back a result.

- **Modules are composed, not connected.** The orchestrator calls module A, takes its result, and passes it to module B. Module A and module B have no knowledge of each other. If they need to interact, the orchestrator mediates.
- **Orchestrators read as narrative.** The top-level function should read top-to-bottom as a story of what happens. Each step is a named function call, not inline logic.
- **Modules own their domains.** No git commands outside the git module. No HTTP calls outside the API module. Domain logic stays in the module that owns it.

## Code style

- Prefer declarative structure up front (e.g. a config object, map, or table) that then calls a single utility function, rather than imperative branching logic.
- Prefer a declarative functional style: build up requirements in a struct through the function lifecycle, then call a single function to produce the result. Avoid imperative mutation scattered through function bodies.
- Use early exits (`guard`, early `return`, `continue`) rather than large nested `if` blocks.
- Functions with 3+ parameters should use a named options struct. No positional string juggling.
- Prefer functional composition where possible. Avoid over-extraction — don't extract single-line utilities unless the function serves as a source of truth (e.g. a string composition function that defines a canonical format used across the app).
- When moving functions or types to a new file, update all existing import sites to point to the new location. Do not re-export from the old location as a compatibility shim — that creates dead indirection and hides the real dependency graph.
- Small targeted refactors are encouraged as part of a PR if you spot something that would be notably improved, or if changes are becoming increasingly brittle and would benefit from an architectural refactor first.
- Single source of truth: flag definitions, log prefixes, prompt templates, config keys — each defined in one place. No duplication across code and config.

## Silent failures

Look for and eliminate: errors swallowed without logging, functions that return nil/null on failure without signaling why, conditions that skip work without explanation. Every error path should either handle the error meaningfully or propagate it — never silently discard it.

## Typing

- Use typed languages and variants from the outset: TypeScript over JavaScript, typed Python (type hints + mypy/pyright), etc.
- When creating new projects or files, always set up the build system to accommodate typing (e.g., `tsconfig.json` for TypeScript, pyproject.toml for Python type-checking).
- If adding code to an existing untyped project, introduce typing incrementally — add types to new files and functions you touch, don't rewrite the whole codebase.
- Prefer strict type-checking settings where the ecosystem supports it (e.g., `"strict": true` in tsconfig).

## Boy Scout Rule

Before committing, glance at the files you touched. If you see something genuinely worth cleaning up, do it:
- Dead code: unused functions, unreachable branches, commented-out code — delete it, git remembers
- Unclear names in code you modified — names should reveal intent
- Files growing past ~500 lines — consider whether they have distinct responsibilities worth splitting

But don't clean up for the sake of it. Don't extract one-line helpers used once. Don't create abstractions for one-time operations. Three similar lines are better than a premature abstraction. If the code reads fine, leave it alone.

## API integration

- Never assume the shape of an API response. Before writing code against a third-party API, make a test call with a real payload and inspect what it actually returns. Do not guess property names, nesting, or the presence of flags — APIs frequently omit fields you'd expect or structure them differently than the docs suggest.

## Environment awareness

- You may be in a macOS or Linux environment. If commands don't work when you first run them, note which ones work for which environment.
- If you are working on something that can be built or run in the environment, the build must not be broken at commit time. For example, in a macOS environment for an Xcode project, part of allowing a commit would be that the project builds successfully.
