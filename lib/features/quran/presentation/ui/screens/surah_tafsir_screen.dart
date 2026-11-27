import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/dashed_divider.dart';
import 'package:mishkat_almasabih/core/widgets/detail_header.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_commentary.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/surah_tafsir/surah_tafsir_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_cloud_labels.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/edition_picker_sheet.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

/// Where the reader asked to go in the mushaf from the tafsir.
typedef TafsirReaderTarget = ({int page, int ayahId, int surahNumber});

/// A surah's tafsir read straight through: each ayah from the bundled
/// mushaf, its tafsir and translation from the service, a page at a time.
///
/// Opened over the mushaf, «اقرأ في المصحف» returns to it at the ayah.
class SurahTafsirScreen extends StatelessWidget {
  const SurahTafsirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child: BlocBuilder<SurahTafsirCubit, SurahTafsirState>(
                  builder:
                      (context, state) => switch (state) {
                        SurahTafsirLoading() => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        SurahTafsirFailure(:final message) => ListView(
                          padding: EdgeInsets.only(top: 24.h),
                          children: [
                            StateMessage.error(
                              message: message,
                              onRetry: context.read<SurahTafsirCubit>().retry,
                            ),
                          ],
                        ),
                        SurahTafsirLoaded() => _TafsirList(state: state),
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SurahTafsirCubit, SurahTafsirState>(
      buildWhen:
          (previous, current) =>
              _titles(previous) != _titles(current) ||
              previous.settings != current.settings,
      builder: (context, state) {
        final (title, subtitle) = _titles(state);
        return DetailHeader(
          title: title,
          subtitle: subtitle,
          actions: [
            AppIconButton(
              tooltip: 'اختيار التفسير',
              icon: Icons.menu_book_rounded,
              onPressed: () => _pickTafsir(context, state.settings.tafsirId),
            ),
            AppIconButton(
              tooltip: 'الترجمة',
              icon: Icons.translate_rounded,
              variant:
                  state.settings.translationId == null
                      ? AppIconButtonVariant.outlined
                      : AppIconButtonVariant.tonal,
              onPressed:
                  () => _pickTranslation(context, state.settings.translationId),
            ),
          ],
        );
      },
    );
  }

  static (String, String?) _titles(SurahTafsirState state) => switch (state) {
    SurahTafsirLoaded(:final surah, :final ayahs) => (
      'تفسير سورة ${surah.nameArabic}',
      ayahs.firstOrNull?.commentary.tafsir?.edition.name,
    ),
    _ => ('التفسير', null),
  };

  Future<void> _pickTafsir(BuildContext context, String current) {
    final cubit = context.read<SurahTafsirCubit>();
    return pickEdition(
      context,
      type: QuranEditionType.tafsir,
      selectedId: current,
      apply: (edition) => cubit.setTafsir(edition!),
    );
  }

  Future<void> _pickTranslation(BuildContext context, String? current) {
    final cubit = context.read<SurahTafsirCubit>();
    return pickEdition(
      context,
      type: QuranEditionType.translation,
      selectedId: current,
      allowNone: true,
      apply: cubit.setTranslation,
    );
  }
}

class _TafsirList extends StatelessWidget {
  final SurahTafsirLoaded state;

  const _TafsirList({required this.state});

  @override
  Widget build(BuildContext context) {
    final ayahs = state.ayahs;
    final lead = state.startsMidway ? 1 : 0;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      itemCount: lead + ayahs.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, i) {
        if (i < lead) return _MidwayBanner(startAyah: state.startAyah);
        final index = i - lead;
        if (index < ayahs.length) return _CommentedAyahCard(item: ayahs[index]);
        return _Footer(state: state);
      },
    );
  }
}

class _MidwayBanner extends StatelessWidget {
  final int startAyah;

  const _MidwayBanner({required this.startAyah});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(14.w, 6.h, 6.w, 6.h),
      decoration: BoxDecoration(
        color: palette.primarySoft,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'من الآية ${toArabicNumerals(startAyah)}',
              style: TextStyles.labelLarge.copyWith(color: palette.purpleText),
            ),
          ),
          TextButton(
            onPressed: context.read<SurahTafsirCubit>().showFromStart,
            child: const Text('من أول السورة'),
          ),
        ],
      ),
    );
  }
}

class _CommentedAyahCard extends StatelessWidget {
  final CommentedAyah item;

  const _CommentedAyahCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final ayah = item.ayah;
    final tafsir = item.commentary.tafsir;
    final translation = item.commentary.translation;
    final body = TextStyles.explanationBody.copyWith(
      fontSize: 15.sp,
      height: 1.9,
      color: palette.primaryText,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppBadge.tag('الآية ${toArabicNumerals(ayah.number)}'),
              SizedBox(width: 8.w),
              Text(
                'ص ${toArabicNumerals(ayah.page)}',
                style: TextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.secondaryText,
                ),
              ),
              const Spacer(),
              AppIconButton(
                tooltip: 'اقرأ في المصحف',
                icon: Icons.chrome_reader_mode_outlined,
                variant: AppIconButtonVariant.ghost,
                size: 36.r,
                onPressed:
                    () => Navigator.of(context).pop<TafsirReaderTarget>((
                      page: ayah.page,
                      ayahId: ayah.id,
                      surahNumber: ayah.surahNumber,
                    )),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            ayah.text,
            textAlign: TextAlign.center,
            style: QuranTextStyles.mushafText(
              color: palette.primaryText,
              size: 22.sp,
            ),
          ),
          SizedBox(height: 12.h),
          const DashedDivider(),
          SizedBox(height: 12.h),
          if (tafsir == null)
            Text(
              'لا يتوفر تفسير لهذه الآية في هذا الإصدار',
              style: TextStyles.caption.copyWith(color: palette.secondaryText),
            )
          else
            Text(
              tafsir.text,
              textDirection: editionDirection(tafsir.edition),
              style: body,
            ),
          if (translation != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: palette.secondaryBackground,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                translation.text,
                textDirection: editionDirection(translation.edition),
                style: body.copyWith(fontSize: 14.sp, height: 1.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// More ayahs loading, a failed page to retry, or the surah's end.
class _Footer extends StatelessWidget {
  final SurahTafsirLoaded state;

  const _Footer({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SurahTafsirCubit>();
    final failure = state.loadMoreFailure;
    if (failure != null) {
      return StateMessage.error(message: failure, onRetry: cubit.loadMore);
    }
    if (state.hasMore) {
      // Reached the end of what is loaded: fetch the next page.
      if (!state.isLoadingMore) {
        WidgetsBinding.instance.addPostFrameCallback((_) => cubit.loadMore());
      }
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final next = state.surah.number + 1;
    return Column(
      children: [
        SizedBox(height: 8.h),
        Text(
          'انتهى تفسير سورة ${state.surah.nameArabic}',
          textAlign: TextAlign.center,
          style: TextStyles.caption.copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppPaletteOverride.of(context).secondaryText,
          ),
        ),
        if (next <= QuranMetrics.surahCount)
          TextButton.icon(
            onPressed: () => cubit.load(next),
            // Mirrors itself: points left in Arabic, the way reading goes.
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('تفسير السورة التالية'),
          ),
      ],
    );
  }
}
