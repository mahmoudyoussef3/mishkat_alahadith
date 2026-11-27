import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/settings_group.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/prayer_location.dart';

/// Lets the reader pick the city prayer times are calculated for, or use
/// the device's location.
Future<void> showPrayerLocationSheet(
  BuildContext context, {
  required PrayerLocation current,
  required ValueChanged<PrayerLocation> onSelected,
  required VoidCallback onUseCurrentLocation,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder:
        (sheetContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8,
            ),
            child: SafeArea(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                children: [
                  Text('موقع المواقيت', style: TextStyles.sectionTitle),
                  Text(
                    'تُحسب المواقيت والتنبيهات لهذا الموقع',
                    style: TextStyles.caption.copyWith(fontSize: 13.sp),
                  ),
                  SizedBox(height: 16.h),
                  SettingsGroup(
                    title: 'تلقائي',
                    children: [
                      SettingsTile(
                        icon: Icons.my_location_rounded,
                        title: 'استخدم موقعي الحالي',
                        subtitle: 'يتطلب إذن الوصول إلى الموقع',
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          onUseCurrentLocation();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SettingsGroup(
                    title: 'المدن',
                    children: [
                      for (final city in PrayerLocation.egyptianCities)
                        SettingsTile(
                          icon: Icons.location_city_rounded,
                          iconBackground: ColorsManager.lightGray,
                          iconColor: ColorsManager.primaryText,
                          title: city.cityName,
                          trailing:
                              city.cityName == current.cityName
                                  ? Icon(
                                    Icons.check_circle_rounded,
                                    color: ColorsManager.primaryPurple,
                                    size: 22.r,
                                  )
                                  : const SizedBox.shrink(),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            if (city.cityName != current.cityName) {
                              onSelected(city);
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}
