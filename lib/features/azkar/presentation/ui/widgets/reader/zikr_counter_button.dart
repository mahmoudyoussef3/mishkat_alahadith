import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// A round counter showing how many repetitions remain, ringed with how
/// many are done; a check once the zikr is complete.
class ZikrCounterButton extends StatelessWidget {
  const ZikrCounterButton({
    super.key,
    required this.said,
    required this.count,
    required this.onPressed,
  });

  final int said;
  final int count;

  /// Null once the zikr is complete.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final done = said >= count;
    final remaining = count - said;
    final dimension = 64.r;

    return Semantics(
      button: true,
      enabled: !done,
      label: done ? 'تمّ' : 'عدّ، بقي ${toArabicDigits('$remaining')}',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: dimension,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: count == 0 ? 0 : said / count,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
              color: done ? palette.success : palette.goldBright,
              backgroundColor: palette.lightGray,
            ),
            Padding(
              padding: EdgeInsets.all(7.r),
              child: Material(
                color: done ? palette.success : palette.primaryPurple,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onPressed,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder:
                          (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                      child:
                          done
                              ? Icon(
                                Icons.check_rounded,
                                key: const ValueKey('done'),
                                size: dimension * 0.4,
                                color: ColorsManager.white,
                              )
                              : FittedBox(
                                key: ValueKey(remaining),
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                  ),
                                  child: Text(
                                    toArabicDigits('$remaining'),
                                    style: TextStyles.titleLarge.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: ColorsManager.white,
                                    ),
                                  ),
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
