import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_badge.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_settings.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/zikr.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_reader/azkar_reader_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';
import 'package:share_plus/share_plus.dart';

import 'azkar_audio_button.dart';
import 'zikr_counter_button.dart';

/// One zikr to read and count: tapping the card or its counter counts one
/// repetition, and the card turns green once it is said as often as asked.
///
/// Only this card rebuilds as its own count changes.
class ZikrCard extends StatelessWidget {
  const ZikrCard({
    super.key,
    required this.category,
    required this.zikr,
    required this.position,
    required this.settings,
  });

  final AzkarCategory category;
  final Zikr zikr;

  /// Its place in the chapter, from 1.
  final int position;
  final AzkarSettings settings;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AzkarReaderCubit, AzkarReaderState, int>(
      selector:
          (state) => state is AzkarReaderLoaded ? state.countOf(zikr.id) : 0,
      builder: (context, said) {
        final palette = AppPaletteOverride.of(context);
        final done = said >= zikr.count;
        final audio = AzkarAudioTrack.ofZikr(category, zikr);
        void count() => _count(context);

        return Material(
          color: done ? palette.successSoft : palette.cardBackground,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
            side: BorderSide(
              color:
                  done
                      ? palette.success.withValues(alpha: 0.45)
                      : palette.border,
            ),
          ),
          child: InkWell(
            onTap: done ? null : count,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 10.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AppBadge.tag(
                        '${toArabicDigits('$position')} / '
                        '${toArabicDigits('${category.azkar.length}')}',
                      ),
                      if (zikr.isRepeated) ...[
                        SizedBox(width: 6.w),
                        AppBadge(
                          label: repetitionLabel(zikr.count),
                          icon: Icons.repeat_rounded,
                          background: palette.goldSoft,
                          foreground: palette.goldInk,
                        ),
                      ],
                      const Spacer(),
                      if (audio != null)
                        AzkarAudioButton(
                          track: audio,
                          tooltip: 'استماع للذكر',
                          size: 36.r,
                        ),
                      AppIconButton(
                        tooltip: 'نسخ',
                        icon: Icons.content_copy_rounded,
                        variant: AppIconButtonVariant.ghost,
                        size: 36.r,
                        onPressed: () => _copy(context),
                      ),
                      Builder(
                        builder:
                            (buttonContext) => AppIconButton(
                              tooltip: 'مشاركة',
                              icon: Icons.share_rounded,
                              variant: AppIconButtonVariant.ghost,
                              size: 36.r,
                              onPressed: () => _share(buttonContext),
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 6.w),
                    child: Text(
                      zikr.text,
                      style: TextStyles.readingMedium.copyWith(
                        fontSize: 19.sp * settings.fontScale.factor,
                        height: 2.0,
                        color:
                            done ? palette.secondaryText : palette.primaryText,
                      ),
                    ),
                  ),
                  if (zikr.translation != null || zikr.transliteration != null)
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: 8.h, end: 6.w),
                      child: _Translation(zikr: zikr, settings: settings),
                    ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      ZikrCounterButton(
                        said: said,
                        count: zikr.count,
                        onPressed: done ? null : count,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(child: _Status(zikr: zikr, said: said)),
                      if (said > 0)
                        AppIconButton(
                          tooltip: 'إعادة عدّ هذا الذكر',
                          icon: Icons.restart_alt_rounded,
                          variant: AppIconButtonVariant.ghost,
                          size: 36.r,
                          onPressed:
                              () => context.read<AzkarReaderCubit>().resetZikr(
                                zikr.id,
                              ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _count(BuildContext context) {
    final outcome = context.read<AzkarReaderCubit>().count(zikr.id);
    if (!settings.hapticFeedback) return;
    switch (outcome) {
      case ZikrCountOutcome.counted:
        HapticFeedback.selectionClick();
      case ZikrCountOutcome.zikrCompleted:
        HapticFeedback.mediumImpact();
      case ZikrCountOutcome.categoryCompleted:
        HapticFeedback.heavyImpact();
      case ZikrCountOutcome.ignored:
        break;
    }
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: formatZikrForSharing(category, zikr)),
    );
    if (context.mounted) showInfoSnackbar(context, 'تم نسخ الذكر');
  }

  Future<void> _share(BuildContext context) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: formatZikrForSharing(category, zikr),
          subject: category.title,
          sharePositionOrigin: shareOriginOf(context),
        ),
      );
    } on PlatformException {
      if (context.mounted) showErrorSnackbar(context, 'تعذر مشاركة الذكر');
    }
  }
}

/// The meaning in the chosen language, set left to right under a rule.
class _Translation extends StatelessWidget {
  const _Translation({required this.zikr, required this.settings});

  final Zikr zikr;
  final AzkarSettings settings;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final translation = zikr.translation;
    final transliteration = zikr.transliteration;
    final style = TextStyles.explanationBody.copyWith(
      fontSize: 14.sp * settings.fontScale.factor,
      height: 1.6,
      color: palette.secondaryText,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: EdgeInsetsDirectional.only(start: 12.w),
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(color: palette.goldBright, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transliteration != null)
              Text(
                transliteration,
                style: style.copyWith(
                  fontStyle: FontStyle.italic,
                  color: palette.purpleText,
                ),
              ),
            if (translation != null) Text(translation, style: style),
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.zikr, required this.said});

  final Zikr zikr;
  final int said;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final done = said >= zikr.count;
    final (title, subtitle) =
        done
            ? ('تمّ بحمد الله', null)
            : said == 0
            ? (
              zikr.isRepeated ? 'اضغط للعدّ' : 'اضغط بعد قراءته',
              zikr.isRepeated ? repetitionLabel(zikr.count) : null,
            )
            : (
              'بقي ${repetitionLabel(zikr.count - said)}',
              'من ${toArabicDigits('${zikr.count}')}',
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: done ? palette.success : palette.primaryText,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyles.caption.copyWith(color: palette.secondaryText),
          ),
      ],
    );
  }
}
