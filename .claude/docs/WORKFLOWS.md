# Development Workflows

Concrete, ordered playbooks for common tasks. All of them respect the golden rule: **never modify
existing source files unless the task explicitly requires it.** Data-driven features follow the Clean
Architecture in `.claude/docs/ARCHITECTURE.md`. `<app_name>` = the project's package name from
`pubspec.yaml`; `<x>`/`<Feature>`/`<Entity>` are per-feature placeholders.

---

## Workflow A — Add a new feature (Clean Architecture)

1. **Skeleton.** Create `features/<x>/{data/{models,datasources,mappers,repos},domain/{entities,repos,usecases},presentation/{logic,ui/widgets}}`.
2. **Data → models.** Add `@JsonSerializable` DTOs (`fromJson` for responses, `toJson` for request bodies),
   `@JsonKey` for mismatched keys. Nullable response fields.
3. **Data → datasource.** Add `<x>_api_service.dart` (`@RestApi(baseUrl: ApiConstants.apiBaseUrl)`) and
   `<x>_api_constants.dart` with endpoint path strings.
4. **Domain → entities.** Plain classes, no annotations.
5. **Domain → repo interface.** `abstract class <X>Repo` with methods returning `Future<ApiResult<Entity>>`.
6. **Data → mapper.** Extension `<X>Model.toEntity()`.
7. **Data → repo impl.** `<X>RepoImpl implements <X>Repo`; try/catch → `ApiResult.success(mapped)` /
   `ApiResult.failure(ErrorHandler.handle(e))`.
8. **Domain → use cases.** One class per action, `call(...)` delegating to the repo interface.
9. **Presentation → state.** `@freezed` union (`initial/loading/success/error`).
10. **Presentation → cubit.** Injects use case(s); emits states via `result.when(...)`.
11. **Presentation → UI.** Screen + small widgets in `ui/widgets/`; `BlocBuilder` (with `buildWhen`) for
    rendering, a `<x>_bloc_listener.dart` for dialogs/navigation.
12. **DI.** Register datasource, repo impl (bound to interface), use cases, and cubit in `setupGetIt()`.
13. **Routing.** Add a `Routes.xScreen` constant and a `case` in `AppRouter` wrapping the screen in a
    `BlocProvider`.
14. **Codegen.** `dart run build_runner build --delete-conflicting-outputs`.
15. **Verify.** `flutter analyze` (0 new issues) → run the app.
16. **Commit** source + generated files together.

> Prefer the `create-feature` skill, which scaffolds steps 1–13 following these conventions.

---

## Workflow B — Add an API call to an existing feature

1. Add the endpoint path to the feature's `*ApiConstants` (or `ApiConstants` for shared/auth).
2. Add the method to the feature's Retrofit `*ApiService` (`@GET`/`@POST`, `@Body()`/`@Query()`/`@Path()`).
3. Add request/response models (`@JsonSerializable`) if needed.
4. Add a repo method returning `ApiResult<T>` (try/catch → success/failure).
5. `dart run build_runner build --delete-conflicting-outputs`.
6. Call it from the Cubit and emit new states as needed.

If the feature has no `*ApiService` yet, create one in `data/datasources/` and register it in `setupGetIt()`.

---

## Workflow C — Add / change a model

1. Edit or create the `@JsonSerializable` class; add `part '<name>.g.dart';`.
2. Use `@JsonKey(name:)` for server keys that differ from Dart names.
3. `dart run build_runner build --delete-conflicting-outputs`.
4. Confirm the generated `.g.dart` compiles; commit both files.
5. Update the corresponding entity + mapper.

---

## Workflow D — Create a Cubit + State

1. Create `<feature>_state.dart` (`@freezed`, `part '<feature>_state.freezed.dart';`).
   - Auth/simple style: `initial/loading/success<T>/error`.
   - Multi-concern: explicit typed, prefixed factories per concern.
2. Create `<feature>_cubit.dart` (`extends Cubit<<Feature>State>`), inject use case/repo, own
   `TextEditingController`s + `formKey` if it's a form.
3. Action method(s) emit `loading` → call use case/repo → `response.when(success:, failure:)`.
4. `dart run build_runner build --delete-conflicting-outputs` (for the freezed state).
5. Provide the Cubit via `BlocProvider` in `AppRouter` and/or register in `setupGetIt()`.

---

## Workflow E — Build a screen / widget

1. `<Feature>Screen extends StatelessWidget`; `Scaffold` → `SafeArea` → padding with `.w`/`.h`.
2. Break the screen into small widgets under `ui/widgets/` (group into sub-folders for clusters).
3. Colors from `ColorsManager`, text from `TextStyles`, spacing via `verticalSpace`/`horizontalSpace`,
   sizes with ScreenUtil extensions.
4. Reuse `AppTextButton` / `AppTextFormField`.
5. Wire state with `BlocBuilder` (`buildWhen` + `maybeWhen(orElse:)`); side effects in a `BlocListener`
   widget (`listenWhen` + `whenOrNull`).
6. Navigate with `context.pushNamed(Routes.x)` etc.

---

## Workflow F — Run code generation

```bash
dart run build_runner build --delete-conflicting-outputs   # one-off
dart run build_runner watch --delete-conflicting-outputs   # keep running while editing
```
If it fails: `flutter clean && flutter pub get`, then rebuild. Never edit generated files by hand.

---

## Workflow G — Introduce / update localization (only if explicitly requested)

Localization is opt-in. If asked to introduce it:
1. Add `assets/translations/{en.json, ...}` and register `assets/translations/` in `pubspec.yaml`.
2. `await EasyLocalization.ensureInitialized();`, wrap `runApp` with `EasyLocalization(...)`, and add its
   delegates to `MaterialApp` in the root widget.
3. Replace hardcoded strings with `'key'.tr()` — scope changes to the target screens.
4. Don't retrofit unrelated existing screens unless explicitly asked.

---

## Workflow H — Update the theme

1. New color → add a `static const Color` to `ColorsManager`.
2. New text style → add a `static TextStyle font<Size><Color><Weight>` to `TextStyles`.
3. New weight → add to `FontWeightHelper` only if a real new weight is needed.
4. Reference the new tokens from widgets; never inline literal colors/styles.

---

## Workflow I — Review a feature

Use the `review-feature` skill or `/review-feature`. Check: layer boundaries, Cubit/State conventions,
`ApiResult` usage in repos, `buildWhen`/`listenWhen` present, theming tokens (no hardcoded
colors/styles/sizes), navigation via extension, DI registration, and that codegen output is up to date.
Report findings; **do not** auto-refactor existing code.

---

## Workflow J — Prepare a commit / PR

1. `dart run build_runner build --delete-conflicting-outputs` if any annotated file changed.
2. `flutter analyze` → 0 new issues.
3. `dart format <only files you touched>` — never bulk-format.
4. Stage source + generated files together.
5. Commit message: concise, imperative.
6. Keep the diff scoped to one feature/fix; target the repository's integration branch. Include what/why
   and test notes.
