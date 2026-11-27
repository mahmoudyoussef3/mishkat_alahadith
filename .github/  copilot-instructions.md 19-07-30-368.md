# Copilot Instructions — Flutter Clean Architecture Project

<!--
Golden Test: "Would removing this rule cause incorrect behavior?"
If not → remove it.
Avoid duplication of defaults already handled by Copilot or Dart/Flutter best practices.
-->

---

# A — Core Engineering Rules

## 1. Architecture (STRICT)

Follow clean architecture:

```
Presentation → Domain → Data
```

Rules:

- Presentation = UI + state observation only
- Domain = business logic only (pure Dart)
- Data = API / DB / external sources only
- Never bypass layers
- Never mix responsibilities

---

## 2. Shared Code

- Any reusable logic used in 2+ places MUST go to `core/`
- Always check `core/` before creating new utilities
- Never duplicate logic across features

---

## 3. Error Handling

- Errors must flow through layers properly
- No silent failures
- Handle:
  - null
  - empty
  - loading
  - error states explicitly
- Catch exceptions ONLY in data layer boundary

---

## 4. Change Discipline

- Make minimal required change only
- Fix root cause, not symptoms
- Do not refactor unrelated code
- Never break existing flows unless explicitly asked
- Always read relevant code before modifying

---

## 5. Dependencies

- Do NOT add packages without justification
- Must be:
  - stable
  - maintained
  - production ready

---

## 6. Security

- No hardcoded secrets or tokens
- No sensitive logging
- Validate all external input
- Flag security risks immediately

---

## 7. Testing Rules

- Test domain + data layers
- Bug fixes MUST include reproduction test
- Tests must be deterministic
- One behavior per test

---

## 8. Workflow Rules (MANDATORY)

Before:

- Feature creation → use `flutter-feature` skill
- Task completion → run `flutter-code-review` skill
- After approval → use `git-expert` agent for PR workflow

---

## 9. Agent Usage (IMPORTANT)

Always proactively suggest:

- `@debugger` → for crashes, bugs, unexpected behavior
- `@code-reviewer` → after code-review skill passes, before PR
- `@test-writer` → when tests are missing or feature changed
- `@git-expert` → for commits, branches, PRs, conflicts, rebases

---

# B — Flutter / Dart Rules

## 1. State Management

- Use Cubit/Bloc ONLY
- Cubits depend ONLY on use cases
- No direct repository access in Cubit
- `setState` allowed ONLY for local UI state

---

## 2. No Code Generation Policy

- No Freezed
- No build_runner
- Use Dart 3 features:
  - sealed classes
  - pattern matching
  - switch expressions

---

## 3. Domain Purity

- Domain layer = pure Dart only
- No Flutter imports in domain

---

## 4. Feature Structure

```
features/{feature}/
  data/
  domain/
  presentation/
```

---

## 5. Error Contract

- Data layer → maps exceptions → Failure types
- Domain layer → returns ApiResult<T>
- Presentation → converts failures into UI states

---

## 6. Dependency Injection

- Use `get_it`
- All DI in `core/di/`
- No manual instantiation of repositories/use cases in UI

---

## 7. Build Method Rules

- Use `const` wherever possible
- NEVER create controllers inside build()
- Dispose controllers properly
- Avoid heavy logic in build()
- Use smallest possible BlocBuilder scope