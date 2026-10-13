import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/hero_surface.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_juz.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_index/quran_index_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;
import 'package:shimmer/shimmer.dart';

/// Takes the reader back to the page they stopped on and shows how far
/// through the mushaf it is, or invites them to start from Al-Fātiḥah the
/// first time.
class ContinueReadingCard extends StatelessWidget {
  final ValueChanged<int> onOpenPage;

  const ContinueReadingCard({super.key, required this.onOpenPage});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranIndexCubit, QuranIndexState>(
      buildWhen:
          (previous, current) =>
              previous.runtimeType != current.runtimeType ||
              (previous is QuranIndexLoaded &&
                  current is QuranIndexLoaded &&
                  (previous.lastRead?.page != current.lastRead?.page ||
                      previous.lastReadInfo != current.lastReadInfo)),
      builder:
          (context, state) => switch (state) {
            QuranIndexLoading() => const _HeroShimmer(),
            QuranIndexFailure() => const SizedBox.shrink(),
            QuranIndexLoaded() => _ContinueReadingHero(
              state: state,
              onOpenPage: onOpenPage,
            ),
          },
    );
  }
}

class _ContinueReadingHero extends StatelessWidget {
  final QuranIndexLoaded state;
  final ValueChanged<int> onOpenPage;

  const _ContinueReadingHero({required this.state, required this.onOpenPage});

  @override
  Widget build(BuildContext context) {
    final lastRead = state.lastRead;
    final page = lastRead?.page ?? QuranMetrics.firstPage;
    final surah = state.resumeSurah;
    final juz =
        state.lastReadInfo?.juz ??
        QuranJuz.containingPage(state.juzList, page)?.number;
    final title = surah == null ? 'القرآن الكريم' : 'سورة ${surah.nameArabic}';

    final muted = ColorsManager.white.withValues(alpha: 0.78);
    final small = TextStyles.labelSmall.copyWith(
      fontWeight: FontWeight.w600,
      color: muted,
    );

    return Semantics(
      button: true,
      label:
          lastRead == null
              ? 'ابدأ القراءة من $title'
              : 'تابع القراءة: $title، الصفحة ${toArabicNumerals(page)}',
      onTap: () => onOpenPage(page),
      excludeSemantics: true,
      child: HeroSurface(
        radius: 24.r,
        padding: EdgeInsets.all(20.r),
        imageOpacity: 0.28,
        onTap: () => onOpenPage(page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastRead == null
                            ? 'ابدأ رحلتك مع كتاب الله'
                            : 'تابع من حيث توقفت',
                        style: TextStyles.caption.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: muted,
                        ),
                      ),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.screenTitle.copyWith(
                          color: ColorsManager.white,
                        ),
                      ),
                      Text(
                        juz == null
                            ? 'الصفحة ${toArabicNumerals(page)}'
                            : juzTitle(juz),
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
                    lastRead == null
                        ? Icons.auto_stories_rounded
                        : Icons.play_arrow_rounded,
                    size: 28.r,
                    color: ColorsManager.onGoldBright,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            if (lastRead == null)
              Text(
                [
                  arabicCount(QuranMetrics.surahCount, ArabicNoun.surah),
                  arabicCount(QuranMetrics.juzCount, ArabicNoun.juz),
                  arabicCount(QuranMetrics.pageCount, ArabicNoun.page),
                ].join(' · '),
                style: small,
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: LinearProgressIndicator(
                  value: page / QuranMetrics.pageCount,
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
                      'الصفحة ${toArabicNumerals(page)} من '
                      '${toArabicNumerals(QuranMetrics.pageCount)}',
                      style: small,
                    ),
                  ),
                  Text(
                    '${toArabicNumerals(page * 100 ~/ QuranMetrics.pageCount)}٪'
                    ' من المصحف',
                    style: small,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroShimmer extends StatelessWidget {
  const _HeroShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorsManager.shimmerBase,
      highlightColor: ColorsManager.shimmerHighlight,
      child: Container(
        height: 150.h,
        decoration: BoxDecoration(
          color: ColorsManager.shimmerBase,
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
    );
  }
}
