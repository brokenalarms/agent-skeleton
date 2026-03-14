# Agent Guidelines

## Testing
- You MUST read and follow @docs/testing.md before writing or modifying any tests.

## Committing & Pull Requests
- You MUST read and follow @docs/committing.md before any commit, push, or PR action.

## Development
- You MUST read and follow @docs/developing.md before starting any feature or bug fix work.

## Issue Tracking
- Use BD for issue tracking if installed.

## TODOs & Specs
- Open tasks are maintained at @docs/TODO.md, with larger tasks broken down into their own specifications in @docs/specs/, and previously completed ones in @docs/specs/completed.
- Large tasks in specs/ may not have their own entries in TODO.md, so part of looking for TODOs is checking through specs files as well.
- TODO.md is a sliding context window for fresh agents — open tasks only; completed work belongs in commit messages, not here.
- At the start of each session, in the absence of any specific instruction, read TODO.md.
- At the end of a session, remove any completed tasks from TODO.md and add any newly discovered ones.
- Never add a "Done" section or status reports to TODO.md, and never tick off items versus just removing them. The commit record is the 'Done' record.
