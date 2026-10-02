---
name: create-cubit
description: Create a Cubit + freezed State pair following the playbook conventions (loading/success/error, response.when, form controllers). Use when adding state management to a feature.
---

# create-cubit

Creates `<feature>_cubit.dart` and `<feature>_state.dart` matching `CLAUDE.md` §5.

## Inputs
- Feature name, the dependency it injects (use case for data-driven features, repo otherwise),
  the action(s) it performs, and whether it manages a form.

## 1. State (`<feature>_state.dart`)
Auth/simple style (generic success payload):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part '<feature>_state.freezed.dart';

@freezed
class <Feature>State<T> with _$<Feature>State<T> {
  const factory <Feature>State.initial() = _Initial;
  const factory <Feature>State.loading() = Loading;
  const factory <Feature>State.success(T data) = Success<T>;
  const factory <Feature>State.error({required String error}) = Error;
}
```
Multi-concern style (typed factories, prefixed names — one Cubit driving several UI regions):
```dart
@freezed
class <Feature>State with _$<Feature>State {
  const factory <Feature>State.initial() = _Initial;
  const factory <Feature>State.<concept>Loading() = <Concept>Loading;
  const factory <Feature>State.<concept>Success(<Type> data) = <Concept>Success;
  const factory <Feature>State.<concept>Error(ErrorHandler errorHandler) = <Concept>Error;
}
```

## 2. Cubit (`<feature>_cubit.dart`)
```dart
class <Feature>Cubit extends Cubit<<Feature>State> {
  final <Dependency> _dependency;
  <Feature>Cubit(this._dependency) : super(const <Feature>State.initial());

  // Form-owning cubits declare their controllers + key here:
  // TextEditingController emailController = TextEditingController();
  // final formKey = GlobalKey<FormState>();

  void emit<Feature>States() async {
    emit(const <Feature>State.loading());
    final response = await _dependency.<method>(/* build request from controllers */);
    response.when(
      success: (data) => emit(<Feature>State.success(data)),
      failure: (error) => emit(<Feature>State.error(error: error.apiErrorModel.message ?? '')),
    );
  }
}
```

## 3. Generate & wire
```bash
dart run build_runner build --delete-conflicting-outputs
```
- Provide via `BlocProvider` in `AppRouter` and/or `getIt.registerFactory<<Feature>Cubit>(() => <Feature>Cubit(getIt()));`.
- Consume with `BlocBuilder` (`buildWhen` + `maybeWhen(orElse:)`); side effects in a `*_bloc_listener.dart`
  (see the `create-bloc-listener` skill).

## Guardrails
- Cubit only (no Bloc/events). Emit `loading` before async, branch with `.when(success:, failure:)`.
- Data-driven features inject a **use case**, not a repo. Never hand-edit `*.freezed.dart`.
