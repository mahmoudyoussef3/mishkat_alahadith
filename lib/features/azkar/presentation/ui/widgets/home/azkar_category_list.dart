import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_home/azkar_home_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_home_actions.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/common/azkar_category_row.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/common/azkar_list.dart';

/// The chapters of the chosen theme, or all of them, as a sliver.
class AzkarCategoryList extends StatelessWidget {
  const AzkarCategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarHomeCubit, AzkarHomeState>(
      buildWhen:
          (previous, current) =>
              previous is! AzkarHomeLoaded ||
              current is! AzkarHomeLoaded ||
              previous.categories != current.categories ||
              previous.collection != current.collection ||
              previous.progress != current.progress ||
              !listEquals(previous.favoriteIds, current.favoriteIds),
      builder: (context, state) {
        if (state is! AzkarHomeLoaded) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        final categories = state.visibleCategories;
        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: AzkarListHeader(
                title: state.collection?.label ?? 'جميع الأبواب',
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
                        () => openAzkarReader(context, categoryId: category.id),
                    onToggleFavorite:
                        () => toggleAzkarFavorite(context, category.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
