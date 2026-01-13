import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/decorations.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

class BuildInfoSection extends StatelessWidget {
  const BuildInfoSection({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: Decorations.infoCard,
      child: Row(
        children: [
          Icon(icon, color: ColorsManager.primaryGreen),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              text,
              style: TextStyles.bodyMedium.copyWith(
                color: ColorsManager.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
