import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_search_results.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

/// One matching ayah, with every occurrence of the query washed in gold.
class QuranSearchHitTile extends StatelessWidget {
  final QuranSearchHit hit;
  final VoidCallback onTap;

  const QuranSearchHitTile({super.key, required this.hit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ayah = hit.ayah;
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: QuranDecorations.searchHitCard(),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'سورة ${hit.surahName} · الآية ${toArabicNumerals(ayah.number)}',
                        style: QuranTextStyles.searchHitReference,
                      ),
                    ),
                    Text(
                      'ص ${toArabicNumerals(ayah.page)}',
                      style: QuranTextStyles.searchHitPage,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text.rich(_highlighted(), textAlign: TextAlign.start),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextSpan _highlighted() {
    final mark = TextStyle(
      backgroundColor: QuranDecorations.searchMatchHighlight,
    );
    return styledRanges(
      text: hit.ayah.text,
      base: QuranTextStyles.mushafText(
        color: ColorsManager.primaryText,
        size: 20.sp,
      ),
      ranges: [
        for (final match in hit.matches)
          (start: match.start, end: match.end, style: mark),
      ],
    );
  }
}
