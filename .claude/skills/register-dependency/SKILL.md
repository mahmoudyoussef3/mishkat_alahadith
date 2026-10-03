---
name: register-dependency
description: Register a service, repository, use case, or cubit in get_it (setupGetIt), choosing the correct lifetime. Use when wiring dependency injection for new code.
---

# register-dependency

Adds registrations to `core/di/dependency_injection.dart` following `CLAUDE.md` §12. Keep edits additive
and grouped by feature, matching the existing comment layout.

## Lifetimes
- `registerLazySingleton<T>` — ApiServices, repos/repo-impls, use cases, datasources (single shared instance).
- `registerFactory<T>` — Cubits (fresh instance per screen/BlocProvider).

## Feature block template (append inside `setupGetIt()`)
```dart
// <feature>
getIt.registerLazySingleton<<Feature>ApiService>(() => <Feature>ApiService(dio));
getIt.registerLazySingleton<<Feature>Repo>(() => <Feature>RepoImpl(getIt()));   // bind impl to interface
getIt.registerLazySingleton<Get<Feature>UseCase>(() => Get<Feature>UseCase(getIt()));
getIt.registerFactory<<Feature>Cubit>(() => <Feature>Cubit(getIt()));
```
`getIt()` resolves constructor dependencies automatically by type.

## Lighter variant (no domain layer)
```dart
getIt.registerLazySingleton<<Feature>Repo>(() => <Feature>Repo(getIt()));
getIt.registerFactory<<Feature>Cubit>(() => <Feature>Cubit(getIt()));
```

## Notes
- The shared `dio` is created once at the top of `setupGetIt()` via `DioFactory.getDio()`. Reuse that
  variable when registering ApiServices.
- Some cubits are built inline in `AppRouter` (`<Feature>Cubit(getIt())..init()`) instead of being
  registered — that's an accepted pattern; follow the architect's/feature's choice.
- Resolve where you need it: `getIt<<Feature>Cubit>()` (usually inside a `BlocProvider` in `AppRouter`).

## Guardrails
- Register the type against its **interface** when one exists.
- Don't introduce new DI/service-locator libraries — get_it only.
- Only edit `dependency_injection.dart`; don't touch unrelated files.
