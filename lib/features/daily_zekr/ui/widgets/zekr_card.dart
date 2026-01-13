import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/daily_zekr_decorations.dart';
import 'package:mishkat_almasabih/core/theming/daily_zekr_styles.dart';
import 'animated_checkbox.dart';

class ZekrCard extends StatelessWidget {
  final String title;
  final String description;
  final bool checked;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onChanged;
  final IconData? leadingIcon;
  final bool enabled;
  final String? footerText;
  final IconData? footerIcon;

  const ZekrCard({
    super.key,
    required this.title,
    required this.description,
    required this.checked,
    this.onTap,
    this.onChanged,
    this.leadingIcon,
    this.enabled = true,
    this.footerText,
    this.footerIcon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFooterText =
        footerText ?? (checked ? 'مكتمل اليوم' : 'سأذكّرك كل دقيقة (تجربة)');
    final effectiveFooterIcon =
        footerIcon ??
        (checked
            ? Icons.check_circle_rounded
            : Icons.notifications_active_rounded);

    return Semantics(
      button: true,
      checked: checked,
      label: title,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(14.r),
          decoration: DailyZekrDecorations.zekrCard(
            enabled: enabled,
            checked: checked,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedCheckbox(
                value: checked,
                onChanged: enabled ? onChanged : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (leadingIcon != null) ...[
                          Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: DailyZekrDecorations.leadingIconTile(),
                            child: Icon(
                              leadingIcon,
                              size: 16.sp,
                              color: ColorsManager.primaryPurple,
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Flexible(
                          child: Text(
                            title,
                            style: DailyZekrTextStyles.zekrTitle(
                              checked: checked,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      description,
                      style: DailyZekrTextStyles.zekrDescription,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: DailyZekrDecorations.footerPill(
                        enabled: enabled,
                        checked: checked,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            effectiveFooterIcon,
                            size: 16.sp,
                            color:
                                !enabled
                                    ? ColorsManager.secondaryText
                                    : checked
                                    ? ColorsManager.hadithAuthentic
                                    : ColorsManager.primaryGold,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            effectiveFooterText,
                            style: DailyZekrTextStyles.footerLabel(
                              enabled: enabled,
                              checked: checked,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 4.w,
                height: 48.h,
                decoration: DailyZekrDecorations.rightGradientBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
