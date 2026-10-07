import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/widgets/section_header.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/logic/random_ahadith_cubit.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/ui/widgets/compact_hadith_tile.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/presentation/ui/screens/hadith_result_details.dart';
import 'package:shimmer/shimmer.dart';

/// "أحاديث متنوعة": a refreshable selection of random hadiths, listed as
/// compact rows inside one card.
class RandomAhadithBlocBuilder extends StatelessWidget {
  const RandomAhadithBlocBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: BlocSelector<RandomAhadithCubit, RandomAhadithState, bool>(
            selector: (state) => state is RandomAhadithLoading,
            builder:
                (context, loading) => SectionHeader(
                  title: 'أحاديث متنوعة',
                  actionLabel: 'تحديث',
                  actionIcon: Icons.refresh_rounded,
                  onAction:
                      loading
                          ? null
                          : () =>
                              context
                                  .read<RandomAhadithCubit>()
                                  .emitRandomStats(),
                ),
          ),
        ),
        SliverToBoxAdapter(
          child: BlocBuilder<RandomAhadithCubit, RandomAhadithState>(
            builder:
                (context, state) => switch (state) {
                  RandomAhadithSuccess(:final hadiths) when hadiths.isEmpty =>
                    const StateMessage(
                      icon: Icons.menu_book_rounded,
                      title: 'لا توجد أحاديث لعرضها الآن',
                    ),
                  RandomAhadithSuccess(:final hadiths) => _HadithGroup(
                    hadiths: hadiths,
                  ),
                  RandomAhaditFailure(:final errMessage) => StateMessage.error(
                    message: errMessage,
                    onRetry:
                        () =>
                            context
                                .read<RandomAhadithCubit>()
                                .emitRandomStats(),
                  ),
                  _ => const _HadithGroupShimmer(),
                },
          ),
        ),
      ],
    );
  }
}

/// The bordered card that groups the rows, with hairlines between them.
class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Material(
        color: palette.cardBackground,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
          side: BorderSide(color: palette.border),
        ),
        child: child,
      ),
    );
  }
}

class _HadithGroup extends StatelessWidget {
  const _HadithGroup({required this.hadiths});

  final List<ExplainedHadith> hadiths;

  void _open(BuildContext context, ExplainedHadith hadith) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HadithResultDetails(enhancedHadithModel: hadith),
    ),
  );

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// Who reported it ("رواه مسلم"), else the reference, which is often a
  /// long bibliography and only a fallback for a one-line source.
  static String? _source(ExplainedHadith hadith) {
    final source = _nonEmpty(hadith.attribution) ?? _nonEmpty(hadith.reference);
    return source == null ? null : toArabicDigits(source);
  }

  static String _preview(ExplainedHadith hadith) {
    final matn = HadithTextParts.split(hadith.hadeeth ?? '').matn;
    return matn.isEmpty ? 'نص الحديث غير متوفر' : matn;
  }

  @override
  Widget build(BuildContext context) {
    final divider = AppPaletteOverride.of(context).lightGray;

    return _GroupCard(
      child: Column(
        children: [
          for (final (index, hadith) in hadiths.indexed) ...[
            if (index > 0) Divider(height: 1, thickness: 1, color: divider),
            CompactHadithTile(
              text: _preview(hadith),
              category: _nonEmpty(hadith.categories?.firstOrNull),
              grade: HadithGrade.tryParse(hadith.grade),
              source: _source(hadith),
              onTap: () => _open(context, hadith),
            ),
          ],
        ],
      ),
    );
  }
}

class _HadithGroupShimmer extends StatelessWidget {
  const _HadithGroupShimmer();

  static const _rows = 3;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);

    return _GroupCard(
      child: Shimmer.fromColors(
        baseColor: palette.shimmerBase,
        highlightColor: palette.shimmerHighlight,
        child: Column(
          children: [
            for (var index = 0; index < _rows; index++) ...[
              if (index > 0)
                Divider(height: 1, thickness: 1, color: palette.lightGray),
              const _SkeletonRow(),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    final color = AppPaletteOverride.of(context).shimmerBase;

    Widget line(double widthFactor, double height) => FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 70.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              children: [
                line(1, 14.h),
                SizedBox(height: 14.h),
                line(0.75, 14.h),
                SizedBox(height: 12.h),
                line(0.45, 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
