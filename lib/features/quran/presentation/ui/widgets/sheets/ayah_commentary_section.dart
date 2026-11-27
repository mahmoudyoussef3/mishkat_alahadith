import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_commentary.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/ayah_commentary/ayah_commentary_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_cloud_labels.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/edition_picker_sheet.dart';
import 'package:shimmer/shimmer.dart';

/// The ayah's tafsir and, if the reader chose one, its translation — each
/// with a chip to switch edition.
class AyahCommentarySection extends StatelessWidget {
  /// Opens the tafsir of the whole surah from this ayah on.
  final VoidCallback onReadSurahTafsir;

  const AyahCommentarySection({super.key, required this.onReadSurahTafsir});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AyahCommentaryCubit, AyahCommentaryState>(
      builder: (context, state) {
        final commentary = switch (state) {
          AyahCommentaryLoaded(:final commentary) => commentary,
          _ => null,
        };
        final hasTranslation = state.settings.translationId != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionTitle(
              title: 'التفسير',
              chipLabel: commentary?.tafsir?.edition.name ?? 'اختيار التفسير',
              onChip: () => _pickTafsir(context, state.settings.tafsirId),
            ),
            SizedBox(height: 10.h),
            switch (state) {
              AyahCommentaryLoading() => const _LoadingCard(),
              AyahCommentaryFailure(:final message) => _FailureCard(
                message: message,
                onRetry: context.read<AyahCommentaryCubit>().retry,
              ),
              AyahCommentaryLoaded(:final commentary) => _PassageCard(
                passage: commentary.tafsir,
                emptyMessage: 'لا يتوفر تفسير لهذه الآية في هذا الإصدار',
              ),
            },
            SizedBox(height: 18.h),
            _SectionTitle(
              title: 'الترجمة',
              chipLabel:
                  hasTranslation
                      ? commentary?.translation?.edition.name ??
                          'اختيار الترجمة'
                      : 'إضافة ترجمة',
              chipIcon:
                  hasTranslation ? Icons.swap_horiz_rounded : Icons.add_rounded,
              onChip:
                  () => _pickTranslation(context, state.settings.translationId),
            ),
            SizedBox(height: 10.h),
            if (!hasTranslation)
              const _Note('أضف ترجمة لمعاني الآيات بلغة تختارها.')
            else
              switch (state) {
                AyahCommentaryLoading() => const _LoadingCard(lines: 2),
                // The tafsir's card already offers to retry.
                AyahCommentaryFailure() => const _Note(
                  'تتعذر الترجمة حتى يعود الاتصال.',
                ),
                AyahCommentaryLoaded(:final commentary) => _PassageCard(
                  passage: commentary.translation,
                  emptyMessage: 'لا تتوفر ترجمة لهذه الآية في هذا الإصدار',
                ),
              },
            SizedBox(height: 14.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: onReadSurahTafsir,
                icon: const Icon(Icons.auto_stories_rounded),
                label: const Text('تفسير السورة متصلًا من هذه الآية'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickTafsir(BuildContext context, String current) {
    final cubit = context.read<AyahCommentaryCubit>();
    return pickEdition(
      context,
      type: QuranEditionType.tafsir,
      selectedId: current,
      apply: (edition) => cubit.setTafsir(edition!),
    );
  }

  Future<void> _pickTranslation(BuildContext context, String? current) {
    final cubit = context.read<AyahCommentaryCubit>();
    return pickEdition(
      context,
      type: QuranEditionType.translation,
      selectedId: current,
      allowNone: true,
      apply: cubit.setTranslation,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String chipLabel;
  final IconData chipIcon;
  final VoidCallback onChip;

  const _SectionTitle({
    required this.title,
    required this.chipLabel,
    required this.onChip,
    this.chipIcon = Icons.swap_horiz_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Row(
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: TextStyles.sectionTitle.copyWith(
              fontSize: 16.sp,
              color: palette.primaryText,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Material(
              color: palette.primarySoft,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onChip,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(chipIcon, size: 16.r, color: palette.purpleText),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          chipLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.chipLabel.copyWith(
                            fontSize: 12.5.sp,
                            color: palette.purpleText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A passage of a tafsir or translation, folded when long, with a button to
/// copy it.
class _PassageCard extends StatefulWidget {
  /// Folded to this many lines until the reader asks for the rest.
  static const int _foldedLines = 9;

  /// Passages shorter than this are always shown whole.
  static const int _foldThreshold = 420;

  final EditionText? passage;
  final String emptyMessage;

  const _PassageCard({required this.passage, required this.emptyMessage});

  @override
  State<_PassageCard> createState() => _PassageCardState();
}

class _PassageCardState extends State<_PassageCard> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final passage = widget.passage;
    if (passage == null) return _Note(widget.emptyMessage);

    final foldable = passage.text.length > _PassageCard._foldThreshold;
    final folded = foldable && !_expanded;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            passage.text,
            textDirection: editionDirection(passage.edition),
            maxLines: folded ? _PassageCard._foldedLines : null,
            overflow: folded ? TextOverflow.fade : TextOverflow.visible,
            style: TextStyles.explanationBody.copyWith(
              fontSize: 15.sp,
              height: 1.9,
              color: palette.primaryText,
            ),
          ),
          Row(
            children: [
              if (foldable)
                TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(_expanded ? 'عرض أقل' : 'عرض المزيد'),
                ),
              const Spacer(),
              IconButton(
                tooltip: 'نسخ',
                icon: Icon(
                  Icons.content_copy_rounded,
                  size: 18.r,
                  color: palette.secondaryText,
                ),
                onPressed: () => _copy(context, passage),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _copy(BuildContext context, EditionText passage) async {
    await Clipboard.setData(
      ClipboardData(text: '${passage.text}\n— ${passage.edition.name}'),
    );
    if (context.mounted) showInfoSnackbar(context, 'تم النسخ');
  }
}

class _LoadingCard extends StatelessWidget {
  final int lines;

  const _LoadingCard({this.lines = 4});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Semantics(
      label: 'جارٍ التحميل',
      child: Shimmer.fromColors(
        baseColor: palette.shimmerBase,
        highlightColor: palette.shimmerHighlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < lines; i++)
              Container(
                height: 12.h,
                margin: EdgeInsetsDirectional.only(
                  bottom: 10.h,
                  end: i == lines - 1 ? 80.w : 0,
                ),
                decoration: BoxDecoration(
                  color: palette.shimmerBase,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FailureCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FailureCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(14.w, 10.h, 6.w, 10.h),
      decoration: BoxDecoration(
        color: palette.secondaryBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 20.r, color: palette.gray),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyles.caption.copyWith(
                fontSize: 13.sp,
                color: palette.secondaryText,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String text;

  const _Note(this.text);

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: palette.secondaryBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        text,
        style: TextStyles.caption.copyWith(
          fontSize: 13.sp,
          color: palette.secondaryText,
        ),
      ),
    );
  }
}
