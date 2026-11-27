import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/section_header.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/common/azkar_list.dart';
import 'package:shimmer/shimmer.dart';

import 'azkar_category_list.dart';
import 'azkar_collection_filter.dart';
import 'azkar_daily_grid.dart';
import 'azkar_favorites_section.dart';
import 'azkar_suggestion_card.dart';

/// Everything on the azkar home below the search field, while not
/// searching: the suggestion for the hour, the daily chapters, the
/// favourites and the whole book by theme.
class AzkarHomeSections extends StatelessWidget {
  const AzkarHomeSections({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
          sliver: const SliverToBoxAdapter(child: AzkarSuggestionCard()),
        ),
        const SliverToBoxAdapter(child: SectionHeader(title: 'أذكار اليوم')),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: const SliverToBoxAdapter(child: AzkarDailyGrid()),
        ),
        const SliverToBoxAdapter(child: AzkarFavoritesSection()),
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'أبواب حصن المسلم'),
        ),
        const SliverToBoxAdapter(child: AzkarCollectionFilter()),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          sliver: const AzkarCategoryList(),
        ),
        const SliverToBoxAdapter(child: AzkarSourceNote()),
      ],
    );
  }
}

/// Where the text and the recitations come from.
class AzkarSourceNote extends StatelessWidget {
  const AzkarSourceNote({super.key});

  @override
  Widget build(BuildContext context) {
    final style = TextStyles.caption.copyWith(
      height: 1.7,
      color: AppPaletteOverride.of(context).secondaryText,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 0),
      child: Column(
        children: [
          Text(
            'الأذكار من كتاب «$kHisnAlMuslim» للشيخ سعيد بن علي بن وهف '
            'القحطاني، والتلاوات $kAzkarReciter.',
            textAlign: TextAlign.center,
            style: style,
          ),
          Text(
            'Islamic Pro Azkar API · MIT',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: style,
          ),
        ],
      ),
    );
  }
}

/// Placeholders for the suggestion card and the chapter list while the book
/// loads.
class AzkarHomeShimmer extends StatelessWidget {
  const AzkarHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: ColorsManager.shimmerBase,
              highlightColor: ColorsManager.shimmerHighlight,
              child: Container(
                height: 160.h,
                decoration: BoxDecoration(
                  color: ColorsManager.shimmerBase,
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          const AzkarListShimmer(),
        ],
      ),
    );
  }
}
