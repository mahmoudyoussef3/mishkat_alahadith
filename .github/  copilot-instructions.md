# Copilot Instructions for Mishkat Al-Masabih

These guidelines help AI assistants contribute safely and consistently to this Flutter project. Follow them to keep the architecture clean, the UI cohesive, and the app fully RTL-friendly.

## Project Architecture
- Clean Architecture per feature:
  - data: models, datasources, repositories (interfaces + implementations)
  - logic: Cubit/Bloc, states
  - ui: screens, widgets
- Dependency Injection: GetIt
  - Register interfaces with `registerLazySingleton` and factories with `registerFactory`
  - Keep registrations in `lib/core/di/dependency_injection.dart`
- Routing: Centralized in `lib/core/routing/app_router.dart` with names in `lib/core/routing/routes.dart`
- Theming: Use `ColorsManager` and `TextStyles`. Fonts: Cairo/Amiri only.
- RTL: All screens and widgets must work Right-To-Left. Prefer `EdgeInsetsDirectional` and avoid `left/right`-only paddings.

## Conventions
- Files and folders: `lower_snake_case`
- Feature structure: `lib/features/<feature>/{data,logic,ui}`
- Public APIs: Preserve existing signatures unless a change is required and all usages are updated.
- Responsiveness: Use `flutter_screenutil` sizes and `LayoutBuilder` for breakpoints (e.g., switch to grid when width >= 700).
- State classes: Keep simple, sealed-like states (Loading/Loaded/Error) when appropriate.
- Null-safety: Avoid `dynamic`; prefer explicit types.

## Data and Networking
- Use `dio` + `retrofit` for HTTP APIs; annotate models with `json_serializable`.
- Do not edit generated files in `build/`.
- For local persistence, prefer `SharedPreferences` for simple key-value, Hive for complex if needed.

## Notifications
- Use `flutter_local_notifications` via our `LocalNotification` helper.
  - Schedule/cancel reminders through provided methods (e.g., hourly section reminders for Daily Zekr).
  - Keep iOS/Android platform differences in mind.

## Prayer Times
- Use `egyptian_prayer_times` for calculation.
  - Set coordinates, method, and timezone correctly.
  - Provide a next-prayer countdown updated with a ticker.
  - Display a responsive grid of prayer times.

## UI/UX Guidelines
- Use `BuildHeaderAppBar` for section headers.
- Match app style from Home/Profile/Library screens.
- Arabic copy: clear, concise, respectful tone.
- Keep widgets reusable (e.g., cards, rows, list items) and RTL-aware.
- Avoid over-animation; use subtle transitions (`AnimatedSwitcher`, `FadeTransition`).

## Adding a New Feature (example flow)
1. Create folders under `lib/features/<feature>/{data,logic,ui}`.
2. Define models and repository interfaces in `data`; implement with a concrete datasource.
3. Add a Cubit in `logic` with states.
4. Build UI widgets and screen in `ui`, wire to Cubit.
5. Register DI in `core/di/dependency_injection.dart`.
6. Add route in `core/routing/app_router.dart` and constant in `core/routing/routes.dart`.
7. Ensure RTL, theming, and responsiveness.

## Testing and Quality
- Write unit tests for pure logic (e.g., Cubit methods) and widget tests for UI states when feasible.
- Keep changes incremental; run analysis/formatting.
- Avoid refactoring unrelated files.

## Security and Secrets
- Never hardcode secrets/api keys. Use platform configs (e.g., `google-services.json`) or environment placeholders.
- Do not commit credentials.

## What to Ask For (when using Copilot)
- Provide clear task goals, file paths, constraints, and expected behavior.
- Request minimal, focused changes that respect existing patterns.
- Ask to update DI and routing when adding screens.
- Specify RTL and responsiveness requirements explicitly.

## Do and Don't
- Do: Use `EdgeInsetsDirectional`, `TextDirection.rtl`, `ScreenUtil`, `GetIt`, `Cubit`.
- Do: Keep styles from `ColorsManager`/`TextStyles`.
- Don't: Introduce new state libraries, change font families, or bypass DI.
- Don't: Edit files under `build/` or reformat large unrelated areas.

## References in Repo
- Daily Zekr feature: shows repository, Cubit, notification scheduling, and RTL-first UI.
- Prayer Times screen: shows package integration, ticker-based countdown, and responsive grid layout.

By following these, AI-generated changes will remain consistent, safe, and mergeable.