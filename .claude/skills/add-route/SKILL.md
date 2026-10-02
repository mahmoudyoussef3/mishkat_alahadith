---
name: add-route
description: Add a navigation route — a Routes constant plus an AppRouter case (with BlocProvider if the screen uses a cubit). Use when exposing a new screen to navigation.
---

# add-route

Wires a screen into navigation following `CLAUDE.md` §8. Touch only `routes.dart` and `app_router.dart`.

## 1. Add the route name (`core/routing/routes.dart`)
```dart
class Routes {
  static const String onBoardingScreen = '/onBoardingScreen';
  static const String loginScreen = '/loginScreen';
  static const String signUpScreen = '/signUpScreen';
  static const String homeScreen = '/homeScreen';
  static const String <feature>Screen = '/<feature>Screen';   // <-- add
}
```

## 2. Add the case (`core/routing/app_router.dart`)
Screen **with** a Cubit:
```dart
case Routes.<feature>Screen:
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => getIt<<Feature>Cubit>()..<initialAction>(),
      child: const <Feature>Screen(),
    ),
  );
```
Screen **without** a Cubit:
```dart
case Routes.<feature>Screen:
  return MaterialPageRoute(builder: (_) => const <Feature>Screen());
```
Passing arguments:
```dart
final args = settings.arguments as <ArgsType>;
case Routes.<feature>Screen:
  return MaterialPageRoute(builder: (_) => <Feature>Screen(args: args));
```

## 3. Navigate to it
```dart
context.pushNamed(Routes.<feature>Screen, arguments: /* optional */);
```

## Guardrails
- Route strings only in `Routes`; never inline literals at call sites.
- Provide the Cubit here via `BlocProvider` (unless the feature registers it another way).
- Navigate via the `context` `Navigation` extension — never `Navigator.of(context)` directly in features.
- Keep the `switch` returning `null` in its `default` case (existing behavior).
