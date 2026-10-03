import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';

// ignore: must_be_immutable
class DoubleTapToExitApp extends StatelessWidget {
  DoubleTapToExitApp({super.key, required this.myScaffoldScreen});

  DateTime? lastBackPressed;
  Widget myScaffoldScreen;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          if (lastBackPressed == null ||
              now.difference(lastBackPressed!) > Duration(seconds: 2)) {
            lastBackPressed = now;
            showToast('اضغط مرة اخري للخروج من التطبيق', ColorsManager.gray);

            return false;
          }
          return true;
        },
        child: myScaffoldScreen);
  }
}
