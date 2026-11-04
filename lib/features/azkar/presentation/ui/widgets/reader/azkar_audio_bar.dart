import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_audio/azkar_audio_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_reader/azkar_reader_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';

/// A small player docked under the azkar while a recitation is on.
class AzkarAudioBar extends StatelessWidget {
  const AzkarAudioBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarAudioCubit, AzkarAudioState>(
      builder: (context, state) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.bottomCenter,
          child:
              state is AzkarAudioActive
                  ? _Bar(state: state)
                  : const SizedBox(width: double.infinity),
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.state});

  final AzkarAudioActive state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AzkarAudioCubit>();
    final muted = ColorsManager.white.withValues(alpha: 0.72);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
        child: Container(
          padding: EdgeInsetsDirectional.fromSTEB(12.w, 10.h, 10.w, 10.h),
          decoration: BoxDecoration(
            color: ColorsManager.heroBackground,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: ColorsManager.goldBright,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.graphic_eq_rounded,
                  size: 20.r,
                  color: ColorsManager.onGoldBright,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(context, state.track),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorsManager.white,
                      ),
                    ),
                    Text(
                      state.isLoading ? 'جارٍ تجهيز التلاوة…' : kAzkarReciter,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.caption.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                tooltip: state.isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                variant: AppIconButtonVariant.glass,
                onPressed:
                    state.isLoading ? null : () => cubit.toggle(state.track),
                child:
                    state.isLoading
                        ? SizedBox.square(
                          dimension: 18.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ColorsManager.white,
                          ),
                        )
                        : Icon(
                          state.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
              ),
              SizedBox(width: 8.w),
              AppIconButton(
                tooltip: 'إغلاق',
                icon: Icons.close_rounded,
                variant: AppIconButtonVariant.glass,
                onPressed: cubit.stop,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// «تلاوة الباب كاملاً», or the zikr's place in the chapter.
  static String _title(BuildContext context, AzkarAudioTrack track) {
    final zikrId = track.zikrId;
    if (zikrId == null) return 'تلاوة الباب كاملاً';
    final reader = context.read<AzkarReaderCubit>().state;
    if (reader is! AzkarReaderLoaded) return 'الذكر';
    final index = reader.category.azkar.indexWhere((z) => z.id == zikrId);
    return index < 0 ? 'الذكر' : 'الذكر ${toArabicDigits('${index + 1}')}';
  }
}
