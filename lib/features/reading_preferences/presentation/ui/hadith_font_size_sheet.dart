import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/entities/hadith_font_scale.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/logic/hadith_font_scale_cubit.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/ui/hadith_text.dart';

extension HadithFontScaleLabel on HadithFontScale {
  String get label => switch (this) {
    HadithFontScale.small => 'صغير',
    HadithFontScale.medium => 'متوسط',
    HadithFontScale.large => 'كبير',
    HadithFontScale.extraLarge => 'كبير جداً',
  };

  /// Short form for the segmented control.
  String get shortLabel => switch (this) {
    HadithFontScale.extraLarge => 'أكبر',
    _ => label,
  };
}

/// Lets the reader pick the hadith text size, with a live preview.
Future<void> showHadithFontSizeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder:
        (_) => const Directionality(
          textDirection: TextDirection.rtl,
          child: _HadithFontSizeSheet(),
        ),
  );
}

class _HadithFontSizeSheet extends StatelessWidget {
  const _HadithFontSizeSheet();

  static const _sample =
      '«إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى»';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('حجم خط الحديث', style: TextStyles.sectionTitle),
            Text(
              'يُطبَّق على نصوص الأحاديث في جميع الشاشات',
              style: TextStyles.caption.copyWith(fontSize: 13.sp),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: ColorsManager.cardBackground,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: ColorsManager.border),
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.topCenter,
                child: HadithText(
                  _sample,
                  style: TextStyles.hadithPreview.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            BlocBuilder<HadithFontScaleCubit, HadithFontScale>(
              builder: (context, scale) {
                final cubit = context.read<HadithFontScaleCubit>();
                return Row(
                  children: [
                    AppIconButton(
                      tooltip: 'تصغير الخط',
                      icon: Icons.text_decrease_rounded,
                      onPressed: scale.isSmallest ? null : cubit.decrease,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: SegmentedTabs(
                        labels: [
                          for (final option in HadithFontScale.values)
                            option.shortLabel,
                        ],
                        selectedIndex: scale.index,
                        onChanged:
                            (index) =>
                                cubit.select(HadithFontScale.values[index]),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    AppIconButton(
                      tooltip: 'تكبير الخط',
                      icon: Icons.text_increase_rounded,
                      onPressed: scale.isLargest ? null : cubit.increase,
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16.h),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('تم'),
            ),
          ],
        ),
      ),
    );
  }
}
