import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../cubit/ramadan_tasks_cubit.dart';

/// Error state view with message and retry button.
/// Enhanced with animations and better visual feedback.
class RamadanErrorView extends StatelessWidget {
  final String message;

  const RamadanErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated error icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: ColorsManager.error.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorsManager.error.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 40.sp,
                    color: ColorsManager.error,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Error message
              Text(
                'حدث خطأ',
                style: TextStyles.titleLarge.copyWith(
                  color: ColorsManager.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyles.bodyMedium.copyWith(
                  color: ColorsManager.secondaryText,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              // Retry button
              _RetryButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated retry button with hover effect
class _RetryButton extends StatefulWidget {
  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () => context.read<RamadanTasksCubit>().init(),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 28.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ColorsManager.primaryPurple, ColorsManager.darkPurple],
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.primaryPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, color: ColorsManager.white),
                SizedBox(width: 8.w),
                Text(
                  'إعادة المحاولة',
                  style: TextStyles.titleSmall.copyWith(
                    color: ColorsManager.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
