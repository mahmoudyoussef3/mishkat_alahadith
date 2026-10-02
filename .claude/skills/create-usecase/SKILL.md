---
name: create-usecase
description: Create a single-responsibility use case for a feature's domain layer. It depends on a repo interface and returns ApiResult<Entity>. Use when wiring domain logic between the cubit and the repository.
---

# create-usecase

A use case encapsulates one action. It depends on a **domain repo interface** and returns the shared
`ApiResult<T>` wrapper, where `T` is a domain **entity** (or a list of entities).
`<app_name>` = the project's package name from `pubspec.yaml`.

## Template (`domain/usecases/<verb>_<noun>_use_case.dart`)
```dart
import 'package:<app_name>/core/networking/api_result.dart';
import '../entities/<entity>.dart';
import '../repos/<feature>_repo.dart';

class <Verb><Noun>UseCase {
  final <Feature>Repo _repo;
  <Verb><Noun>UseCase(this._repo);

  Future<ApiResult<List<<Entity>>>> call({required int id}) =>
      _repo.get<Noun>(id: id);
}
```

Using `call(...)` lets the cubit invoke it like a function: `final result = await _get<Noun>(...)`.

## Register in DI
```dart
getIt.registerLazySingleton<<Verb><Noun>UseCase>(() => <Verb><Noun>UseCase(getIt()));
```
The cubit then injects the use case (not the repo): `getIt.registerFactory<<Feature>Cubit>(() => <Feature>Cubit(getIt()));`.

## Guardrails
- One action per use case (`Get<Noun>UseCase`, `LoginUseCase`, …).
- Depends only on the **domain repo interface**, never on the impl or the datasource.
- Returns `ApiResult<Entity>`; no mapping, networking, or UI logic here (that's the repo impl / UI).
- Name `<Verb><Noun>UseCase`; file `snake_case`.
