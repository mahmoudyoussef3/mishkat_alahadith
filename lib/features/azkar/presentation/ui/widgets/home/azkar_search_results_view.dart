import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_search_results.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_home/azkar_home_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_home_actions.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/common/azkar_category_row.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/common/azkar_list.dart';

/// Chapters and azkar matching the query, as a sliver.
class AzkarSearchResultsView extends StatelessWidget {
  const AzkarSearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarHomeCubit, AzkarHomeState>(
      buildWhen:
          (previous, current) =>
              previous is! AzkarHomeLoaded ||
              current is! AzkarHomeLoaded ||
              previous.searchResults != current.searchResults ||
              previous.progress != current.progress ||
              !listEquals(previous.favoriteIds, current.favoriteIds),
      builder: (context, state) {
        final results = state is AzkarHomeLoaded ? state.searchResults : null;
        if (state is! AzkarHomeLoaded || results == null) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        if (results.isEmpty) {
          return SliverToBoxAdapter(
            child: StateMessage(
              icon: Icons.search_off_rounded,
              title: 'لا توجد نتائج',
              subtitle: 'لم نجد باباً أو ذكراً يطابق «${results.query}»',
            ),
          );
        }

        final categories = results.categories;
        final hits = results.hits;
        return SliverMainAxisGroup(
          slivers: [
            if (categories.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: AzkarListHeader(
                  title: 'الأبواب',
                  count: arabicCount(categories.length, ArabicNoun.chapter),
                ),
              ),
              AzkarListCard(
                sliver: SliverList.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final category = categories[i];
                    return AzkarCategoryRow(
                      category: category,
                      number: state.numberOf(category),
                      progress: state.progressOf(category),
                      isFavorite: state.isFavorite(category.id),
                      isFirst: i == 0,
                      isLast: i == categories.length - 1,
                      onTap:
                          () =>
                              openAzkarReader(context, categoryId: category.id),
                      onToggleFavorite:
                          () => toggleAzkarFavorite(context, category.id),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            ],
            if (hits.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: AzkarListHeader(
                  title: 'الأذكار',
                  count:
                      results.isTruncated
                          ? 'أول ${toArabicDigits('${hits.length}')} من '
                              '${toArabicDigits('${results.totalHits}')}'
                          : arabicCount(hits.length, ArabicNoun.zikr),
                ),
              ),
              SliverList.separated(
                itemCount: hits.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (context, i) => _ZikrHitCard(hit: hits[i]),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ZikrHitCard extends StatelessWidget {
  const _ZikrHitCard({required this.hit});

  final AzkarSearchHit hit;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final translation = hit.zikr.translation;
    return Material(
      color: palette.cardBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(color: palette.border),
      ),
      child: InkWell(
        onTap:
            () => openAzkarReader(
              context,
              categoryId: hit.category.id,
              zikrId: hit.zikr.id,
            ),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBadge.tag(hit.category.title),
              SizedBox(height: 8.h),
              Text(
                hit.zikr.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.readingMedium.copyWith(
                  fontSize: 16.sp,
                  height: 1.9,
                  color: palette.primaryText,
                ),
              ),
              if (translation != null)
                Text(
                  translation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: TextStyles.caption.copyWith(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: palette.secondaryText,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
