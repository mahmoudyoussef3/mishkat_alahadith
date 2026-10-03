# Checklists

Copy the relevant block into your working notes and tick each item.

---

## New feature (Clean Architecture)
- [ ] Folder skeleton: `data/{models,datasources,mappers,repos}`, `domain/{entities,repos,usecases}`, `presentation/{logic,ui/widgets}`
- [ ] Models `@JsonSerializable` (+ `@JsonKey` where needed), nullable response fields
- [ ] Retrofit datasource `@RestApi(baseUrl: ApiConstants.apiBaseUrl)` + `*ApiConstants` paths
- [ ] Entities are plain Dart (no annotations)
- [ ] `domain/repos/*_repo.dart` abstract interface returns `Future<ApiResult<Entity>>`
- [ ] Mapper `Model.toEntity()`
- [ ] `data/repos/*_repo_impl.dart implements` the interface; try/catch → `ApiResult` (+ mapping)
- [ ] Use cases: one action each, return `ApiResult<Entity>`
- [ ] `@freezed` State (`initial/loading/success/error` or multi-concern)
- [ ] Cubit injects use case(s), emits via `result.when(...)`
- [ ] Screen + small widgets; `BlocBuilder`(`buildWhen`) + `*_bloc_listener.dart`(`listenWhen`)
- [ ] DI: datasource, repo impl (bound to interface), use cases, cubit registered
- [ ] Route constant + `AppRouter` case + `BlocProvider`
- [ ] `presentation/` imports no `data/`; `domain/` imports no Flutter/Dio/Retrofit
- [ ] `build_runner` run; generated files committed
- [ ] `flutter analyze` clean; app runs

## API call added
- [ ] Endpoint path in `*ApiConstants`
- [ ] Method on Retrofit service (`@GET/@POST`, `@Body/@Query/@Path`)
- [ ] Request/response models added if needed
- [ ] Repo method returns `ApiResult<T>` (try/catch)
- [ ] `build_runner` run
- [ ] Cubit consumes it and emits states

## Model added/changed
- [ ] `@JsonSerializable()` + `part '*.g.dart';`
- [ ] `fromJson` (response) / `toJson` (request body)
- [ ] `@JsonKey(name:)` for server key mismatches
- [ ] `build_runner` run; `.g.dart` committed
- [ ] Entity + mapper updated

## Cubit + State
- [ ] `@freezed` state with `part '*.freezed.dart';`
- [ ] Cubit `extends Cubit<State>`, injects dependency, `super(const State.initial())`
- [ ] Owns controllers + `formKey` if it's a form
- [ ] `emit(loading)` → call → `when(success:, failure:)`
- [ ] `build_runner` run
- [ ] Provided via `BlocProvider` / registered in DI

## Screen / widget
- [ ] `Scaffold` → `SafeArea` → padded with `.w/.h`
- [ ] Decomposed into `ui/widgets/`
- [ ] Colors `ColorsManager`, text `TextStyles`, spacing helpers, ScreenUtil sizes
- [ ] Reuse `AppTextButton` / `AppTextFormField`
- [ ] `BlocBuilder`(`buildWhen`) / `BlocListener`(`listenWhen`) wired
- [ ] Navigation via `context` extension + `Routes`
- [ ] `const` where possible; controllers disposed

## Pre-commit / Pre-PR
- [ ] `build_runner` run if annotated files changed (generated files staged)
- [ ] `flutter analyze` → 0 new issues
- [ ] `dart format` on touched files only
- [ ] No existing files refactored/renamed/moved unintentionally
- [ ] No new state-mgmt/DI/networking libraries introduced
- [ ] PR scoped to one feature/fix, targeting the integration branch
