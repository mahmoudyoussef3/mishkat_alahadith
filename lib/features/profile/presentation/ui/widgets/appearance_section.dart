import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/profile_styles.dart';

import 'dark_mode_toggle.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.palette,
                  size: 20.sp,
                  color: ColorsManager.primaryPurple,
                ),
                SizedBox(width: 8.w),
                Text('المظهر', style: ProfileTextStyles.sectionHeaderText),
              ],
            ),
            SizedBox(height: 16.h),
            const DarkModeToggle(),
          ],
        ),
      ),
    );
  }
}
