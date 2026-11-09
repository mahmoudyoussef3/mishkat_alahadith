import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/core/widgets/filter_pill.dart';
import 'package:mishkat_almasabih/core/widgets/search_bar_widget.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_search_results.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_search/quran_search_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/tafsir_search/quran_tafsir_search_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/models/mushaf_reader_args.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/search/quran_search_hit_tile.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/search/search_common.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/search/tafsir_search_view.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

/// Where the search looks.
enum _SearchMode {
  /// The words of the ayahs, on the device.
  text('في نص الآيات'),

  /// The words of a tafsir, online — finds ayahs by what they are about.
  tafsir('في التفسير');

  const _SearchMode(this.label);

  final String label;
}

/// Full-text search over every ayah — harakat and Uthmanic spelling are
/// optional: «الرحمن» finds «ٱلرَّحۡمَٰنِ» — or over a tafsir, online.
class QuranSearchScreen extends StatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  State<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  late final TextEditingController _controller;
  _SearchMode _mode = _SearchMode.text;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _searchFor(String query) {
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _search(query);
  }

  // Only the cubit of the mode shown is read: the tafsir search is opened
  // on demand.

  void _onQueryChanged(String query) => switch (_mode) {
    _SearchMode.text =>
      query.isEmpty
          ? context.read<QuranSearchCubit>().clear()
          : context.read<QuranSearchCubit>().onQueryChanged(query),
    _SearchMode.tafsir =>
      query.isEmpty
          ? context.read<QuranTafsirSearchCubit>().clear()
          : context.read<QuranTafsirSearchCubit>().onQueryChanged(query),
  };

  Future<void> _search(String query) => switch (_mode) {
    _SearchMode.text => context.read<QuranSearchCubit>().search(query),
    _SearchMode.tafsir => context.read<QuranTafsirSearchCubit>().search(query),
  };

  /// Shows the other kind of search, for the words already typed.
  void _setMode(_SearchMode mode) {
    if (mode == _mode) return;
    // The search left behind would otherwise still run once its typing
    // pause ran out — for the tafsir, a request no one would see.
    switch (_mode) {
      case _SearchMode.text:
        context.read<QuranSearchCubit>().clear();
      case _SearchMode.tafsir:
        context.read<QuranTafsirSearchCubit>().clear();
    }
    setState(() => _mode = mode);
    _search(_controller.text);
  }

  void _openAyah({required int page, required int ayahId, required int surah}) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.pushNamed(
      Routes.mushafReader,
      arguments: MushafReaderArgs(
        initialPage: page,
        highlightAyahId: ayahId,
        surahNumber: surah,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              DetailHeader(
                title: 'البحث في القرآن',
                subtitle: switch (_mode) {
                  _SearchMode.text =>
                    'في ${arabicCount(QuranMetrics.ayahCount, ArabicNoun.ayah)}'
                        '، بالتشكيل وبدونه',
                  _SearchMode.tafsir => 'في معاني الآيات من كتب التفسير',
                },
                bottom: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SearchBarWidget(
                      controller: _controller,
                      autofocus: true,
                      hintText: switch (_mode) {
                        _SearchMode.text => 'اكتب كلمة أو جزءًا من آية…',
                        _SearchMode.tafsir => 'اكتب موضوعًا أو كلمة…',
                      },
                      // Clearing the field returns to the suggestions at once.
                      onChanged: _onQueryChanged,
                      onSearch: _search,
                    ),
                    SizedBox(height: 10.h),
                    SegmentedTabs(
                      labels: [
                        for (final mode in _SearchMode.values) mode.label,
                      ],
                      selectedIndex: _mode.index,
                      onChanged: (i) => _setMode(_SearchMode.values[i]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch (_mode) {
                  _SearchMode.text => _textResults(),
                  _SearchMode.tafsir => TafsirSearchView(
                    onPick: _searchFor,
                    onOpenHit:
                        (hit) => _openAyah(
                          page: hit.ayah.page,
                          ayahId: hit.ayah.id,
                          surah: hit.ayah.surahNumber,
                        ),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textResults() {
    final cubit = context.read<QuranSearchCubit>();
    return BlocBuilder<QuranSearchCubit, QuranSearchState>(
      builder:
          (context, state) => switch (state) {
            QuranSearchIdle() => _SearchSuggestions(onPick: _searchFor),
            QuranSearchLoading() => const QuranSearchResultsShimmer(),
            QuranSearchEmpty(:final query) => QuranSearchCentered(
              child: StateMessage(
                icon: Icons.search_off_rounded,
                title: 'لا توجد نتائج',
                subtitle:
                    'لا توجد آيات تحتوي على «$query».\n'
                    'جرّب كلمة أقصر أو بصيغة أخرى.',
              ),
            ),
            QuranSearchFailure(:final query, :final message) =>
              QuranSearchCentered(
                child: StateMessage.error(
                  message: message,
                  onRetry: () => cubit.search(query),
                ),
              ),
            QuranSearchSuccess(:final results) => _SearchResults(
              results: results,
              onOpenAyah: _openAyah,
            ),
          },
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  static const List<String> _examples = [
    'الرحمن',
    'الصبر',
    'الجنة',
    'رب اغفر',
    'يا أيها الذين آمنوا',
    'الحمد لله',
  ];

  final ValueChanged<String> onPick;

  const _SearchSuggestions({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      children: [
        const StateMessage(
          icon: Icons.manage_search_rounded,
          title: 'اكتب كلمة أو جزءًا من آية',
          subtitle:
              'لا حاجة إلى التشكيل ولا إلى الرسم العثماني؛ '
              'تُطابَق الكلمات مهما اختلف رسمها.',
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
            for (final example in _examples)
              FilterPill(
                label: example,
                selected: false,
                onTap: () => onPick(example),
              ),
          ],
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final QuranSearchResults results;
  final void Function({
    required int page,
    required int ayahId,
    required int surah,
  })
  onOpenAyah;

  const _SearchResults({required this.results, required this.onOpenAyah});

  @override
  Widget build(BuildContext context) {
    final hits = results.hits;
    final total = arabicCount(results.totalMatches, ArabicNoun.ayah);
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      itemCount: hits.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
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
                  results.isTruncated
                      ? '$total · تُعرض أول ${toArabicNumerals(hits.length)}'
                      : total,
                  style: TextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
        final hit = hits[i - 1];
        return QuranSearchHitTile(
          hit: hit,
          onTap:
              () => onOpenAyah(
                page: hit.ayah.page,
                ayahId: hit.ayah.id,
                surah: hit.ayah.surahNumber,
              ),
        );
      },
    );
  }
}
