---
description: Clean the build and regenerate all codegen output from scratch.
---

Perform a clean regeneration of generated code for this project.

1. `dart run build_runner clean`
2. `flutter clean`
3. `flutter pub get`
4. `dart run build_runner build --delete-conflicting-outputs`
5. `flutter analyze`

Report each step's outcome and any files that changed. Use this when codegen is in a bad/stale state.
Never hand-edit generated files.

$ARGUMENTS
