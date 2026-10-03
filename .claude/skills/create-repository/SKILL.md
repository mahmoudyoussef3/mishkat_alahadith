---
name: create-repository
description: Create a repository that returns ApiResult<T> using the try/catch + ErrorHandler pattern. Creates the domain repo interface and implementation, and maps models to entities. Use when adding data access for a feature.
---

# create-repository

`<app_name>` = the project's package name from `pubspec.yaml`.

## Clean Architecture style (interface + impl + mapping) — the standard
**Domain interface** — `domain/repos/<f>_repo.dart`
```dart
import 'package:<app_name>/core/networking/api_result.dart';
import '../entities/<entity>.dart';

abstract class <Feature>Repo {
  Future<ApiResult<List<<Entity>>>> get<Feature>();
}
```
**Data implementation** — `data/repos/<f>_repo_impl.dart`
```dart
import 'package:<app_name>/core/networking/api_error_handler.dart';
import 'package:<app_name>/core/networking/api_result.dart';
import '../../domain/repos/<f>_repo.dart';

class <Feature>RepoImpl implements <Feature>Repo {
  final <Feature>ApiService _apiService;
  <Feature>RepoImpl(this._apiService);

  @override
  Future<ApiResult<List<<Entity>>>> get<Feature>() async {
    try {
      final response = await _apiService.get<Feature>();
      final entities = (response.dataList ?? [])
          .whereType<<Model>>()
          .map((m) => m.toEntity())
          .toList();
      return ApiResult.success(entities);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
```

## Lighter variant (no domain layer, for simple features)
A single repo class returning `ApiResult<Model>` (no interface, no mapping) is acceptable when a feature
has no domain layer:
```dart
class <Feature>Repo {
  final <Feature>ApiService _apiService;
  <Feature>Repo(this._apiService);

  Future<ApiResult<<Feature>ResponseModel>> get<Feature>() async {
    try {
      final response = await _apiService.get<Feature>();
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
```

## Register in DI
```dart
getIt.registerLazySingleton<<Feature>Repo>(() => <Feature>RepoImpl(getIt()));  // bind impl to interface
getIt.registerLazySingleton<<Feature>Repo>(() => <Feature>Repo(getIt()));      // lighter variant
```

## Guardrails
- Always try/catch → `ApiResult.failure(ErrorHandler.handle(e))`. Repos never throw.
- Keep repos thin: call → (map) → wrap. No UI or business rules.
- Mapping model → entity happens here (via the mapper), not in the Cubit/UI.
- Run `build_runner` if new models/entities were added.
