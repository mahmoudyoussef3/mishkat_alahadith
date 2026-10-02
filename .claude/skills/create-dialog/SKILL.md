---
name: create-dialog
description: Create a dialog (AlertDialog) or a modal bottom sheet using the playbook theming and navigation conventions. Use when a screen needs a popup or bottom sheet.
---

# create-dialog

Covers `showDialog` alerts and `showModalBottomSheet` sheets, styled with `TextStyles`/`ColorsManager`
and dismissed via the `context` navigation extension.

## Alert dialog
```dart
void showAppDialog(BuildContext context, {required String message}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.error, color: Colors.red, size: 32),
      content: Text(message, style: TextStyles.font15DarkBlueMedium),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text('Got it', style: TextStyles.font14BlueSemiBold),
        ),
      ],
    ),
  );
}
```

## Loading dialog
```dart
void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(color: ColorsManager.mainColor),
    ),
  );
}
// dismiss with context.pop();
```

## Modal bottom sheet
```dart
void showAppBottomSheet(BuildContext context, {required Widget child}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.all(24.w),
      child: child,
    ),
  );
}
```

## Guardrails
- Dismiss with `context.pop()` (the `Navigation` extension), not `Navigator.pop` directly.
- Style with `TextStyles` + `ColorsManager`; size with ScreenUtil `.w/.h/.r`.
- Prefer showing dialogs from a `BlocListener` (side-effect layer), not from `build`.
- For confirmation flows, return a value via `Navigator.pop(context, value)` and `await showDialog<T>()`.
