import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'notification_toggle_card.dart';

class NotificationSection extends StatelessWidget {
  final bool dailyHadithNotification;
  final bool azkarNotification;
  final bool werdNotification;
  final Function(String key, bool value) onNotificationChanged;

  const NotificationSection({
    super.key,
    required this.dailyHadithNotification,
    required this.azkarNotification,
    required this.werdNotification,
    required this.onNotificationChanged,
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
              title: "الحديث اليومي",
              subtitle: "استقبل إشعار بحديث جديد كل يوم",
              icon: FontAwesomeIcons.bookQuran,
              value: dailyHadithNotification,
              onChanged: (value) {
                onNotificationChanged('daily_hadith_notification', value);
              },
            ),
            SizedBox(height: 12.h),
            NotificationToggleCard(
              title: "أذكار الصباح والمساء",
              subtitle: "تذكير بأذكار الصباح والمساء يومياً",
              icon: FontAwesomeIcons.moon,
              value: azkarNotification,
              onChanged: (value) {
                onNotificationChanged('azkar_notification', value);
              },
            ),
            SizedBox(height: 12.h),
            NotificationToggleCard(
              title: "الورد اليومي",
              subtitle: "تذكير بورد جديد كل يوم",
              icon: FontAwesomeIcons.book,
              value: werdNotification,
              onChanged: (value) {
                onNotificationChanged('werd_notification', value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(
          FontAwesomeIcons.bell,
          size: 20.sp,
          color: ColorsManager.primaryPurple,
        ),
        SizedBox(width: 8.w),
        Text(
          "الإشعارات",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}