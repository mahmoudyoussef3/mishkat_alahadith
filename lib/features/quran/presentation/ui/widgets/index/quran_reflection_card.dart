import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/quran_styles.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_commentary.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/reflection/quran_reflection_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_cloud_labels.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;
import 'package:shimmer/shimmer.dart';

/// An ayah picked at random with a few lines of its tafsir, to pause on;
/// another at a tap, or the ayah in the mushaf.
class QuranReflectionCard extends StatelessWidget {
  final ValueChanged<QuranAyah> onOpenAyah;

  const QuranReflectionCard({super.key, required this.onOpenAyah});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 10.w, 14.h),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.border),
      ),
      child: BlocBuilder<QuranReflectionCubit, QuranReflectionState>(
        builder: (context, state) {
          final cubit = context.read<QuranReflectionCubit>();
          final loading = state is QuranReflectionLoading;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      color: palette.goldSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18.r,
                      color: palette.goldInk,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'آية للتدبّر',
                        style: TextStyles.sectionTitle.copyWith(
                          fontSize: 16.sp,
                          color: palette.primaryText,
                        ),
                      ),
                    ),
                  ),
                  AppIconButton(
                    tooltip: 'آية أخرى',
                    icon: Icons.refresh_rounded,
                    variant: AppIconButtonVariant.ghost,
                    size: 38.r,
                    onPressed: loading ? null : cubit.load,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsetsDirectional.only(end: 6.w),
                child: switch (state) {
                  QuranReflectionLoading(previous: null) => const _Shimmer(),
                  QuranReflectionLoading(previous: final ayah?) => Opacity(
                    opacity: 0.45,
                    child: _Reflection(item: ayah, onOpen: null),
                  ),
                  QuranReflectionLoaded(:final ayah) => _Reflection(
                    item: ayah,
                    onOpen: () => onOpenAyah(ayah.ayah),
                  ),
                  QuranReflectionFailure(:final message) => _Failure(
                    message: message,
                    onRetry: cubit.load,
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Reflection extends StatelessWidget {
  final CommentedAyah item;

  /// Null while another ayah loads.
  final VoidCallback? onOpen;

  const _Reflection({required this.item, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final tafsir = item.commentary.tafsir;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '﴿${item.ayah.text.trim()}﴾',
          textAlign: TextAlign.center,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: QuranTextStyles.mushafText(
            color: palette.primaryText,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'سورة ${item.surah.nameArabic} · الآية ${toArabicNumerals(item.ayah.number)}',
          textAlign: TextAlign.center,
          style: TextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: palette.goldInk,
          ),
        ),
        if (tafsir != null) ...[
          SizedBox(height: 10.h),
          Text(
            tafsir.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textDirection: editionDirection(tafsir.edition),
            style: TextStyles.caption.copyWith(
              fontSize: 13.5.sp,
              height: 1.8,
              color: palette.secondaryText,
            ),
          ),
        ],
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.chrome_reader_mode_outlined),
            label: const Text('اقرأ في المصحف'),
          ),
        ),
      ],
    );
  }
}

class _Failure extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _Failure({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    return Row(
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
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    Widget line(double endInset) => Container(
      height: 14.h,
      margin: EdgeInsetsDirectional.only(bottom: 10.h, end: endInset),
      decoration: BoxDecoration(
        color: palette.shimmerBase,
        borderRadius: BorderRadius.circular(7.r),
      ),
    );
    return Semantics(
      label: 'جارٍ التحميل',
      child: Shimmer.fromColors(
        baseColor: palette.shimmerBase,
        highlightColor: palette.shimmerHighlight,
        child: Column(children: [line(0), line(40.w), line(120.w)]),
      ),
    );
  }
}
