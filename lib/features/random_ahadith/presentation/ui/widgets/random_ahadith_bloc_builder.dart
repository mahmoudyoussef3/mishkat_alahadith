import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/widgets/section_header.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/logic/random_ahadith_cubit.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/ui/widgets/compact_hadith_tile.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/presentation/ui/screens/hadith_result_details.dart';
import 'package:shimmer/shimmer.dart';

/// "أحاديث متنوعة": a refreshable selection of random hadiths, each in its
/// own card.
class RandomAhadithBlocBuilder extends StatelessWidget {
  const RandomAhadithBlocBuilder({super.key});

  static const _switchDuration = Duration(milliseconds: 250);

  /// Pins outgoing and incoming content to the top while they cross-fade.
  /// The outgoing one can no longer be tapped or read out.
  static Widget _topAligned(Widget? current, List<Widget> previous) => Stack(
    alignment: Alignment.topCenter,
    children: [
      for (final child in previous)
        IgnorePointer(child: ExcludeSemantics(child: child)),
      if (current != null) current,
    ],
  );

  static bool _isLoading(RandomAhadithState state) => switch (state) {
    RandomAhadithLoading() => true,
    RandomAhadithSuccess(:final refreshing) => refreshing,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: BlocSelector<RandomAhadithCubit, RandomAhadithState, bool>(
            selector: _isLoading,
            builder:
                (context, loading) => SectionHeader(
                  title: 'أحاديث متنوعة',
                  actionLabel: 'تحديث',
                  actionIcon: Icons.refresh_rounded,
                  actionBusy: loading,
                  onAction:
                      () =>
                          context.read<RandomAhadithCubit>().emitRandomStats(),
                ),
          ),
        ),
        SliverToBoxAdapter(
          child: BlocListener<RandomAhadithCubit, RandomAhadithState>(
            listenWhen:
                (_, current) =>
                    current is RandomAhadithSuccess &&
                    current.refreshFailure != null,
            listener:
                (context, state) => showInfoSnackbar(
                  context,
                  (state as RandomAhadithSuccess).refreshFailure!,
                ),
            child: BlocBuilder<RandomAhadithCubit, RandomAhadithState>(
              // A refresh that starts or fails leaves the same hadiths on
              // screen, so there is nothing to rebuild.
              buildWhen:
                  (previous, current) =>
                      previous is! RandomAhadithSuccess ||
                      current is! RandomAhadithSuccess ||
                      !identical(previous.hadiths, current.hadiths),
              builder:
                  (context, state) => AnimatedSwitcher(
                    duration: _switchDuration,
                    layoutBuilder: _topAligned,
                    child: switch (state) {
                      RandomAhadithSuccess(:final hadiths)
                          when hadiths.isEmpty =>
                        const StateMessage(
                          key: ValueKey('empty'),
                          icon: Icons.menu_book_rounded,
                          title: 'لا توجد أحاديث لعرضها الآن',
                        ),
                      RandomAhadithSuccess(:final hadiths) => _HadithList(
                        key: ObjectKey(hadiths),
                        hadiths: hadiths,
                      ),
                      RandomAhaditFailure(:final errMessage) =>
                        StateMessage.error(
                          key: const ValueKey('error'),
                          message: errMessage,
                          onRetry:
                              () =>
                                  context
                                      .read<RandomAhadithCubit>()
                                      .emitRandomStats(),
                        ),
                      _ => const _HadithListShimmer(),
                    },
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HadithList extends StatelessWidget {
  const _HadithList({super.key, required this.hadiths});

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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          for (final (index, hadith) in hadiths.indexed) ...[
            if (index > 0) SizedBox(height: 12.h),
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

class _HadithListShimmer extends StatelessWidget {
  const _HadithListShimmer();

  static const _cards = 3;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          for (var index = 0; index < _cards; index++) ...[
            if (index > 0) SizedBox(height: 12.h),
            const _SkeletonCard(),
          ],
        ],
      ),
    );
  }
}

/// Placeholder in the shape of a [CompactHadithTile]: badges, three lines
/// of text and the footer.
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);

    Widget block(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: palette.shimmerBase,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );

    Widget line(double widthFactor) => FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: block(double.infinity, 14.h),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      // Only the blocks shimmer; the card itself stays put.
      child: Shimmer.fromColors(
        baseColor: palette.shimmerBase,
        highlightColor: palette.shimmerHighlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [block(88.w, 22.h), const Spacer(), block(44.w, 22.h)],
            ),
            SizedBox(height: 16.h),
            line(1),
            SizedBox(height: 16.h),
            line(0.92),
            SizedBox(height: 16.h),
            line(0.6),
            SizedBox(height: 18.h),
            Row(
              children: [block(96.w, 10.h), const Spacer(), block(72.w, 10.h)],
            ),
          ],
        ),
      ),
    );
  }
}
