# Client App Engineering Standard (`lib/apps/client`)

This is the **authoritative convention reference for the Client App**. The root `CLAUDE.md` is a
generic Flutter playbook that assumes a Retrofit/Dio/freezed/`ApiResult` stack — **the Client App
does not use that stack.** Per the golden rule ("match the conventions of the code you are editing"),
Client App work follows the patterns documented here. Where this file and the generic playbook
conflict, **this file wins for anything under `lib/apps/client`.**

---

## 1. Stack (what the client actually uses)

| Concern | Client App reality |
|---|---|
| Backend | **Supabase** (`Supabase.instance.client`). No Retrofit, no Dio, no `ApiConstants` base URL. |
| State mgmt | `flutter_bloc` **Cubit only**. |
| State type | **Plain `sealed class` unions** — `XLoading` / `XLoaded(data)` / `XError(msg)`. **No freezed** for client state. |
| Errors | Datasource/repo may `throw`. The **cubit** wraps calls in `try/catch` and emits `XError(e.toString())`. **No `ApiResult<T>`.** |
| DI | `get_it` via the client-local locator **`clientGetIt`**, wired in `core/di/client_di.dart` through inline private `_registerXDependencies()` functions. |
| Routing | Core `ClientRouter` (a `Map<String, WidgetBuilder>`) + `ClientCubitScopes` + `ClientRoutes` in `core/routes/`. |
| Theme | `core/theme/client_*` — `ClientColors`, `ClientTypography`, `ClientAppTheme`, `client_design_tokens.dart`. |
| Shared widgets | `core/widgets/client_*` — `ClientButton`, `ClientCard`, `ClientSectionHeader`, `ClientSkeleton`, `ClientStatusBadge`, `ClientBottomSheet`, `ClientErrorCard`, plus `client_widgets.dart` barrel. |
| Localization | Generated `context.l10n.*` (`AppLocalizations`). Already wired app-wide — reuse keys; add keys via the l10n workflow, never hardcode user-facing strings. |
| Sizing | Uses raw logical pixels + `EdgeInsets`/`SizedBox` (no `flutter_screenutil` in the client). Match the file you edit. |

## 2. Feature layout (Clean Architecture, one-way deps)

```
features/<x>/
  data/{datasources,models,mappers,repositories}   # Supabase datasources + DTOs + mappers + repo impl
  domain/{entities,repositories,usecases}           # pure Dart contracts
  presentation/{cubit,screens,widgets,routes,utils,models}
```

- `data/datasources/`: an abstract `<X>Datasource` interface + a `Supabase<X>Datasource(SupabaseClient)`
  implementation. Register the implementation against the interface in `client_di.dart`.
- `domain/repositories/`: abstract `<X>Repository` returning **plain futures of entities**
  (`Future<Entity>` / `Future<List<Entity>>`), not `ApiResult`.
- `data/repositories/<x>_repository_impl.dart implements <X>Repository`; maps models → entities via
  `data/mappers/`.
- `domain/usecases/`: one action per class, `call(...)` delegating to the repository interface.
- Presentation never imports `data/`; domain never imports Flutter/Supabase.
- **Dead `di/<x>_di.dart` files** (global `getIt`, `// GENERATED_PLACEHOLDER_HEADER`) are scaffold
  leftovers — the real DI is inline in `core/di/client_di.dart`. Do not add to them; delete on sight.

## 3. Cubit + State conventions

- **One cubit per flow/screen concern**, not one god-cubit per feature. If a feature has several
  independent screens (search, results, details…), each gets its own small cubit + state.
- Cubit `extends Cubit<XState>`, injects use case(s), `super(const XInitial())` (or `XLoading()`).
- Action method: `emit(const XLoading())` → `try { emit(XLoaded(await useCase())); } catch (e) { emit(XError(e.toString())); }`.
- State is a `sealed class` in `<x>_state.dart` (no codegen):

```dart
sealed class VehicleListingState { const VehicleListingState(); }
class VehicleListingLoading extends VehicleListingState { const VehicleListingLoading(); }
class VehicleListingLoaded extends VehicleListingState {
  const VehicleListingLoaded(this.vehicles);
  final List<VehicleDetailData> vehicles;
}
class VehicleListingError extends VehicleListingState {
  const VehicleListingError(this.message);
  final String message;
}
```

- A cubit that owns form-like input (query, filters, selected values) holds that in its **loaded
  state**, and exposes intent methods (`setPickup`, `swap`, `setSort`) that re-emit an updated state —
  **not** in a `StatefulWidget`.
- UI: `BlocBuilder` with `buildWhen`; switch on the sealed state (`switch (state) { … }` or
  pattern `is`-checks) returning `const` placeholders for irrelevant states. Side effects in a
  `BlocListener` (`listenWhen`).

## 4. Screens & widgets

- Screens are **`StatelessWidget`** and get their data from a cubit. Use `StatefulWidget` **only** for
  genuinely ephemeral UI state (`TabController`, `AnimationController`, `ScrollController`,
  text-field focus) — and even then the *data* comes from the cubit, not `setState`.
- **No file over 120 lines** for screens/widgets/cubits/states (hard). Decompose screens into small
  `const` `StatelessWidget`s under `presentation/widgets/<cluster>/` (see existing `route_details/`,
  `summary/`, `payment/`, `map/` clusters).
- Data-layer files (datasources/models) aim ≤120 via private query helpers + `data/mappers/`
  extraction, but a single cohesive Supabase query may exceed — keep it readable and flag it.
- `const` constructors and `const` instances wherever possible. One widget per file.
- Colors only from `ClientColors`; text only from `ClientTypography`/theme; reuse `client_*` widgets.

## 5. Routing

- Route-name constants live **with their feature**: `features/<x>/presentation/routes/<x>_routes.dart`
  (e.g. `BookingRoutes`). App-shell-only paths live in `ClientRoutes`. Every path is declared once.
- The central table is `ClientRouter.routes` (`core/routes/client_router.dart`), mapping each path to a
  builder that wraps the screen in the right **`ClientCubitScopes`** helper and resolves arguments via
  the owning entity's `fromArguments` factory.
- Add a screen = add a route constant + a `ClientCubitScopes.<x>` helper (if it needs a cubit) + a
  builder entry in `ClientRouter`. Cubit scopes use `clientGetIt<XCubit>()` via `registerFactory`
  (fresh cubit per navigation).
- Navigation from screens uses `Navigator.pushNamed(context, XRoutes.y, arguments: …)`; the shell
  passes an `onOpenRoute` opener to its tabs. Match the existing style of the file you edit.

## 6. DI (`core/di/client_di.dart`)

- `final clientGetIt = GetIt.asNewInstance();` (client-local). `setupClientDependencies()` calls one
  `_registerXDependencies()` per feature.
- Pattern: datasource impl → repo impl (bound to interface) as `registerLazySingleton`; use cases as
  `registerLazySingleton`; **cubits as `registerFactory`**. Guard each with `if (!isRegistered<…>())`.

## 7. Definition of done (per feature)

- No dead code (unused widgets/usecases/routes/di); no commented-out blocks.
- One cubit per concern; screens stateless; every presentation file ≤120 lines.
- `flutter analyze lib/apps/client/features/<x>` → **0 new issues** vs baseline.
- All existing behavior preserved (this is structural refactoring, not feature change).
