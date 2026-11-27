import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';

/// A chapter's number, or icon, in a circle whose rim fills as today's
/// count grows, turning to a check once the chapter is done.
class AzkarProgressBadge extends StatelessWidget {
  const AzkarProgressBadge({
    super.key,
    required this.progress,
    this.label,
    this.icon,
    this.size,
    this.background,
    this.foreground,
  }) : assert(label != null || icon != null);

  final AzkarCategoryProgress progress;
  final String? label;
  final IconData? icon;
  final double? size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final dimension = size ?? 42.r;
    final done = progress.isComplete;
    final fill = done ? palette.success : (background ?? palette.primarySoft);
    final ink =
        done ? palette.cardBackground : (foreground ?? palette.purpleText);
    final label = this.label;

    return SizedBox.square(
      dimension: dimension,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsets.all(4.r),
            child: DecoratedBox(
              decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
              child: Center(
                child:
                    done
                        ? Icon(
                          Icons.check_rounded,
                          size: dimension * 0.45,
                          color: ink,
                        )
                        : label == null
                        ? Icon(icon, size: dimension * 0.45, color: ink)
                        : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              label,
                              style: TextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color: ink,
                              ),
                            ),
                          ),
                        ),
              ),
            ),
          ),
          if (progress.isStarted && !done)
            CircularProgressIndicator(
              value: progress.fraction,
              strokeWidth: 2.5,
              strokeCap: StrokeCap.round,
              color: palette.goldBright,
              backgroundColor: palette.lightGray,
            ),
        ],
      ),
    );
  }
}
