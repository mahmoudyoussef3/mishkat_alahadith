#!/usr/bin/env bash
# PostToolUse hook (Write|Edit) — Flutter Engineering Playbook
# Advisory only: if an edited Dart file needs code generation (freezed / json_serializable /
# retrofit), inject a reminder to run build_runner. Never blocks, never edits anything.

set -euo pipefail

# Read the hook payload from stdin.
payload="$(cat 2>/dev/null || true)"

# Extract tool_input.file_path without requiring jq.
file_path=""
if command -v python3 >/dev/null 2>&1; then
  file_path="$(printf '%s' "$payload" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    ti = data.get("tool_input", {}) or {}
    print(ti.get("file_path", "") or "")
except Exception:
    print("")
' 2>/dev/null || true)"
else
  # Fallback: grab the first file_path string from the JSON.
  file_path="$(printf '%s' "$payload" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
fi

# Only care about Dart source files.
case "$file_path" in
  *.dart) ;;
  *) exit 0 ;;
esac

# Skip generated files themselves.
case "$file_path" in
  *.g.dart|*.freezed.dart) exit 0 ;;
esac

[ -f "$file_path" ] || exit 0

# Does the file declare a generated part that needs build_runner?
if grep -Eq "part '.*\.(g|freezed)\.dart';" "$file_path" 2>/dev/null; then
  msg="Reminder: ${file_path} declares a generated part (*.g.dart / *.freezed.dart). Run: dart run build_runner build --delete-conflicting-outputs — and commit the regenerated file(s). Do not hand-edit generated files."
  # Inject as additional context for the model (PostToolUse).
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$msg"
fi

exit 0
