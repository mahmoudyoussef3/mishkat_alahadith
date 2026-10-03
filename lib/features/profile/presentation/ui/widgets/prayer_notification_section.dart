import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/profile_styles.dart';

import 'notification_toggle_card.dart';

class PrayerNotificationSection extends StatelessWidget {
  final bool enabled;
  final bool isBusy;

  /// Whether the optional battery-reliability tile should be shown: true only
  /// when notifications are on and the app is not yet exempt from battery
  /// optimization. When false, the tile is hidden entirely.
  final bool showBatteryReliabilityAction;
  final ValueChanged<bool> onChanged;
  final VoidCallback onRefresh;
  final VoidCallback onImproveReliability;

  const PrayerNotificationSection({
    super.key,
    required this.enabled,
    required this.isBusy,
    required this.showBatteryReliabilityAction,
    required this.onChanged,
    required this.onRefresh,
    required this.onImproveReliability,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            SizedBox(height: 16.h),
            NotificationToggleCard(
              title: 'إشعارات مواقيت الصلاة',
              subtitle: 'تنبيهات دقيقة للفجر والظهر والعصر والمغرب والعشاء',
              icon: FontAwesomeIcons.bell,
              value: enabled,
              onChanged: isBusy ? (_) {} : onChanged,
            ),
            SizedBox(height: 10.h),
            _buildRefreshButton(),
            if (showBatteryReliabilityAction) ...[
              SizedBox(height: 10.h),
              _buildBatteryReliabilityCard(),
            ],
            SizedBox(height: 8.h),
            Text(
              'يتم استخدام موقعك المحفوظ أو موقع الجهاز الحالي، مع إعادة المزامنة عند فتح التطبيق.',
              style: ProfileTextStyles.notificationCardSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryReliabilityCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: ColorsManager.primaryGold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ColorsManager.primaryGold.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                FontAwesomeIcons.batteryHalf,
                size: 18.sp,
                color: ColorsManager.primaryGold,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'لضمان وصول التنبيهات في وقتها بدقة، استثنِ التطبيق من تحسين البطارية على جهازك.',
                  style: ProfileTextStyles.notificationCardSubtitle,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: isBusy ? null : onImproveReliability,
              icon: Icon(Icons.tune, size: 18.sp),
              label: const Text('تحسين موثوقية التنبيهات'),
              style: TextButton.styleFrom(
                foregroundColor: ColorsManager.primaryPurple,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(
          FontAwesomeIcons.clockRotateLeft,
          size: 20.sp,
          color: ColorsManager.primaryPurple,
        ),
        SizedBox(width: 8.w),
        Text('مواقيت الصلاة', style: ProfileTextStyles.sectionHeaderText),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isBusy ? null : onRefresh,
        icon:
            isBusy
                ? SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.sync),
        label: Text(
          'مزامنة الإشعارات الآن',
          style: TextStyle(
            color: isBusy ? Colors.grey : ColorsManager.primaryPurple,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: ColorsManager.primaryPurple.withOpacity(0.35),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        ),
      ),
    );
  }
}
