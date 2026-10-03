---
name: create-screen
description: Create a screen widget with the playbook layout, theming, ScreenUtil sizing, and Cubit wiring, decomposed into small widgets. Use when adding a UI screen.
---

# create-screen

Creates `<feature>_screen.dart` plus a `widgets/` folder, following `CLAUDE.md` §11.

## Screen template (`ui/<feature>_screen.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/helpers/spacing.dart';
import '../../../core/theming/styles.dart';

class <Feature>Screen extends StatelessWidget {
  const <Feature>Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title', style: TextStyles.font24BlueBold),
                verticalSpace(8),
                // decomposed widgets from ui/widgets/ go here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Rules
- **Colors** from `ColorsManager`, **text** from `TextStyles`, **spacing** via `verticalSpace`/`horizontalSpace`,
  **sizes** via ScreenUtil `.w/.h/.sp/.r` (design canvas set once, e.g. 375×812). No hardcoded colors/styles/pixels.
- Reuse `AppTextButton` / `AppTextFormField`.
- Break the screen into small widgets in `ui/widgets/` (sub-folders for clusters, like `<feature>/ui/widgets/<cluster>/`).
- If the screen shows async data: consume it with a `BlocBuilder` (`buildWhen` + `maybeWhen(orElse:)`) and add a
  `*_bloc_listener.dart` for side effects (see `create-bloc-listener`).
- Provide the Cubit in `AppRouter` via `BlocProvider`, and add a `Routes` constant (see `add-route`).
- Navigate with `context.pushNamed(Routes.x)` / `context.pop()`.
- `StatelessWidget` by default; `StatefulWidget` only for local UI state (dispose what you own).

## Assets
- SVG: `SvgPicture.asset('assets/svgs/...')`. Network image: `CachedNetworkImage` + `Shimmer.fromColors` placeholder.
- Register any new asset directories in `pubspec.yaml`.
