import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/core/theming/profile_styles.dart';
import 'package:mishkat_almasabih/core/theming/profile_decorations.dart';

class LastActivityCard extends StatelessWidget {
  final String date;

  const LastActivityCard({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: ProfileDecorations.lastActivityCard(),
      child: Row(
        children: [
          _buildIcon(),
          SizedBox(width: 16.w),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: ProfileDecorations.lastActivityIconContainer(),
      child: Icon(FontAwesomeIcons.clock, size: 24.sp, color: Colors.white),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("آخر نشاط", style: ProfileTextStyles.lastActivityLabel),
        SizedBox(height: 4.h),
        Text(date, style: ProfileTextStyles.lastActivityDate),
      ],
    );
  }
}
