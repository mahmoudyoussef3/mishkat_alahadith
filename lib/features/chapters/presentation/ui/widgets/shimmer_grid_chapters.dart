import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/chapters/ui/widgets/chapter_card_shimmer.dart';

class ChapterGridShimmer extends StatelessWidget {
  const ChapterGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const crossAxisCount = 2;
    final spacing = 12 * (crossAxisCount - 1);
    final itemWidth = (screenWidth - spacing) / crossAxisCount;
    final itemHeight = itemWidth * 0.4;
    final aspectRatio = itemWidth / itemHeight;

    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: ChapterCardShimmer(),
        );
      }, childCount: 30),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
    );
  }
}