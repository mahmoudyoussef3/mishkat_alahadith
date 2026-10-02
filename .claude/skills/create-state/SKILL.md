---
name: create-state
description: Create a freezed state union for a Cubit, in either the auth/simple style (generic success) or the multi-concern typed style. Use when you need just the state class.
---

# create-state

Generates a `@freezed` state file matching `CLAUDE.md` §5. `<app_name>` = the project's package name.

## Simple / auth style (generic success payload)
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part '<feature>_state.freezed.dart';

@freezed
class <Feature>State<T> with _$<Feature>State<T> {
  const factory <Feature>State.initial() = _Initial;
  const factory <Feature>State.loading() = Loading;
  const factory <Feature>State.success(T data) = Success<T>;
  const factory <Feature>State.error({required String error}) = Error;
}
```

## Multi-concern style (explicit typed factories, prefixed names)
Use when one cubit drives several independent UI regions.
```dart
import 'package:<app_name>/core/networking/api_error_handler.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '<feature>_state.freezed.dart';

@freezed
class <Feature>State with _$<Feature>State {
  const factory <Feature>State.initial() = _Initial;

  const factory <Feature>State.<a>Loading() = <A>Loading;
  const factory <Feature>State.<a>Success(<TypeA> data) = <A>Success;
  const factory <Feature>State.<a>Error(ErrorHandler errorHandler) = <A>Error;

  const factory <Feature>State.<b>Success(<TypeB> data) = <B>Success;
  const factory <Feature>State.<b>Error(ErrorHandler errorHandler) = <B>Error;
}
```

## After creating
```bash
dart run build_runner build --delete-conflicting-outputs
```
- Filter rebuilds/listens with `buildWhen`/`listenWhen` against the named subclasses
  (`current is <A>Loading || current is <A>Success ...`).
- Use `maybeWhen(..., orElse: () => const SizedBox.shrink())` in builders and `whenOrNull(...)` in listeners.

## Guardrails
- Keep `part '<feature>_state.freezed.dart';` present. Never edit the generated file.
- For data-driven features, the success payload type should be a **domain entity**, not a network model.
