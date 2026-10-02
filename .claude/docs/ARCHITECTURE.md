# Architecture Guide

This document expands on `CLAUDE.md` §1–§4. It describes the **standard architecture for every
data-driven feature** — Clean Architecture (Presentation → Domain → Data) — with a full worked example.

> Placeholders: `<app_name>` is the project's package name from `pubspec.yaml`; `<Feature>`/`<feature>`
> and `<Entity>`/`<Name>` are substituted per feature. When joining an existing codebase, reuse the
> `core/` primitives already present and match the surrounding style.

---

## 1. The dependency rule

```
Presentation  ──▶  Domain  ◀──  Data
```

- **Presentation** (`presentation/` = `logic/` + `ui/`): Cubit, freezed State, Screen, widgets.
  Depends **only** on Domain (use cases + entities). Never imports anything from `data/`.
- **Domain** (`domain/`): pure Dart. Entities, abstract repository interfaces, use cases.
  Depends on nothing but `core/` primitives (e.g. `ApiResult`).
- **Data** (`data/`): models (DTOs), datasources (Retrofit/local), mappers, repository **implementations**.
  Depends on Domain (to implement its contracts) and on `core/networking`.

**Simple / presentation-only features** (static screens, onboarding-style flows with no network or
business logic) may skip Domain and Data, using just `ui/` (+ `widgets/`) and an optional `logic/` Cubit.
Everything that fetches or mutates data uses all three layers.

---

## 2. Folder skeleton for a new feature `<feature>`

```
features/<feature>/
├── data/
│   ├── models/         <feature>_request_body.dart, <feature>_response_model.dart   (@JsonSerializable)
│   ├── datasources/    <feature>_api_service.dart (@RestApi) + <feature>_api_constants.dart
│   ├── mappers/        <feature>_mapper.dart      (model → entity)
│   └── repos/          <feature>_repo_impl.dart   (implements domain <Feature>Repo)
├── domain/
│   ├── entities/       <entity>.dart      (plain class, no annotations)
│   ├── repos/          <feature>_repo.dart        (abstract interface)
│   └── usecases/       get_<feature>_use_case.dart
└── presentation/
    ├── logic/          <feature>_cubit.dart, <feature>_state.dart (@freezed)
    └── ui/             <feature>_screen.dart, widgets/
```

### Dependency wiring (`setupGetIt`)
```dart
// data source (Retrofit)
getIt.registerLazySingleton<<Feature>ApiService>(() => <Feature>ApiService(dio));
// repo implementation bound to the domain interface
getIt.registerLazySingleton<<Feature>Repo>(() => <Feature>RepoImpl(getIt()));
// use case depends on the domain interface
getIt.registerLazySingleton<Get<Feature>UseCase>(() => Get<Feature>UseCase(getIt()));
// cubit depends on the use case(s)
getIt.registerFactory<<Feature>Cubit>(() => <Feature>Cubit(getIt()));
```

---

## 3. Worked example (Clean Architecture)

Substitute `<Feature>`/`<Entity>`/`<Name>` for your feature. The shapes below are the pattern to follow.

### Domain: entity
```dart
// features/<feature>/domain/entities/<entity>.dart
class <Entity> {
  final int id;
  final String name;
  final String? photo;
  final int price;

  const <Entity>({
    required this.id,
    required this.name,
    this.photo,
    required this.price,
  });
}
```

### Domain: repository interface
```dart
// features/<feature>/domain/repos/<feature>_repo.dart
import 'package:<app_name>/core/networking/api_result.dart';
import '../entities/<entity>.dart';

abstract class <Feature>Repo {
  Future<ApiResult<List<<Entity>>>> get<Feature>({required int id});
}
```

### Domain: use case
```dart
// features/<feature>/domain/usecases/get_<feature>_use_case.dart
import 'package:<app_name>/core/networking/api_result.dart';
import '../entities/<entity>.dart';
import '../repos/<feature>_repo.dart';

class Get<Feature>UseCase {
  final <Feature>Repo _repo;
  Get<Feature>UseCase(this._repo);

  Future<ApiResult<List<<Entity>>>> call({required int id}) =>
      _repo.get<Feature>(id: id);
}
```

