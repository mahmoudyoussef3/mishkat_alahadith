import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'animated_checkbox.dart';

class ZekrCard extends StatelessWidget {
  final String title;
  final String description;
  final bool checked;
  final VoidCallback onTap;
  final ValueChanged<bool?> onChanged;
  final IconData? leadingIcon;

  const ZekrCard({
    super.key,
    required this.title,
    required this.description,
    required this.checked,
    required this.onTap,
    required this.onChanged,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        checked
            ? ColorsManager.primaryPurple.withOpacity(0.06)
            : ColorsManager.cardBackground;
    final borderColor =
        checked ? ColorsManager.primaryPurple : ColorsManager.mediumGray;

    return Semantics(
      button: true,
      checked: checked,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: borderColor, width: checked ? 1.8 : 1.2),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.primaryPurple.withOpacity(
                  checked ? 0.10 : 0.06,
                ),
                blurRadius: checked ? 10 : 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedCheckbox(value: checked, onChanged: onChanged),
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
                            decoration: BoxDecoration(
                              color: ColorsManager.primaryPurple.withOpacity(
                                0.10,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: ColorsManager.primaryPurple.withOpacity(
                                  0.25,
                                ),
                                width: 1,
                              ),
                            ),
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
                            style: TextStyles.titleLarge.copyWith(
                              color:
                                  checked
                                      ? ColorsManager.primaryPurple
                                      : ColorsManager.primaryText,
                              fontFamily: 'Cairo',
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
                      style: TextStyles.bodyMedium.copyWith(
                        color: ColorsManager.secondaryText,
                        fontFamily: 'Cairo',
                      ),
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
                        decoration: BoxDecoration(
                          color:
                              checked
                                  ? ColorsManager.hadithAuthentic.withOpacity(
                                    0.12,
                                  )
                                  : ColorsManager.primaryGold.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color:
                                checked
                                    ? ColorsManager.hadithAuthentic.withOpacity(
                                      0.6,
                                    )
                                    : ColorsManager.primaryGold.withOpacity(
                                      0.6,
                                    ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              checked
                                  ? Icons.check_circle_rounded
                                  : Icons.notifications_active_rounded,
                              size: 16.sp,
                              color:
                                  checked
                                      ? ColorsManager.hadithAuthentic
                                      : ColorsManager.primaryGold,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              checked ? 'مكتمل اليوم' : 'سأذكّرك كل ساعة',
                              style: TextStyles.labelMedium.copyWith(
                                color:
                                    checked
                                        ? ColorsManager.hadithAuthentic
                                        : ColorsManager.primaryGold,
                                fontFamily: 'Cairo',
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ColorsManager.primaryPurple,
                      ColorsManager.primaryGold,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
