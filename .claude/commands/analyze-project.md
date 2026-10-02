---
description: Run flutter analyze and summarize issues without changing code.
---

Run the static analyzer and report results.

1. Run `flutter analyze`.
2. Group findings by file and severity; summarize the count of errors/warnings/infos.
3. For each actionable issue, note the `file:line` and a suggested fix that matches project conventions.
4. Do NOT auto-fix or reformat existing files. Only report. If the user wants fixes applied, they can ask,
   and fixes must stay surgical and convention-consistent (see the bugfix-engineer agent).

$ARGUMENTS
