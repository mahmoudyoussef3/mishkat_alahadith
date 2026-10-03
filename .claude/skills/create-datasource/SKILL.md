---
name: create-datasource
description: Create a data source for a feature — a remote Retrofit source (@RestApi) and/or a local source over SharedPrefHelper. Use when the data layer needs a source abstraction.
---

# create-datasource

The primary data source is a **remote Retrofit service**. A local source (over `SharedPrefHelper`) is
optional and only added when a feature caches/persists data.

## Remote source (Retrofit) — `data/datasources/<f>_api_service.dart`
Same as the `create-retrofit-api` skill:
```dart
part '<f>_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.apiBaseUrl)
abstract class <Feature>ApiService {
  factory <Feature>ApiService(Dio dio) = _<Feature>ApiService;

  @GET(<Feature>ApiConstants.<name>EP)
  Future<<Feature>ResponseModel> get<Feature>();
}
```
Register: `getIt.registerLazySingleton<<Feature>ApiService>(() => <Feature>ApiService(dio));`

## Local source (optional) — `data/datasources/<f>_local_data_source.dart`
Wrap `SharedPrefHelper` (secure storage for sensitive data). Keep keys in `SharedPrefKeys`.
```dart
class <Feature>LocalDataSource {
  Future<void> cacheToken(String token) =>
      SharedPrefHelper.setSecuredString(SharedPrefKeys.userToken, token);

  Future<String> getToken() =>
      SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
}
```
Register: `getIt.registerLazySingleton<<Feature>LocalDataSource>(() => <Feature>LocalDataSource());`

## How it's used
The repo implementation depends on the datasource(s), calls them, maps model → entity, and wraps in
`ApiResult`. The datasource itself does not build `ApiResult` — it just returns raw models / values.

## Guardrails
- One Dio via `DioFactory` (already created in `setupGetIt`); never `Dio()` here.
- Secure storage for tokens/PII; plain `SharedPreferences` for non-sensitive prefs.
- Run `build_runner` after adding the Retrofit source.
- Datasources don't do error mapping or business logic — that's the repo's job.
