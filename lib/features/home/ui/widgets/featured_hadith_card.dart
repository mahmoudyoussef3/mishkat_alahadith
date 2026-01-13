import 'package:flutter/material.dart';
// Removed unused flutter_screenutil import after centralizing styles

import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
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
        color: ColorsManager.white,
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
          // Header with gradient background
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
                  onPressed: () {
                    // TODO: Add to bookmarks
                  },
                ),
              ],
            ),
          ),

          // Hadith content
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

                  // Footer with narrator info
                  Container(
                    padding: EdgeInsets.all(Spacing.sm),
                    decoration: HomeDecorations.featuredFooter(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: ColorsManager.primaryPurple,
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
                            color: ColorsManager.primaryPurple,
                          ),
                          onPressed: () {
                            // TODO: Share hadith
                          },
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
