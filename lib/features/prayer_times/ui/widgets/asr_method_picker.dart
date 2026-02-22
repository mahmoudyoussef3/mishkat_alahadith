import 'package:egyptian_prayer_times/egyptian_prayer_times.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/prayer_times_decorations.dart';
import 'package:mishkat_almasabih/core/theming/prayer_times_styles.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/services/asr_method_preference.dart';

class AsrMethodPicker extends StatelessWidget {
  final AsrMethod selected;
  final ValueChanged<AsrMethod> onChanged;

  const AsrMethodPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: PrayerTimesDecorations.gridRowContainer(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طريقة حساب العصر',
              style: PrayerTimesTextStyles.prayerRowTitle.copyWith(
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children:
                  AsrMethodPreference.allMethods.map((method) {
                    final isSelected = method == selected;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end:
                              method != AsrMethodPreference.allMethods.last
                                  ? 8.w
                                  : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => onChanged(method),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              vertical: 10.h,
                              horizontal: 4.w,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? ColorsManager.primaryPurple.withOpacity(
                                        0.12,
                                      )
                                      : ColorsManager.cardBackground,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? ColorsManager.primaryPurple
                                        : ColorsManager.mediumGray,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                AsrMethodPreference.arabicLabel(method),
                                textAlign: TextAlign.center,
                                style: PrayerTimesTextStyles.prayerRowTime
                                    .copyWith(
                                      color:
                                          isSelected
                                              ? ColorsManager.primaryPurple
                                              : ColorsManager.secondaryText,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w700
                                              : FontWeight.normal,
                                      fontSize: 13.sp,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
