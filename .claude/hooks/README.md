# Hooks

Advisory, non-destructive hooks. None of them ever edit source code. They exist to keep codegen and
conventions front-of-mind during AI-assisted development.

## Wired by default (`.claude/settings.json`)

- **`codegen_reminder.sh`** — `PostToolUse` on `Write|Edit`.
  When a Dart file that declares `part '*.g.dart';` or `part '*.freezed.dart';` is written/edited, it
  injects a reminder to run `dart run build_runner build --delete-conflicting-outputs` and commit the
  regenerated files. Non-blocking.

## Available but NOT wired (opt-in)

Add these to `.claude/settings.json` only if you want them. Both are advisory (never block).

- **`pre_commit_checks.sh`** — `PreToolUse` on `Bash` matching `git commit`. Runs `flutter analyze` and
  surfaces the result before committing (does not block the commit).
  ```json
  {
    "hooks": {
      "PreToolUse": [
        {
          "matcher": "Bash",
          "hooks": [
            { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/pre_commit_checks.sh\"" }
          ]
        }
      ]
    }
  }
  ```

- **`validate_conventions.sh`** — a manual, read-only convention scanner (Navigator misuse, raw `Dio()`,
  hardcoded colors, presentation→data imports, impure domain imports). Run it directly:
  ```bash
  bash .claude/hooks/validate_conventions.sh
  ```
  It reports possible violations; some hits may be in pre-existing files you shouldn't touch — **do not**
  refactor those.

## Design principles
- **Never modify code.** Hooks only read and report.
- **Never hard-block** normal workflow — everything exits 0 and is advisory.
- Keep them portable (bash + optional `python3`, no `jq` dependency).
