import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_audio/azkar_audio_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';

/// A small player shown, as the mini player over any screen, while a
/// recitation of the azkar is on or offered again: what it is, and the
/// controls.
class AzkarAudioBar extends StatelessWidget {
  const AzkarAudioBar({super.key, required this.onTap});

  /// Opens the recitation's chapter, at its zikr.
  final ValueChanged<AzkarAudioTrack> onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarAudioCubit, AzkarAudioState>(
      buildWhen: (previous, current) => _shown(previous) != _shown(current),
      builder: (context, state) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.bottomCenter,
          child: switch (state) {
            AzkarAudioActive() ||
            AzkarAudioSuspended() => _Bar(state: state, onTap: onTap),
            AzkarAudioIdle() ||
            AzkarAudioFailure() => const SizedBox(width: double.infinity),
          },
        );
      },
    );
  }

  /// What the bar draws and acts on, so it rebuilds only when that
  /// changes.
  static Object? _shown(AzkarAudioState state) => switch (state) {
    AzkarAudioActive(:final track, :final status) => (
      track,
      track.title,
      status,
    ),
    AzkarAudioSuspended(:final track) => ('suspended', track, track.title),
    AzkarAudioIdle() || AzkarAudioFailure() => null,
  };
}

class _Bar extends StatelessWidget {
  const _Bar({required this.state, required this.onTap});

  /// [AzkarAudioActive] or [AzkarAudioSuspended].
  final AzkarAudioState state;
  final ValueChanged<AzkarAudioTrack> onTap;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AzkarAudioCubit>();
    final track = state.track!;
    final muted = ColorsManager.white.withValues(alpha: 0.72);
    final active = switch (state) {
      final AzkarAudioActive active => active,
      _ => null,
    };
    final loading = active?.isLoading ?? false;
    final playing = active?.isPlaying ?? false;
    final subtitle = loading ? 'جارٍ تجهيز التلاوة…' : kAzkarReciter;
    final buttonSize = 38.r;

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
      child: Material(
        color: ColorsManager.heroBackground,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(10.w, 8.h, 6.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: '${track.title}، $subtitle، فتح الذكر',
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => onTap(track),
                    borderRadius: BorderRadius.circular(14.r),
                    child: Row(
                      children: [
                        Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: ColorsManager.goldBright,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.graphic_eq_rounded,
                            size: 19.r,
                            color: ColorsManager.onGoldBright,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: ColorsManager.white,
                                ),
                              ),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.caption.copyWith(
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              AppIconButton(
                tooltip: playing ? 'إيقاف مؤقت' : 'تشغيل',
                variant: AppIconButtonVariant.glass,
                size: buttonSize,
                onPressed: loading ? null : () => cubit.toggle(track),
                child:
                    loading
                        ? SizedBox.square(
                          dimension: 18.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ColorsManager.white,
                          ),
                        )
                        : Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
              ),
              SizedBox(width: 4.w),
              AppIconButton(
                tooltip: 'إغلاق',
                icon: Icons.close_rounded,
                variant: AppIconButtonVariant.glass,
                size: buttonSize,
                onPressed: cubit.stop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
