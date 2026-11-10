#!/bin/sh
# Claude Code SessionStart hook (matcher: resume).
# When a session is resumed inside a herdr pane (herdr restore after a server
# restart, or a manual --resume/--continue), queue a /compact once the agent is
# idle. Runs detached so the hook itself returns immediately.
set -eu

cat >/dev/null 2>&1 || true   # drain hook JSON on stdin

[ "${HERDR_ENV:-}" = 1 ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v herdr >/dev/null 2>&1 || exit 0

pane="$HERDR_PANE_ID"
job='sleep 3
herdr agent wait "$1" --timeout 120000 >/dev/null 2>&1 || exit 0
herdr agent prompt "$1" "/compact" >/dev/null 2>&1 || exit 0'

if command -v setsid >/dev/null 2>&1; then
  setsid -f sh -c "$job" sh "$pane" </dev/null >/dev/null 2>&1
else
  nohup sh -c "$job" sh "$pane" </dev/null >/dev/null 2>&1 &
fi
exit 0
