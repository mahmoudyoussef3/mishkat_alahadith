---
description: Scaffold a new feature using the playbook's Clean Architecture (Presentation → Domain → Data).
argument-hint: <feature_name> [endpoint + brief description]
---

Scaffold a new feature named "$ARGUMENTS".

Follow the `create-feature` skill exactly and `.claude/docs/ARCHITECTURE.md`:
- Create `lib/features/<name>/{data/{models,datasources,mappers,repos},domain/{entities,repos,usecases},presentation/{logic,ui/widgets}}`.
- Build: models → datasource (+ api constants) → entity → repo interface → mapper → repo impl → use case
  → freezed state → cubit → screen + widgets → bloc listener.
- Register in `setupGetIt()`; add a `Routes` constant + `AppRouter` case with `BlocProvider`.
- Run `dart run build_runner build --delete-conflicting-outputs`, then `flutter analyze`.

Hard rules:
- Create only new files; make the minimal additions to `dependency_injection.dart`, `routes.dart`,
  `app_router.dart`. Do NOT modify any other existing file, and do NOT touch unrelated existing code.
- Presentation imports only Domain; Domain is pure Dart; Data implements Domain.
- Reuse `ApiResult`, `ErrorHandler`, `DioFactory`, theming/spacing/extensions, shared widgets.

First inspect the repo (package name from `pubspec.yaml`, existing core primitives) and confirm the
endpoint(s), request/response shape, and whether a form is needed if not given. Then report every file
created and the DI/route lines added.
