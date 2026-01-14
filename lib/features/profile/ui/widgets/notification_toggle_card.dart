import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/profile_styles.dart';
import 'package:mishkat_almasabih/core/theming/profile_decorations.dart';

class NotificationToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationToggleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ProfileDecorations.notificationCard(value),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            _buildIcon(),
            SizedBox(width: 14.w),
            Expanded(child: _buildContent()),
            SizedBox(width: 8.w),
            _buildSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: ProfileDecorations.notificationIconContainer(value),
      child: Icon(
        icon,
        size: 24.sp,
        color: value ? ColorsManager.primaryPurple : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ProfileTextStyles.notificationCardTitle),
        SizedBox(height: 4.h),
        Text(subtitle, style: ProfileTextStyles.notificationCardSubtitle),
      ],
    );
  }

  Widget _buildSwitch() {
    return Transform.scale(
      scale: 0.9,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: ProfileDecorations.notificationSwitchActiveColor,
        activeTrackColor: ProfileDecorations.notificationSwitchActiveTrackColor,
        inactiveThumbColor:
            ProfileDecorations.notificationSwitchInactiveThumbColor,
        inactiveTrackColor:
            ProfileDecorations.notificationSwitchInactiveTrackColor,
      ),
    );
  }
}
