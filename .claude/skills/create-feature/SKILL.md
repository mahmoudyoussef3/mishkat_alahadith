---
name: create-feature
description: Scaffold a complete new feature following the playbook's Clean Architecture (Presentation → Domain → Data), including DI registration and routing. Use when asked to add a new feature/module/screen-with-data.
---

# create-feature

Scaffold a full new feature under `lib/features/<name>/` following `.claude/docs/ARCHITECTURE.md`.
Only create new files; make the minimal additions to DI/routing. Never touch unrelated existing code.
First inspect the repo for the package name (`pubspec.yaml`) and existing core primitives.

## Inputs to confirm
- Feature name (snake_case folder, e.g. `profile`).
- Endpoint(s) + HTTP method + request/response shape.
- Whether it needs a form (controllers + formKey in the cubit).

## Steps

1. **Create the skeleton**
```
lib/features/<name>/
├── data/{models,datasources,mappers,repos}/
├── domain/{entities,repos,usecases}/
└── presentation/{logic,ui/widgets}/
```

2. **Data → model** (`data/models/<name>_response_model.dart`)
```dart
import 'package:json_annotation/json_annotation.dart';
part '<name>_response_model.g.dart';

@JsonSerializable()
class <Name>ResponseModel {
  @JsonKey(name: 'data')
  final List<<Name>Data?>? dataList;
  <Name>ResponseModel({this.dataList});
  factory <Name>ResponseModel.fromJson(Map<String, dynamic> json) => _$<Name>ResponseModelFromJson(json);
}
```

3. **Data → datasource** (`data/datasources/<name>_api_service.dart` + `<name>_api_constants.dart`)
```dart
class <Name>ApiConstants { static const String <name>EP = '<endpoint/path>'; }
```
```dart
part '<name>_api_service.g.dart';
@RestApi(baseUrl: ApiConstants.apiBaseUrl)
abstract class <Name>ApiService {
  factory <Name>ApiService(Dio dio) = _<Name>ApiService;
  @GET(<Name>ApiConstants.<name>EP)
  Future<<Name>ResponseModel> get<Name>();
}
```

4. **Domain → entity** (`domain/entities/<name>.dart`) — plain class, no annotations.

5. **Domain → repo interface** (`domain/repos/<name>_repo.dart`)
```dart
abstract class <Name>Repo {
  Future<ApiResult<List<<Name>>>> get<Name>();
}
```

6. **Data → mapper** (`data/mappers/<name>_mapper.dart`)
```dart
extension <Name>Mapper on <Name>Data { <Name> toEntity() => <Name>(...); }
```

7. **Data → repo impl** (`data/repos/<name>_repo_impl.dart`)
```dart
class <Name>RepoImpl implements <Name>Repo {
  final <Name>ApiService _api;
  <Name>RepoImpl(this._api);
  @override
  Future<ApiResult<List<<Name>>>> get<Name>() async {
    try {
      final response = await _api.get<Name>();
      return ApiResult.success((response.dataList ?? []).whereType<<Name>Data>().map((e) => e.toEntity()).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
```

8. **Domain → use case** (`domain/usecases/get_<name>_use_case.dart`)
```dart
class Get<Name>UseCase {
  final <Name>Repo _repo;
  Get<Name>UseCase(this._repo);
  Future<ApiResult<List<<Name>>>> call() => _repo.get<Name>();
}
```

9. **Presentation → state** (`presentation/logic/<name>_state.dart`)
```dart
@freezed
class <Name>State with _$<Name>State {
  const factory <Name>State.initial() = _Initial;
  const factory <Name>State.loading() = Loading;
  const factory <Name>State.success(List<<Name>> items) = Success;
  const factory <Name>State.error({required String message}) = Error;
}
```

10. **Presentation → cubit** (`presentation/logic/<name>_cubit.dart`)
```dart
class <Name>Cubit extends Cubit<<Name>State> {
  final Get<Name>UseCase _get<Name>;
  <Name>Cubit(this._get<Name>) : super(const <Name>State.initial());
  void get<Name>() async {
    emit(const <Name>State.loading());
    final result = await _get<Name>();
    result.when(
      success: (items) => emit(<Name>State.success(items)),
      failure: (e) => emit(<Name>State.error(message: e.apiErrorModel.message ?? '')),
    );
  }
}
```

11. **Presentation → UI** (`presentation/ui/<name>_screen.dart` + `widgets/`): Scaffold/SafeArea,
    `BlocBuilder` with `buildWhen` + `maybeWhen(orElse:)`, plus a `<name>_bloc_listener.dart` for side effects.
    Use `ColorsManager`/`TextStyles`/spacing helpers/ScreenUtil and shared widgets.

12. **DI** — append to `setupGetIt()` in `core/di/dependency_injection.dart`:
```dart
// <name>
getIt.registerLazySingleton<<Name>ApiService>(() => <Name>ApiService(dio));
getIt.registerLazySingleton<<Name>Repo>(() => <Name>RepoImpl(getIt()));
getIt.registerLazySingleton<Get<Name>UseCase>(() => Get<Name>UseCase(getIt()));
getIt.registerFactory<<Name>Cubit>(() => <Name>Cubit(getIt()));
```

13. **Routing** — add `static const String <name>Screen = '/<name>Screen';` to `Routes`, and a case in
    `AppRouter.generateRoute`:
```dart
case Routes.<name>Screen:
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => getIt<<Name>Cubit>()..get<Name>(),
      child: const <Name>Screen(),
    ),
  );
```

14. **Codegen & verify**
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Guardrails
- Presentation never imports `data/`; Domain imports no Flutter/Dio/Retrofit/json; Data implements Domain.
- Reuse `ApiResult`, `ErrorHandler`, `DioFactory`, theming/spacing/extensions, `AppTextButton`/`AppTextFormField`.
- Match naming in `CLAUDE.md` §10. Commit source + generated files together.
