import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/section_header.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_home/azkar_home_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_home_actions.dart';

/// The starred chapters in a row of cards; hidden until there is one.
class AzkarFavoritesSection extends StatelessWidget {
  const AzkarFavoritesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarHomeCubit, AzkarHomeState>(
      buildWhen:
          (previous, current) =>
              previous is! AzkarHomeLoaded ||
              current is! AzkarHomeLoaded ||
              !listEquals(previous.favoriteIds, current.favoriteIds) ||
              previous.progress != current.progress,
      builder: (context, state) {
        if (state is! AzkarHomeLoaded) return const SizedBox.shrink();
        if (state.favoriteIds == null) {
          return SectionHeader(
            title: 'تعذر تحميل المفضلة',
            actionLabel: 'إعادة المحاولة',
            actionIcon: Icons.refresh_rounded,
            onAction: context.read<AzkarHomeCubit>().refresh,
          );
        }
        final favorites = state.favorites;
        if (favorites.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'المفضلة'),
            // Sized by its cards, whose text follows the reader's text size;
            // the reader picks the favourites, so there are never many.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, category) in favorites.indexed) ...[
                      if (i > 0) SizedBox(width: 10.w),
                      _FavoriteCard(
                        category: category,
                        progress: state.progressOf(category),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.category, required this.progress});

  final AzkarCategory category;
  final AzkarCategoryProgress progress;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final status =
        progress.isComplete
            ? 'أتممته اليوم'
            : progress.isStarted
            ? 'أتممت ${toArabicDigits('${progress.completedAzkar}')} من '
                '${toArabicDigits('${progress.totalAzkar}')}'
            : arabicCount(category.azkar.length, ArabicNoun.zikr);

    return SizedBox(
      width: 176.w,
      child: Material(
        color: palette.cardBackground,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
          side: BorderSide(color: palette.border),
        ),
        child: InkWell(
          onTap: () => openAzkarReader(context, categoryId: category.id),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: palette.primaryGold,
                  size: 22.r,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: palette.primaryText,
                        ),
                      ),
                      Text(
                        status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.caption.copyWith(
                          color:
                              progress.isComplete
                                  ? palette.success
                                  : palette.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
