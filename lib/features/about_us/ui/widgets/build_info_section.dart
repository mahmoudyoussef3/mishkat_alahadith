import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class BuildInfoSection extends StatelessWidget {
  const BuildInfoSection({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;  

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorsManager.mediumGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorsManager.primaryGreen),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
