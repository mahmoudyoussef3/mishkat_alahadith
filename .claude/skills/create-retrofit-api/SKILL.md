---
name: create-retrofit-api
description: Create or extend a Retrofit @RestApi service and its endpoint constants. Use when adding an HTTP endpoint or a new API service to a feature.
---

# create-retrofit-api

Adds a Retrofit service and endpoint constants following `CLAUDE.md` §6.
`<app_name>` = the project's package name from `pubspec.yaml`.

## 1. Endpoint constants
Feature-level — `features/<f>/data/datasources/<f>_api_constants.dart`:
```dart
class <Feature>ApiConstants {
  static const String <name>EP = '<relative/path>';
}
```
Shared/auth endpoints go in `core/networking/api_constants.dart` (`ApiConstants`). Base URL is always
`ApiConstants.apiBaseUrl`.

## 2. Retrofit service
`features/<f>/data/datasources/<f>_api_service.dart`
```dart
import 'package:dio/dio.dart';
import 'package:<app_name>/core/networking/api_constants.dart';
import 'package:retrofit/retrofit.dart';
import '../models/<f>_response_model.dart';
import '<f>_api_constants.dart';

part '<f>_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.apiBaseUrl)
abstract class <Feature>ApiService {
  factory <Feature>ApiService(Dio dio) = _<Feature>ApiService;

  @GET(<Feature>ApiConstants.<name>EP)
  Future<<Feature>ResponseModel> get<Feature>();

  // @POST(<Feature>ApiConstants.<name>EP)
  // Future<<Feature>Response> create<Feature>(@Body() <Feature>RequestBody body);

  // @GET(<Feature>ApiConstants.<name>EP)
  // Future<T> getById(@Query('id') int id);   // or @Path for path params
}
```

## 3. Register in DI
```dart
getIt.registerLazySingleton<<Feature>ApiService>(() => <Feature>ApiService(dio));
```
Use the shared `dio` already created in `setupGetIt()` via `DioFactory.getDio()`.

## 4. Generate
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Guardrails
- `factory X(Dio dio) = _X;` and `part 'x_api_service.g.dart';` are required.
- Use `@Body()` for bodies, `@Query()`/`@Path()` for params. Endpoint strings only from `*ApiConstants`.
- Never construct `Dio()` yourself — always the shared instance from `DioFactory`.
- Central/shared calls (e.g. auth) belong in `core/networking/api_service.dart`.
- Never hand-edit the generated `.g.dart`.
