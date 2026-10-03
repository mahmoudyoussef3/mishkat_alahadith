import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mishkat_almasabih/features/authentication/signup/ui/widgets/already_have_account.dart';
import 'package:mishkat_almasabih/features/authentication/signup/ui/widgets/build_signup_header.dart';
import 'package:mishkat_almasabih/features/authentication/signup/ui/widgets/build_welcome_message.dart';
import 'package:mishkat_almasabih/features/authentication/signup/ui/widgets/sign_up_form.dart';
import 'package:mishkat_almasabih/features/authentication/signup/ui/widgets/signup_bloc_listener.dart';
import '../../../../../core/theming/colors.dart';


class SignupScreen extends StatelessWidget {
   const SignupScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                               SizedBox(height: 40.h),

              BuildSignupHeader(),
          
              SizedBox(height: 24.h),
          
              BuildWelcomeMessage(),
          
              SizedBox(height: 32.h),
          
              SignupForm(),
          
              SizedBox(height: 32.h),
          
              SignupBlocListener(),
          
              SizedBox(height: 24.h),
          
              _buildDivider(),
          
              SizedBox(height: 24.h),
          
              AlreadyHaveAccount(),
                 //       SizedBox(height: 8.h),
         //     LoginWithGoogle(),
          
              SizedBox(height: 40.h),
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
