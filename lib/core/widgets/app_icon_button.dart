import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

enum AppIconButtonVariant {
  /// Card surface with a hairline border — the default for headers.
  outlined,

  /// Brand-tinted fill, for a selected or emphasised action.
  tonal,

  /// Solid brand fill, for the primary action of a group.
  filled,

  /// Translucent white, for buttons drawn over dark imagery.
  glass,
}

/// Rounded-square icon button used in headers, toolbars and cards.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.icon,
    this.child,
    this.variant = AppIconButtonVariant.outlined,
    this.size,
  }) : assert(icon != null || child != null);

  /// Read by screen readers and shown on long press.
  final String? tooltip;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Replaces [icon], e.g. for an animated icon.
  final Widget? child;
  final AppIconButtonVariant variant;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (variant) {
      AppIconButtonVariant.outlined => (
        ColorsManager.cardBackground,
        ColorsManager.primaryText,
        ColorsManager.border,
      ),
      AppIconButtonVariant.tonal => (
        ColorsManager.primarySoft,
        ColorsManager.purpleText,
        Colors.transparent,
      ),
      AppIconButtonVariant.filled => (
        ColorsManager.primaryPurple,
        ColorsManager.white,
        Colors.transparent,
      ),
      AppIconButtonVariant.glass => (
        ColorsManager.white.withValues(alpha: 0.14),
        ColorsManager.white,
        ColorsManager.white.withValues(alpha: 0.22),
      ),
    };
    final dimension = size ?? 42.r;
    final enabled = onPressed != null;

    final button = Material(
      // A disabled solid button falls back to a neutral fill.
      color:
          enabled || variant != AppIconButtonVariant.filled
              ? background
              : ColorsManager.lightGray,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: dimension,
          child: IconTheme.merge(
            data: IconThemeData(
              color:
                  enabled
                      ? foreground
                      : variant == AppIconButtonVariant.filled
                      ? ColorsManager.disabledText
                      : foreground.withValues(alpha: 0.35),
              size: dimension * 0.5,
            ),
            child: Center(child: child ?? Icon(icon)),
          ),
        ),
      ),
    );
    final tooltip = this.tooltip;
    if (tooltip == null) return button;
    return Tooltip(message: tooltip, child: button);
  }
}
