import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/profile_styles.dart';
import 'package:mishkat_almasabih/core/theming/profile_decorations.dart';

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: ProfileDecorations.darkModeCard(),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.sun, color: ColorsManager.primaryGreen),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("الوضع الليلي", style: ProfileTextStyles.darkModeTitle),
                SizedBox(height: 2.h),
                Text("معطل", style: ProfileTextStyles.darkModeStatus),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (value) {},
            activeColor: ProfileDecorations.darkModeSwitchActiveColor,
          ),
        ],
      ),
    );
  }
}
