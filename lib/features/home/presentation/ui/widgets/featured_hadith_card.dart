import 'package:flutter/material.dart';

import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/helpers/spacing.dart';
import 'package:mishkat_almasabih/core/theming/home_decorations.dart';
import 'package:mishkat_almasabih/core/theming/home_styles.dart';

class FeaturedHadithCard extends StatelessWidget {
  final String hadithNumber;
  final String hadithText;
  final String narrator;
  final String book;

  const FeaturedHadithCard({
    super.key,
    required this.hadithNumber,
    required this.hadithText,
    required this.narrator,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: ColorsManager.cardBackground,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Spacing.md),
            decoration: HomeDecorations.featuredHeaderGradient,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: ColorsManager.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(Spacing.sm),
                  ),
                  child: Icon(
                    Icons.format_quote,
                    color: ColorsManager.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hadith #$hadithNumber',
                        style: TextStyles.labelLarge.copyWith(
                          color: ColorsManager.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        book,
                        style: TextStyles.labelMedium.copyWith(
                          color: ColorsManager.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.bookmark_border,
                    color: ColorsManager.white,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hadithText,
                    style: HomeTextStyles.featuredHadithText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  Container(
                    padding: EdgeInsets.all(Spacing.sm),
                    decoration: HomeDecorations.featuredFooter(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: ColorsManager.purpleText,
                        ),
                        SizedBox(width: Spacing.xs),
                        Expanded(
                          child: Text(
                            'Narrated by $narrator',
                            style: HomeTextStyles.featuredNarrator,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.share_outlined,
                            size: 16,
                            color: ColorsManager.purpleText,
                          ),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
