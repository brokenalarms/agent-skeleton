#!/usr/bin/env bash
# Sync with remote, push local commits, wait for CI version tag.
# Generic version — projects hook into this via ralph:verify and ralph:post-task
# npm scripts (or Makefile targets) which ralph calls after sync completes.
set -euo pipefail

root="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)"

if ! git -C "$root" diff --quiet || ! git -C "$root" diff --cached --quiet; then
  echo "[sync] Uncommitted changes — commit or stash before syncing" >&2
  exit 1
fi

echo "[sync] Pulling latest..."
if ! git -C "$root" pull --rebase 2>&1; then
  echo "[sync] Pull --rebase failed" >&2
  exit 1
fi

pushed=false
ahead=$(git -C "$root" rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
if [ "$ahead" != "0" ]; then
  echo "[sync] Pushing $ahead commit(s)..."
  if ! git -C "$root" push 2>&1; then
    echo "[sync] Push failed" >&2
    exit 1
  fi
  pushed=true
fi

old_tag=$(git -C "$root" describe --tags --match 'v[0-9]*.[0-9]*.[0-9]*' --abbrev=0 2>/dev/null || echo "none")
new_tag="$old_tag"
if [ "$pushed" = true ]; then
  echo -n "[sync] Waiting for version tag (current: $old_tag)"
  delay=1
  for i in 1 2 3 4 5 6 7; do
    git -C "$root" fetch --tags --quiet 2>/dev/null || true
    new_tag=$(git -C "$root" describe --tags --match 'v[0-9]*.[0-9]*.[0-9]*' --abbrev=0 2>/dev/null || echo "none")
    if [ "$new_tag" != "$old_tag" ]; then
      echo " → $new_tag"
      break
    fi
    if [ "$i" -lt 7 ]; then
      echo -n "."
      sleep "$delay"
      delay=$((delay * 2))
    else
      echo " (timed out, using $old_tag)"
      new_tag="$old_tag"
    fi
  done
fi

# Export for downstream scripts
export PROJECT_VERSION="${new_tag#v}"
export PROJECT_BUILD_NUMBER="$(git -C "$root" rev-list --count HEAD)"
echo "[sync] Version: $PROJECT_VERSION ($PROJECT_BUILD_NUMBER)"
