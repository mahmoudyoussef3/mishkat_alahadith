import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

void showBookmarkSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorsManager.hadithAuthentic,
      behavior: SnackBarBehavior.floating,
      content: Text(
        message,
        style: TextStyle(color: ColorsManager.white),
      ),
    ),
  );
}

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorsManager.error,
      behavior: SnackBarBehavior.floating,
      content: Text(
        message,
        style: TextStyle(color: ColorsManager.white),
      ),
    ),
  );
}

/// Neutral confirmation in the theme's snackbar style.
void showInfoSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
