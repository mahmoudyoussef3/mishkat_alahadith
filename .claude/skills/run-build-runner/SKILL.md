---
name: run-build-runner
description: Run Dart code generation (build_runner) for freezed / json_serializable / retrofit, and fix common generation failures. Use after editing any annotated file.
---

# run-build-runner

Regenerates `*.g.dart` (json/retrofit) and `*.freezed.dart` (freezed) files.

## When to run
After creating or editing any file that declares:
- `part '*.g.dart';` with `@JsonSerializable` or `@RestApi`, or
- `part '*.freezed.dart';` with `@freezed` (states, `ApiResult`).

## Commands
```bash
# one-off
dart run build_runner build --delete-conflicting-outputs

# watch mode while developing
dart run build_runner watch --delete-conflicting-outputs
```

## If it fails
1. `flutter pub get`
2. Re-run the build command.
3. Stale/conflicting output: `dart run build_runner clean` then rebuild.
4. Still failing: `flutter clean && flutter pub get`, then rebuild.
5. Read the analyzer message — most failures are:
   - a missing `part '...';` directive,
   - a wrong/missing annotation,
   - a non-nullable field without a default when deserializing,
   - a typo in a `@JsonKey(name:)`.

## After a successful build
```bash
flutter analyze
```
Confirm 0 new issues, then stage the regenerated files with their source.

## Guardrails
- Never hand-edit generated files.
- Generated files are committed to the repo — commit them together with the source change.
- Fix generation only by correcting the source annotation/part directive, keeping changes minimal.
