import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';

/// Tells a guest that [action] needs an account, with a way to sign in.
void showSignInRequired(
  BuildContext context, {
  String action = 'حفظ الأحاديث',
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('سجّل الدخول لتتمكن من $action'),
        // Snack bars with an action stay until dismissed by default; this
        // one is a hint and should leave on its own.
        persist: false,
        action: SnackBarAction(
          label: 'تسجيل الدخول',
          onPressed: () => context.pushNamed(Routes.loginScreen),
        ),
      ),
    );
}
