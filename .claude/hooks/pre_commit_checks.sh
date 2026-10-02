#!/usr/bin/env bash
# PreToolUse hook (Bash, matched to `git commit`) — Flutter Engineering Playbook
# Advisory only: runs `flutter analyze` and surfaces the result before a commit. Never blocks the
# commit (always exits 0). Enable by wiring it in .claude/settings.json (see .claude/hooks/README.md).

set -uo pipefail

# Only act on git commit commands.
payload="$(cat 2>/dev/null || true)"
cmd=""
if command -v python3 >/dev/null 2>&1; then
  cmd="$(printf '%s' "$payload" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    print((data.get("tool_input", {}) or {}).get("command", "") or "")
except Exception:
    print("")
' 2>/dev/null || true)"
else
  cmd="$(printf '%s' "$payload" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
fi

case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

if command -v flutter >/dev/null 2>&1; then
  if flutter analyze >/tmp/flutter_analyze.txt 2>&1; then
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"Pre-commit: flutter analyze passed."}}\n'
  else
    tail_out="$(tail -n 20 /tmp/flutter_analyze.txt | tr '\n' ' ' | tr '"' "'")"
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"Pre-commit WARNING: flutter analyze reported issues (commit not blocked). Last lines: %s"}}\n' "$tail_out"
  fi
fi

exit 0
