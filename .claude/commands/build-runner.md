---
description: Run build_runner code generation (freezed/json/retrofit) and report analyzer status.
---

Run Dart code generation for this project and report the outcome.

1. Run: `dart run build_runner build --delete-conflicting-outputs`
2. If it fails, follow the recovery steps in the `run-build-runner` skill
   (`flutter pub get` → rebuild → `build_runner clean` → `flutter clean && flutter pub get`).
3. After a successful build, run `flutter analyze` and summarize any new issues.
4. Report which generated files changed. Never hand-edit generated files.

$ARGUMENTS
