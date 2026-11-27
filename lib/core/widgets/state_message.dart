import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Centered icon, title and hint for empty and error states, with an
/// optional action such as "retry".
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  /// Error state with a retry action.
  factory StateMessage.error({
    Key? key,
    required String message,
    required VoidCallback onRetry,
  }) => StateMessage(
    key: key,
    icon: Icons.cloud_off_rounded,
    title: 'تعذر التحميل',
    subtitle: message,
    actionLabel: 'إعادة المحاولة',
    actionIcon: Icons.refresh_rounded,
    onAction: onRetry,
  );

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final subtitle = this.subtitle;
    final actionLabel = this.actionLabel;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: palette.primarySoft,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(icon, size: 30.r, color: palette.purpleText),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: palette.primaryText,
            ),
          ),
          if (subtitle != null && subtitle.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyles.caption.copyWith(
                fontSize: 13.sp,
                height: 1.6,
                color: palette.secondaryText,
              ),
            ),
          ],
          if (actionLabel != null) ...[
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon ?? Icons.arrow_back_rounded),
              label: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}
