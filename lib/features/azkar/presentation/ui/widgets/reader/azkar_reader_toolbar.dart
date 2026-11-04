import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_reader/azkar_reader_cubit.dart';

import 'azkar_audio_button.dart';
import 'azkar_settings_sheet.dart';

/// Stays above the azkar: back, today's progress through the chapter, the
/// chapter's recitation, the favourite star and the reading settings.
class AzkarReaderToolbar extends StatelessWidget {
  const AzkarReaderToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          AppIconButton(
            tooltip: 'رجوع',
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          SizedBox(width: 12.w),
          const Expanded(child: _Progress()),
          SizedBox(width: 12.w),
          const _Actions(),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      AzkarReaderCubit,
      AzkarReaderState,
      ({int done, int total, double fraction})?
    >(
      selector: (state) {
        if (state is! AzkarReaderLoaded) return null;
        final progress = state.progress;
        return (
          done: progress.completedAzkar,
          total: progress.totalAzkar,
          fraction: progress.fraction,
        );
      },
      builder: (context, progress) {
        if (progress == null) return const SizedBox.shrink();
        final palette = AppPaletteOverride.of(context);
        final complete = progress.done == progress.total;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              complete
                  ? 'أتممت الباب'
                  : '${toArabicDigits('${progress.done}')} من '
                      '${toArabicDigits('${progress.total}')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: complete ? palette.success : palette.secondaryText,
              ),
            ),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(3.r),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress.fraction),
                duration: const Duration(milliseconds: 250),
                builder:
                    (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 5.h,
                      color: complete ? palette.success : palette.goldBright,
                      backgroundColor: palette.lightGray,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarReaderCubit, AzkarReaderState>(
      buildWhen:
          (previous, current) =>
              previous.runtimeType != current.runtimeType ||
              (previous is AzkarReaderLoaded &&
                  current is AzkarReaderLoaded &&
                  (previous.category != current.category ||
                      previous.isFavorite != current.isFavorite)),
      builder: (context, state) {
        if (state is! AzkarReaderLoaded) return const SizedBox.shrink();
        final chapterAudio = AzkarAudioTrack.ofCategory(state.category);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chapterAudio != null) ...[
              AzkarAudioButton(
                track: chapterAudio,
                tooltip: 'الاستماع إلى الباب كاملاً',
                idleVariant: AppIconButtonVariant.outlined,
              ),
              SizedBox(width: 8.w),
            ],
            AppIconButton(
              tooltip:
                  state.isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
              icon:
                  state.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
              variant:
                  state.isFavorite
                      ? AppIconButtonVariant.tonal
                      : AppIconButtonVariant.outlined,
              onPressed: () => _toggleFavorite(context),
            ),
            SizedBox(width: 8.w),
            AppIconButton(
              tooltip: 'إعدادات القراءة',
              icon: Icons.tune_rounded,
              onPressed: () => showAzkarSettingsSheet(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final isFavorite = await context.read<AzkarReaderCubit>().toggleFavorite();
    if (!context.mounted) return;
    switch (isFavorite) {
      case null:
        showErrorSnackbar(context, 'تعذر تحديث المفضلة، حاول مرة أخرى');
      case true:
        showInfoSnackbar(context, 'أُضيف الباب إلى المفضلة');
      case false:
        showInfoSnackbar(context, 'أُزيل الباب من المفضلة');
    }
  }
}
