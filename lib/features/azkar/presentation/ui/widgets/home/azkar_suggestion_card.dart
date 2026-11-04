import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/hero_surface.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_suggestion.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_home/azkar_home_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_home_actions.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';

/// The chapter that suits the hour — the morning remembrances in the
/// morning, those before sleep at night — with how far today's count has
/// got.
class AzkarSuggestionCard extends StatelessWidget {
  const AzkarSuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarHomeCubit, AzkarHomeState>(
      buildWhen:
          (previous, current) =>
              previous is! AzkarHomeLoaded ||
              current is! AzkarHomeLoaded ||
              previous.suggestion != current.suggestion ||
              previous.progress != current.progress ||
              previous.categories != current.categories,
      builder: (context, state) {
        if (state is! AzkarHomeLoaded) return const SizedBox.shrink();
        final category = state.categoryById(state.suggestion.categoryId);
        if (category == null) return const SizedBox.shrink();
        return _SuggestionHero(
          timeOfDay: state.suggestion.timeOfDay,
          category: category,
          progress: state.progressOf(category),
        );
      },
    );
  }
}

class _SuggestionHero extends StatelessWidget {
  const _SuggestionHero({
    required this.timeOfDay,
    required this.category,
    required this.progress,
  });

  final AzkarTimeOfDay timeOfDay;
  final AzkarCategory category;
  final AzkarCategoryProgress progress;

  @override
  Widget build(BuildContext context) {
    final muted = ColorsManager.white.withValues(alpha: 0.78);
    final small = TextStyles.labelSmall.copyWith(
      fontWeight: FontWeight.w600,
      color: muted,
    );
    final percent = (progress.fraction * 100).round();
    void open() => openAzkarReader(context, categoryId: category.id);

    return Semantics(
      button: true,
      label: '${timeOfDay.label}: ${category.title}',
      onTap: open,
      excludeSemantics: true,
      child: HeroSurface(
        radius: 24.r,
        padding: EdgeInsets.all(20.r),
        imageOpacity: 0.28,
        onTap: open,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            timeOfDay.icon,
                            size: 16.r,
                            color: ColorsManager.goldBright,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              timeOfDay.label,
                              style: TextStyles.caption.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        category.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.screenTitle.copyWith(
                          fontSize: 22.sp,
                          color: ColorsManager.white,
                        ),
                      ),
                      Text(
                        '${arabicCount(category.azkar.length, ArabicNoun.zikr)}'
                        ' · $kHisnAlMuslim',
                        style: TextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.goldBright,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: ColorsManager.goldBright,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    progress.isComplete
                        ? Icons.done_all_rounded
                        : Icons.play_arrow_rounded,
                    size: 28.r,
                    color: ColorsManager.onGoldBright,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(3.r),
              child: LinearProgressIndicator(
                value: progress.fraction,
                minHeight: 6.h,
                color: ColorsManager.goldBright,
                backgroundColor: ColorsManager.white.withValues(alpha: 0.18),
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress.isComplete
                        ? 'أتممتها اليوم، تقبّل الله منك'
                        : progress.isStarted
                        ? 'أتممت ${toArabicDigits('${progress.completedAzkar}')}'
                            ' من ${toArabicDigits('${progress.totalAzkar}')}'
                        : 'لم تبدأ بعد اليوم',
                    style: small,
                  ),
                ),
                Text('${toArabicDigits('$percent')}٪', style: small),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
