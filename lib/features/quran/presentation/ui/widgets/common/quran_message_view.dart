import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';

/// An empty, error or hint state: an icon, a message and an optional action.
class QuranMessageView extends StatelessWidget {
  final QuranSurfaceColors colors;
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const QuranMessageView({
    super.key,
    required this.colors,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final action = onAction;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44.sp, color: colors.accent.withValues(alpha: 0.6)),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: QuranTextStyles.message(colors.subtitle),
          ),
          if (action != null && actionLabel != null) ...[
            SizedBox(height: 14.h),
            OutlinedButton.icon(
              onPressed: action,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.accent,
                side: BorderSide(color: colors.accent.withValues(alpha: 0.6)),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
