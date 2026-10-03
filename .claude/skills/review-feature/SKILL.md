---
name: review-feature
description: Review a feature or diff against the playbook conventions and architecture, reporting findings without modifying existing code. Use for code review of new/changed features.
---

# review-feature

Review-only. Produce a prioritized, `file:line`-referenced findings list. **Do not edit code.**

## Scope the review
```bash
git status
git diff --stat
```
Read the changed files plus the feature they belong to.

## Checklist (see `.claude/docs/CHECKLISTS.md`)
**Architecture**
- Presentation imports no `data/`; Domain is pure Dart (no Flutter/Dio/Retrofit/json); Data implements Domain.
- Models mapped to entities in the repo impl (not in Cubit/UI). Use cases are single-action, return `ApiResult<Entity>`.

**State**
- Cubit + `@freezed` state; `loading → success/error`; `response.when(...)`.
- `buildWhen`/`listenWhen` present and correct; side effects isolated in a `*_bloc_listener.dart`.

**Networking**
- Retrofit `@RestApi(baseUrl: ApiConstants.apiBaseUrl)`; endpoint paths in `*ApiConstants`.
- One Dio via `DioFactory`; repos return `ApiResult` with try/catch + `ErrorHandler`.

**Models**
- `@JsonSerializable`, nullable response fields, `@JsonKey` mappings, `part` present, codegen fresh.

**Theming / UI**
- Colors `ColorsManager`, text `TextStyles`, spacing helpers, ScreenUtil sizes; no hardcoded colors/styles/URLs/pixels.
- Reuse `AppTextButton`/`AppTextFormField`; screen decomposed into `ui/widgets/`.

**Navigation & DI**
- `context` extension + `Routes` (no direct `Navigator.of`). Everything registered in `setupGetIt` with correct lifetime.

**Golden rule**
- Flag any change to existing files that wasn't required by the task.
- Verify `flutter analyze` is clean (run it).

## Output
- Rank findings: **Must fix** (bugs, convention/architecture violations) vs **Nice to have**.
- Each finding: `path:line` + one-line problem + concrete fix suggestion.
- Do **not** flag intentional-looking pre-existing patterns in untouched files (`CONVENTIONS.md`
  §Respecting existing code) as defects introduced by this change.
