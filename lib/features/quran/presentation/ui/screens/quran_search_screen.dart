import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_search_results.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_search/quran_search_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/models/mushaf_reader_args.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_message_view.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/search/quran_search_hit_tile.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        appBar: AppBar(
          backgroundColor: ColorsManager.primaryPurple,
          foregroundColor: ColorsManager.white,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 0,
          title: _SearchField(controller: _controller),
        ),
        body: BlocBuilder<QuranSearchCubit, QuranSearchState>(
          builder:
              (context, state) => switch (state) {
                QuranSearchIdle() => _SearchSuggestions(onPick: _searchFor),
                QuranSearchLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                QuranSearchEmpty(:final query) => QuranMessageView(
                  colors: QuranSurfaceColors.app(),
                  icon: Icons.search_off_rounded,
                  message:
                      'لا توجد آيات تحتوي على «$query».\n'
                      'جرّب كلمة أقصر أو بصيغة أخرى.',
                ),
                QuranSearchFailure(:final query, :final message) =>
                  QuranMessageView(
                    colors: QuranSurfaceColors.app(),
                    icon: Icons.error_outline_rounded,
                    message: message,
                    actionLabel: 'إعادة المحاولة',
                    onAction:
                        () => context.read<QuranSearchCubit>().search(query),
                  ),
                QuranSearchSuccess(:final results) => _SearchResults(
                  results: results,
                ),
              },
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuranSearchCubit>();
    return Container(
      height: 44.h,
      margin: EdgeInsetsDirectional.only(end: 12.w),
      decoration: QuranDecorations.searchField(),
      child: TextField(
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        cursorColor: ColorsManager.white,
        style: QuranTextStyles.searchField,
        onChanged: cubit.onQueryChanged,
        onSubmitted: cubit.search,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'ابحث في آيات القرآن الكريم…',
          hintStyle: QuranTextStyles.searchHint,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: ColorsManager.white,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder:
                (context, value, _) =>
                    value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                          tooltip: 'مسح',
                          icon: const Icon(
                            Icons.close_rounded,
                            color: ColorsManager.white,
                          ),
                          onPressed: () {
                            controller.clear();
                            cubit.clear();
                          },
                        ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
      ),
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
    final colors = QuranSurfaceColors.app();
    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        Icon(
          Icons.manage_search_rounded,
          size: 56.sp,
          color: colors.accent.withValues(alpha: 0.5),
        ),
        SizedBox(height: 12.h),
        Text(
          'اكتب كلمة أو جزءًا من آية',
          textAlign: TextAlign.center,
          style: QuranTextStyles.sectionTitle(colors.title),
        ),
        SizedBox(height: 6.h),
        Text(
          'لا حاجة إلى التشكيل ولا إلى الرسم العثماني؛ '
          'تُطابَق الكلمات مهما اختلف رسمها.',
          textAlign: TextAlign.center,
          style: QuranTextStyles.sectionHint(colors.subtitle),
        ),
        SizedBox(height: 20.h),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final example in _examples)
              ActionChip(
                label: Text(example),
                labelStyle: QuranTextStyles.chip(colors.accent),
                backgroundColor: colors.surface,
                side: BorderSide(color: colors.border),
                onPressed: () => onPick(example),
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
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: hits.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, i) {
        if (i == 0) {
          final total = toArabicNumerals(results.totalMatches);
          return Text(
            results.isTruncated
                ? '$total آية — تُعرض أول ${toArabicNumerals(hits.length)}'
                : '$total آية',
            style: QuranTextStyles.searchSummary,
          );
        }
        final hit = hits[i - 1];
        return QuranSearchHitTile(
          hit: hit,
          onTap:
              () => context.pushNamed(
                Routes.mushafReader,
                arguments: MushafReaderArgs(
                  initialPage: hit.ayah.page,
                  highlightAyahId: hit.ayah.id,
                ),
              ),
        );
      },
    );
  }
}
