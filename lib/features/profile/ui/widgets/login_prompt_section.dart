import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class LoginPromptSection extends StatelessWidget {
  final VoidCallback onLoginPressed;

  const LoginPromptSection({
    super.key,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              SizedBox(height: 24.h),
              _buildTitle(),
              SizedBox(height: 12.h),
              _buildSubtitle(),
              SizedBox(height: 32.h),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: ColorsManager.primaryPurple.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        FontAwesomeIcons.userLock,
        size: 80.sp,
        color: ColorsManager.primaryPurple,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "مرحباً بك!",
      style: TextStyle(
        fontSize: 24.sp,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      "يجب تسجيل الدخول لعرض بيانات\nالملف الشخصي والاستمتاع بجميع المزايا",
      style: TextStyle(
        fontSize: 16.sp,
        color: ColorsManager.darkGray,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsManager.primaryGreen,
          elevation: 2,
          shadowColor: ColorsManager.primaryGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        onPressed: onLoginPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.rightToBracket,
              size: 18.sp,
              color: Colors.white,
            ),
            SizedBox(width: 10.w),
            Text(
              "تسجيل الدخول",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}