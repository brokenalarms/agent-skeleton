# Committing, branches & pull requests

## Session start — branch check

Before any commit or push action, every session:

1. For new features, always create a worktree. You may have already been invoked in one, but always check first.
2. `git fetch origin main` and check whether your branch has already been squash-merged (see squash-merge detection below).
3. If the branch was squash-merged, it is dead — immediately create a new branch from `origin/main` before touching any files.
4. Never do any work on a branch that was squash-merged; GitHub closes that branch's PR and new commits become inaccessible through it.
5. `git branch -r --merged` does NOT detect squash merges — always use the diff-based method below.
6. You don't need to ask for permission to pull new content in from main and run local git commands, besides final pushes.
7. If you ever need to amend a commit, ALWAYS check first that that commit has not already been pushed, so you don't create a divergence. Create a new commit rather than amend if it has.

## Commits

- Never push to main. Atomic commits comprising a feature should be pushed as a PR from a branch — this is part of considering a task finished. Don't ask, just do it.
- Before every commit, repeat the branch check above — merges can land between commits.
- Commits should be atomic: one feature change or bug fix per commit where possible.
- Every commit message must have a subject line AND a body separated by a blank line — GitHub uses the subject as PR title and body as PR description.
- Commit body: concise bullet list covering **why** (the bug or goal), **how** (the approach), and test coverage. Don't narrate the diff — the reader has it open.
- Related atomic commits may be grouped into a single PR.
- Every commit that changes code for a feature or bug fix must be backed by a test covering that change.
- Never commit without first running tests and confirming they pass.
- After making code changes, commit immediately before running the full test suite. A WIP commit prevents work loss if the process is terminated. If tests fail, fix and commit again — do not amend the previous commit.
- If the dev environment supports it (package.json, Makefile, cargo, xcodegen), run a build to verify compilation before committing, and make sure that any auto-generated project files (e.g., .xcodeproj) are up to date with the changes.
- One branch per PR — never reuse a branch that has already been merged into main; create a new branch for each new PR. Multiple commits on the same session branch are fine as long as they belong to the same open PR.

## Rebasing

Before you push, you must rebase onto the latest main:
1. `git fetch origin main`
2. `git rebase --update-refs origin/main`
3. If step 2 conflicts because a base branch was squash-merged, abort and use: `git rebase --update-refs --onto origin/main <squash-merged-branch> HEAD` where `<squash-merged-branch>` is the branch ref that was already merged. This skips the duplicate commits. Then delete the merged branch ref.

Always use `--update-refs` to keep stacked branch pointers correct.

## Pull requests

### Squash-merge detection

A squash-merge collapses all branch commits into one commit on main. `git branch -r --merged` will NOT detect this because the branch commits themselves never appear in main's history.

To detect whether your branch was squash-merged, use a diff:

1. `git fetch origin main`
2. `git diff origin/main...HEAD --stat` — if this shows no changes (empty diff), then all the branch's work is already in main via a squash merge.
3. If the diff is empty, the branch is dead. Create a new branch from `origin/main`, cherry-pick any new commits onto it, push, and create a fresh PR.
4. Never push new commits to a branch whose PR was already squash-merged.

### Creating the PR

- Every time before you create a PR, you will need to pull in the latest from main, and check that the branch was not already merged. If so, this branch is dead, and you shouldn't just push the latest to the PR-merged branch, but create a new branch and PR.
- After pushing, always create the PR with `gh pr create` — this supports full markdown bodies without URL-encoding issues.
- PR title and body follow the same format as commit messages: imperative title (lowercase, no period), concise bullet-list body covering **why**, **how**, and test coverage.
- The PR description should encapsulate the sum of all commits in the PR, not repeat each one individually.
- If subsequent commits are added to a PR, update the PR title/body with `gh pr edit` to reflect the full scope of changes.
- It is up to the user to work through stacks and merge them. Never merge a PR to main without asking first.
- If making any visual changes, wherever possible, try to use Playwright or similar to screenshot the changes and add them to the description of the PR

### Keeping PRs up to date

After every push to a PR branch, check whether GitHub reports conflicts or the branch is behind main. If so, rebase and force-push:

1. `git fetch origin main`
2. `git rebase origin/main` (or `--update-refs` for stacked branches)
3. `git push --force-with-lease`

This is equivalent to clicking GitHub's "Update branch" button but uses rebase instead of merge. You can also do it via the API: `gh api repos/OWNER/REPO/pulls/NUMBER/update-branch -X PUT -f update_method=rebase`. Do this proactively after every push — don't wait for merge conflicts to be reported.
