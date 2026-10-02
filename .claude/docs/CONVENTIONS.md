# Coding Conventions

Quick, enforceable reference. See `CLAUDE.md` for the full rationale. `<app_name>` = the project's
package name from `pubspec.yaml`.

---

## Imports
- Cross-module imports use `package:<app_name>/...` (the package name from `pubspec.yaml`).
- Same-feature sibling files may use **relative** imports (`../../core/...`, `widgets/...`).
- Prefer `package:` imports for `core/` and cross-feature references; relative imports for same-feature
  siblings. When editing an existing file, match that file's existing style.
- Order: Dart SDK → Flutter → third-party packages → project imports. Keep generated `part` directives
  right after imports.

## Naming (see CLAUDE.md §10 for the full table)
- Files/folders `snake_case`; classes/enums `PascalCase`; members `lowerCamelCase`.
- `<Feature>Cubit`, `<Feature>State`, `<Feature>Repo`, `<Feature>ApiService`, `<Name>RequestBody`,
  `<Name>Response`/`<Name>ResponseModel`, `<Feature>Screen`.
- Domain: entities `<Noun>`, use cases `<Verb><Noun>UseCase`, repo impl `<Feature>RepoImpl`.

## Widgets
- Prefer `StatelessWidget`; use `StatefulWidget` only for local UI state (obscure toggles, listeners).
- `const` constructors and `const` widget instances wherever possible.
- One widget per file; decompose screens into `ui/widgets/`.
- Dispose controllers/listeners you own in `dispose()`.

## State management
- Cubit only. States are `@freezed` unions.
- `emit(const State.loading())` before async work; branch results with `.when(success:, failure:)`.
- UI: `BlocBuilder` with `buildWhen` + `maybeWhen(..., orElse: () => const SizedBox.shrink())`.
- Side effects: dedicated `*_bloc_listener.dart` using `listenWhen` + `whenOrNull`, child `const SizedBox.shrink()`.

## Networking
- Retrofit abstract service with `factory X(Dio dio) = _X;` and `part 'x.g.dart';`.
- `@RestApi(baseUrl: ApiConstants.apiBaseUrl)`. Endpoint paths only from `*ApiConstants`.
- Single Dio via `DioFactory`. Never `Dio()` elsewhere.
- Repos return `ApiResult<T>`; wrap calls in try/catch → `ApiResult.failure(ErrorHandler.handle(e))`.

## Models
- `@JsonSerializable()` + `part 'x.g.dart';`. Response = `fromJson`; RequestBody = `toJson`.
- Nullable response fields. `@JsonKey(name:)` for server key mismatches.

## Theming & sizing
- Colors → `ColorsManager`. Text → `TextStyles` (`font<Size><Color><Weight>`, use `.copyWith`).
- Weights → `FontWeightHelper`. Sizes → ScreenUtil `.w/.h/.sp/.r` (design canvas set once, e.g. 375×812).
- Spacing → `verticalSpace(n)` / `horizontalSpace(n)`.
- Reuse `AppTextButton`, `AppTextFormField`. SVG via `SvgPicture.asset`, network images via
  `CachedNetworkImage` + `Shimmer`.

## Navigation
- `context.pushNamed/pushReplacementNamed/pushNamedAndRemoveUntil/pop` (from `extensions.dart`).
- Route names from `Routes`. Register routes in `AppRouter.generateRoute`.

## DI
- `getIt.registerLazySingleton` for services/repos/use cases; `getIt.registerFactory` for cubits.
- Register everything in `setupGetIt()`.

## Validation & helpers
- Use `AppRegex` for email/password/phone checks.
- Use `String?.isNullOrEmpty()` / `List?.isNullOrEmpty()` extensions.
- Token/persistence via `SharedPrefHelper` (secure storage for tokens: `SharedPrefKeys.userToken`).

## Lints & formatting
- `flutter_lints` default set (`analysis_options.yaml`). Keep `flutter analyze` clean for new code.
- `dart format` only files you create/edit; never bulk-reformat the repo.

## Respecting existing code
- When you join a codebase, follow whatever conventions and structure are already established.
- Don't "fix" intentional-looking existing patterns, quirks, or deprecated-but-working APIs unless the
  task explicitly asks. In existing files, match what's there; in brand-new files, follow this playbook
  and use current APIs that compile on the project's SDK.
