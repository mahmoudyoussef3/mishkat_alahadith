import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import '../cubit/ramadan_tasks_cubit.dart';

/// Error state view with message and retry button.
class RamadanErrorView extends StatelessWidget {
  final String message;

  const RamadanErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48.sp,
            color: ColorsManager.error,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyles.bodyMedium.copyWith(color: ColorsManager.error),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryPurple,
              foregroundColor: ColorsManager.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () => context.read<RamadanTasksCubit>().init(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'إعادة المحاولة',
              style: TextStyles.titleSmall.copyWith(color: ColorsManager.white),
            ),
          ),
        ],
      ),
    );
  }
}