### Data: model (DTO)
```dart
// features/<feature>/data/models/<name>_model.dart
import 'package:json_annotation/json_annotation.dart';
part '<name>_model.g.dart';

@JsonSerializable()
class <Name>Model {
  final int? id;
  final String? name;
  final String? photo;
  @JsonKey(name: 'server_price_key')
  final int? price;

  <Name>Model({this.id, this.name, this.photo, this.price});

  factory <Name>Model.fromJson(Map<String, dynamic> json) => _$<Name>ModelFromJson(json);
}
```

### Data: datasource (Retrofit)
```dart
// features/<feature>/data/datasources/<feature>_api_service.dart
import 'package:dio/dio.dart';
import 'package:<app_name>/core/networking/api_constants.dart';
import 'package:retrofit/retrofit.dart';
import '../models/<name>_model.dart';
import '<feature>_api_constants.dart';

part '<feature>_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.apiBaseUrl)
abstract class <Feature>ApiService {
  factory <Feature>ApiService(Dio dio) = _<Feature>ApiService;

  @GET(<Feature>ApiConstants.<name>EP)
  Future<List<<Name>Model>> get<Feature>(@Query('id') int id);
}
```

### Data: mapper
```dart
// features/<feature>/data/mappers/<name>_mapper.dart
import '../../domain/entities/<entity>.dart';
import '../models/<name>_model.dart';

extension <Name>Mapper on <Name>Model {
  <Entity> toEntity() => <Entity>(
        id: id ?? 0,
        name: name ?? '',
        photo: photo,
        price: price ?? 0,
      );
}
```

### Data: repository implementation
```dart
// features/<feature>/data/repos/<feature>_repo_impl.dart
import 'package:<app_name>/core/networking/api_error_handler.dart';
import 'package:<app_name>/core/networking/api_result.dart';
import '../../domain/entities/<entity>.dart';
import '../../domain/repos/<feature>_repo.dart';
import '../datasources/<feature>_api_service.dart';
import '../mappers/<name>_mapper.dart';

class <Feature>RepoImpl implements <Feature>Repo {
  final <Feature>ApiService _apiService;
  <Feature>RepoImpl(this._apiService);

  @override
  Future<ApiResult<List<<Entity>>>> get<Feature>({required int id}) async {
    try {
      final response = await _apiService.get<Feature>(id);
      final items = response.map((m) => m.toEntity()).toList();
      return ApiResult.success(items);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
```

### Presentation: state + cubit
```dart
// features/<feature>/presentation/logic/<feature>_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/<entity>.dart';
part '<feature>_state.freezed.dart';

@freezed
class <Feature>State with _$<Feature>State {
  const factory <Feature>State.initial() = _Initial;
  const factory <Feature>State.loading() = Loading;
  const factory <Feature>State.success(List<<Entity>> items) = Success;
  const factory <Feature>State.error({required String message}) = Error;
}
```
```dart
// features/<feature>/presentation/logic/<feature>_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_<feature>_use_case.dart';
import '<feature>_state.dart';

class <Feature>Cubit extends Cubit<<Feature>State> {
  final Get<Feature>UseCase _get<Feature>;
  <Feature>Cubit(this._get<Feature>) : super(const <Feature>State.initial());

  void get<Feature>(int id) async {
    emit(const <Feature>State.loading());
    final result = await _get<Feature>(id: id);
    result.when(
      success: (items) => emit(<Feature>State.success(items)),
      failure: (error) => emit(<Feature>State.error(message: error.apiErrorModel.message ?? '')),
    );
  }
}
```

The UI layer (screen, widgets, `BlocBuilder`/`BlocListener`) follows §5 of `CLAUDE.md` and the
`create-screen` / `create-bloc-listener` skills.

---

## 4. Layer boundary checklist (every data-driven feature)

- [ ] `presentation/` imports only `domain/` (+ `core/`), never `data/`.
- [ ] `domain/` imports only `core/` (e.g. `ApiResult`); no Dio, no Retrofit, no json_annotation, no Flutter.
- [ ] Entities are plain Dart with no `@JsonSerializable` / `fromJson`.
- [ ] `data/repos/*_repo_impl.dart` `implements` the `domain/repos/*_repo.dart` interface.
- [ ] Mapping model → entity happens in the repo impl (via a mapper), not in the Cubit or UI.
- [ ] Use cases are one-action classes returning `ApiResult<Entity>`.
- [ ] Everything registered in `setupGetIt()`; route + `BlocProvider` added to `AppRouter`.
- [ ] `build_runner` run; generated files committed.
