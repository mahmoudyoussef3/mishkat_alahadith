import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Compact on/off switch: brand track when on, sand track when off.
///
/// Pass a null [onChanged] to show it disabled, e.g. while saving.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  static const _duration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final enabled = onChanged != null;
    final width = 46.r;
    final height = 28.r;
    final thumb = 22.r;

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: _duration,
            curve: Curves.easeOut,
            width: width,
            height: height,
            padding: EdgeInsets.all((height - thumb) / 2),
            decoration: BoxDecoration(
              color:
                  value ? palette.primaryPurple : palette.mediumGray,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: AnimatedAlign(
              duration: _duration,
              curve: Curves.easeOut,
              alignment:
                  value
                      ? AlignmentDirectional.centerStart
                      : AlignmentDirectional.centerEnd,
              child: Container(
                width: thumb,
                height: thumb,
                decoration: BoxDecoration(
                  color: ColorsManager.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: palette.shadow,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
