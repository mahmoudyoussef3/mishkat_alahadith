import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_index/quran_index_cubit.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

/// Takes the reader back to the page they stopped on, or invites them to
/// start from Al-Fātiḥah the first time.
class ContinueReadingCard extends StatelessWidget {
  final ValueChanged<int> onOpenPage;

  const ContinueReadingCard({super.key, required this.onOpenPage});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranIndexCubit, QuranIndexState>(
      buildWhen:
          (previous, current) =>
              current is QuranIndexLoaded &&
              (previous is! QuranIndexLoaded ||
                  previous.lastRead?.page != current.lastRead?.page ||
                  previous.lastReadInfo != current.lastReadInfo),
      builder: (context, state) {
        if (state is! QuranIndexLoaded) return const SizedBox.shrink();
        final lastRead = state.lastRead;
        final info = state.lastReadInfo;
        final page = lastRead?.page ?? 1;

        final label =
            lastRead == null ? 'ابدأ رحلتك مع كتاب الله' : 'تابع من حيث توقفت';
        final surah = state.resumeSurah;
        final meta = [
          'الصفحة ${toArabicNumerals(page)}',
          if (info != null) 'الجزء ${toArabicNumerals(info.juz)}',
        ].join(' · ');

        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: QuranDecorations.continueReadingCard(),
          child: Row(
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: QuranDecorations.continueReadingIcon(),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: ColorsManager.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: QuranTextStyles.continueReadingLabel),
                    Text(
                      surah == null
                          ? 'القرآن الكريم'
                          : 'سورة ${surah.nameArabic}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: QuranTextStyles.continueReadingTitle,
                    ),
                    Text(meta, style: QuranTextStyles.continueReadingMeta),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              FilledButton(
                style: QuranDecorations.continueReadingButton(),
                onPressed: () => onOpenPage(page),
                child: Text(
                  lastRead == null ? 'ابدأ' : 'متابعة',
                  style: QuranTextStyles.continueReadingButton,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
