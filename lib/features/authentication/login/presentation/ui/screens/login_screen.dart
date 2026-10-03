import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/authentication/login/ui/widgets/login_as_guest_button.dart';
import '../../../../../core/theming/colors.dart';
import '../widgets/don`t_have_account_text.dart';
import '../widgets/email_and_password.dart';
import '../widgets/login_bloc_listener.dart';
import '../widgets/login_screen_header.dart';
import '../widgets/login_with_google.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
           
        backgroundColor: ColorsManager.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top spacing
              SizedBox(height: 40.h),
              
              // App Logo and Title
              LoginScreenHeader(),
              
              SizedBox(height: 40.h),
              
              // Login Form
              EmailAndPassword(),
              
              SizedBox(height: 22.h),
              
               
              
              // Login Button
              LoginBlocListener(),
              SizedBox(height: 16.h),
              
              // Divider
              _buildDivider(),
              
              SizedBox(height: 16.h),
              
              // Don't have account
              const DontHaveAccountText(),
              
              SizedBox(height: 16.h),
              
              LoginWithGoogle(),
              SizedBox(height: 16.h),
LoginAsGuestButton(
  onTap: () {
     context.pushNamedAndRemoveUntil(Routes.homeScreen, predicate: (route) => false );
  },
),
              
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: ColorsManager.mediumGray)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'أو',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: ColorsManager.secondaryText,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: ColorsManager.mediumGray)),
      ],
    ).animate().fadeIn(delay: 1000.ms, duration: 300.ms).scaleX(begin: 0.0);
  }
}
