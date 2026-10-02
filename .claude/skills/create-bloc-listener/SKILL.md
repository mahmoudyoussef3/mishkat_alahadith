---
name: create-bloc-listener
description: Create a BlocListener widget that handles side effects (loading dialog, success navigation, error dialog) following the playbook pattern. Use when a screen needs to react to cubit states.
---

# create-bloc-listener

Side effects (dialogs, navigation, snackbars) live in a dedicated listener widget, separate from the
builder. It renders `const SizedBox.shrink()` and is placed in the screen's widget tree.
`<app_name>` = the project's package name from `pubspec.yaml`.

## Template (`ui/widgets/<feature>_bloc_listener.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:<app_name>/core/helpers/extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../logic/<feature>_cubit.dart';
import '../../logic/<feature>_state.dart';

class <Feature>BlocListener extends StatelessWidget {
  const <Feature>BlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<<Feature>Cubit, <Feature>State>(
      listenWhen: (previous, current) =>
          current is Loading || current is Success || current is Error,
      listener: (context, state) {
        state.whenOrNull(
          loading: () => showDialog(
            context: context,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: ColorsManager.mainColor),
            ),
          ),
          success: (data) {
            context.pop(); // dismiss loading
            context.pushNamed(Routes.<targetScreen>);
          },
          error: (error) => _showError(context, error),
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  void _showError(BuildContext context, String error) {
    context.pop(); // dismiss loading
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 32),
        content: Text(error, style: TextStyles.font15DarkBlueMedium),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Got it', style: TextStyles.font14BlueSemiBold),
          ),
        ],
      ),
    );
  }
}
```

## Wire it
Place `const <Feature>BlocListener()` inside the screen's `Column`/tree.
For multi-concern states, match the named subclasses (e.g. `<A>Loading`, `<B>Success`, …) in
`listenWhen` and use `maybeWhen`/`whenOrNull` accordingly.

## Guardrails
- Loading is shown via `showDialog`; **always `context.pop()`** the loader before navigating or showing the
  error dialog.
- Use `listenWhen` so the listener only fires on relevant states.
- Navigation via the `context` extension + `Routes`; text via `TextStyles`; colors via `ColorsManager`.
