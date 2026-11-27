import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/filter_pill.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition_search.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_editions/quran_editions_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/tafsir_search/quran_tafsir_search_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/edition_picker_sheet.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

import 'search_common.dart';

/// Searching the reader's tafsir: which tafsir, and the ayahs it finds.
class TafsirSearchView extends StatelessWidget {
  /// Opens the mushaf at a found ayah.
  final ValueChanged<EditionSearchHit> onOpenHit;

  /// Searches for a suggested topic as if typed.
  final ValueChanged<String> onPick;

  const TafsirSearchView({
    super.key,
    required this.onOpenHit,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuranEditionsCubit>()..load(QuranEditionType.tafsir),
      child: Column(
        children: [
          const _TafsirChooser(),
          Expanded(
            child: BlocBuilder<QuranTafsirSearchCubit, QuranTafsirSearchState>(
              builder: (context, state) {
                final cubit = context.read<QuranTafsirSearchCubit>();
                return switch (state) {
                  QuranTafsirSearchIdle() => _Suggestions(onPick: onPick),
                  QuranTafsirSearchLoading() =>
                    const QuranSearchResultsShimmer(),
                  QuranTafsirSearchEmpty(:final query) => QuranSearchCentered(
                    child: StateMessage(
                      icon: Icons.search_off_rounded,
                      title: 'لا توجد نتائج',
                      subtitle:
                          'لم يرد «$query» في هذا التفسير.\n'
                          'جرّب كلمة أخرى أو تفسيرًا آخر.',
                    ),
                  ),
                  QuranTafsirSearchFailure(:final query, :final message) =>
                    QuranSearchCentered(
                      child: StateMessage.error(
                        message: message,
                        onRetry: () => cubit.search(query),
                      ),
                    ),
                  QuranTafsirSearchSuccess() => _Results(
                    state: state,
                    onOpenHit: onOpenHit,
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// «البحث في: التفسير الميسر», tapped to search another tafsir.
class _TafsirChooser extends StatelessWidget {
  const _TafsirChooser();

  @override
  Widget build(BuildContext context) {
    final tafsirId = context.select<QuranTafsirSearchCubit, String>(
      (cubit) => cubit.state.tafsirId,
    );
    final name = context.select<QuranEditionsCubit, String?>(
      (cubit) => switch (cubit.state) {
        QuranEditionsLoaded state => state.find(tafsirId)?.name,
        _ => null,
      },
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      child: Row(
        children: [
          Text(
            'البحث في:',
            style: TextStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: ActionChip(
              avatar: const Icon(Icons.menu_book_rounded, size: 18),
              label: Text(
                name ?? 'التفسير',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () => _pick(context, tafsirId),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context, String current) {
    final cubit = context.read<QuranTafsirSearchCubit>();
    return pickEdition(
      context,
      type: QuranEditionType.tafsir,
      selectedId: current,
      apply: (edition) => cubit.setTafsir(edition!),
    );
  }
}

class _Suggestions extends StatelessWidget {
  static const List<String> _topics = [
    'الربا',
    'بر الوالدين',
    'الصبر',
    'التوبة',
    'الصدقة',
    'اليتيم',
  ];

  final ValueChanged<String> onPick;

  const _Suggestions({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      children: [
        const StateMessage(
          icon: Icons.travel_explore_rounded,
          title: 'ابحث في معاني الآيات',
          subtitle:
              'اكتب موضوعًا أو كلمة، فتظهر الآيات التي يذكرها تفسيرها '
              'وإن لم ترد الكلمة في نصها. يحتاج البحث إلى الإنترنت.',
        ),
        Text(
          'جرّب',
          textAlign: TextAlign.center,
          style: TextStyles.caption.copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final topic in _topics)
              FilterPill(
                label: topic,
                selected: false,
                onTap: () => onPick(topic),
              ),
          ],
        ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  final QuranTafsirSearchSuccess state;
  final ValueChanged<EditionSearchHit> onOpenHit;

  const _Results({required this.state, required this.onOpenHit});

  @override
  Widget build(BuildContext context) {
    final hits = state.hits;
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      itemCount: hits.length + 2,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      'النتائج',
                      style: TextStyles.sectionTitle.copyWith(fontSize: 16.sp),
                    ),
                  ),
                ),
                Text(
                  arabicCount(state.total, ArabicNoun.ayah),
                  style: TextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
        if (i <= hits.length) {
          final hit = hits[i - 1];
          return _HitTile(hit: hit, onTap: () => onOpenHit(hit));
        }
        return _Footer(state: state);
      },
    );
  }
}

class _Footer extends StatelessWidget {
  final QuranTafsirSearchSuccess state;

  const _Footer({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuranTafsirSearchCubit>();
    final failure = state.loadMoreFailure;
    if (failure != null) {
      return StateMessage.error(message: failure, onRetry: cubit.loadMore);
    }
    if (!state.hasMore) return SizedBox(height: 8.h);
    // Reached the end of what is loaded: fetch the next page.
    if (!state.isLoadingMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) => cubit.loadMore());
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

/// A found ayah, with the part of its tafsir that mentions the query.
class _HitTile extends StatelessWidget {
  final EditionSearchHit hit;
  final VoidCallback onTap;

  const _HitTile({required this.hit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ayah = hit.ayah;
    final mark = TextStyle(
      backgroundColor: ColorsManager.primaryGold.withValues(alpha: 0.28),
      fontWeight: FontWeight.w700,
    );
    return Material(
      color: ColorsManager.cardBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: ColorsManager.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AppBadge.tag(
                        '${hit.surahName} · ${toArabicNumerals(ayah.number)}',
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'ص ${toArabicNumerals(ayah.page)}',
                    style: TextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                ayah.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: QuranTextStyles.mushafText(
                  color: ColorsManager.primaryText,
                  size: 18.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text.rich(
                styledRanges(
                  text: hit.excerpt,
                  base: TextStyles.caption.copyWith(
                    fontSize: 13.5.sp,
                    height: 1.8,
                    color: ColorsManager.secondaryText,
                  ),
                  ranges: [
                    for (final match in hit.matches)
                      (start: match.start, end: match.end, style: mark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
