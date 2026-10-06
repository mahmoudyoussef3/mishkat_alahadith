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
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_search_results.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_search/quran_search_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/models/mushaf_reader_args.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/search/quran_search_hit_tile.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;
import 'package:shimmer/shimmer.dart';

/// Full-text search over every ayah. Harakat and Uthmanic spelling are
/// optional: «الرحمن» finds «ٱلرَّحۡمَٰنِ».
class QuranSearchScreen extends StatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  State<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  late final TextEditingController _controller;

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
    context.read<QuranSearchCubit>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuranSearchCubit>();
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
                subtitle:
                    'في ${arabicCount(QuranMetrics.ayahCount, ArabicNoun.ayah)}'
                    '، بالتشكيل وبدونه',
                bottom: SearchBarWidget(
                  controller: _controller,
                  autofocus: true,
                  hintText: 'اكتب كلمة أو جزءًا من آية…',
                  // Clearing the field returns to the suggestions at once.
                  onChanged:
                      (query) =>
                          query.isEmpty
                              ? cubit.clear()
                              : cubit.onQueryChanged(query),
                  onSearch: cubit.search,
                ),
              ),
              Expanded(
                child: BlocBuilder<QuranSearchCubit, QuranSearchState>(
                  builder:
                      (context, state) => switch (state) {
                        QuranSearchIdle() => _SearchSuggestions(
                          onPick: _searchFor,
                        ),
                        QuranSearchLoading() => const _ResultsShimmer(),
                        QuranSearchEmpty(:final query) => _Centered(
                          child: StateMessage(
                            icon: Icons.search_off_rounded,
                            title: 'لا توجد نتائج',
                            subtitle:
                                'لا توجد آيات تحتوي على «$query».\n'
                                'جرّب كلمة أقصر أو بصيغة أخرى.',
                          ),
                        ),
                        QuranSearchFailure(:final query, :final message) =>
                          _Centered(
                            child: StateMessage.error(
                              message: message,
                              onRetry: () => cubit.search(query),
                            ),
                          ),
                        QuranSearchSuccess(:final results) => _SearchResults(
                          results: results,
                        ),
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A state message that stays reachable above the keyboard.
class _Centered extends StatelessWidget {
  final Widget child;

  const _Centered({required this.child});

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(top: 24.h),
      children: [child],
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

  const _SearchResults({required this.results});

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
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            context.pushNamed(
              Routes.mushafReader,
              arguments: MushafReaderArgs(
                initialPage: hit.ayah.page,
                highlightAyahId: hit.ayah.id,
              ),
            );
          },
        );
      },
    );
  }
}

/// Placeholder cards while the mushaf is searched.
class _ResultsShimmer extends StatelessWidget {
  const _ResultsShimmer();

  @override
  Widget build(BuildContext context) {
    final block = ColorsManager.shimmerBase;
    return Shimmer.fromColors(
      baseColor: ColorsManager.shimmerBase,
      highlightColor: ColorsManager.shimmerHighlight,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder:
            (context, index) => Container(
              height: 128.h,
              decoration: BoxDecoration(
                color: block,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
      ),
    );
  }
}
