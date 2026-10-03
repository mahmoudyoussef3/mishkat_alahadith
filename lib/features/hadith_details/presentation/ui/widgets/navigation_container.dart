import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/loading_progress_indicator.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_decorations.dart';
import 'package:mishkat_almasabih/core/theming/hadith_details_styles.dart';

class NavigationContainer extends StatelessWidget {
  final bool isLoading;
  final String hadithId;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const NavigationContainer({
    super.key,
    required this.isLoading,
    required this.hadithId,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: HadithDetailsDecorations.actionRow(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: onPrev,
            color: onPrev == null ? Colors.grey : ColorsManager.primaryPurple,
          ),
          isLoading
              ? Row(
                children: [
                  loadingProgressIndicator(size: 16),
                  SizedBox(width: 8.w),
                  Text(
                    "جاري التحميل...",
                    style: HadithDetailsTextStyles.navigationLabel,
                  ),
                ],
              )
              : Text(
                "الحديث رقم $hadithId",
                style: HadithDetailsTextStyles.navigationLabel,
              ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: onNext,
            color: onNext == null ? Colors.grey : ColorsManager.primaryPurple,
          ),
        ],
      ),
    );
  }
}
