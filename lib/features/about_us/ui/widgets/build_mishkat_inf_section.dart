import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class BuildMishkatInfSection extends StatelessWidget {
  const BuildMishkatInfSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorsManager.primaryPurple, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsManager.white,
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.black.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(18.w),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'منصة رقمية متكاملة لدراسة الأحاديث النبوية الشريفة مع تحليل ذكي وفوائد عملية',
              style: TextStyle(color: ColorsManager.secondaryBackground),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Divider(color: ColorsManager.gray, endIndent: 50.w, indent: 50.w),
            SizedBox(height: 8.h),

            SizedBox(height: 10.h),
            Text(
              "© جميع الحقوق محفوظة لتطبيق مشكاة الأحاديث 2025",
              style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
