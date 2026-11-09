import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/recitation/quran_recitation_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_cloud_labels.dart';

/// A small player docked over the reader's bottom bar while a recitation is
/// on: what is being recited, by whom, and the controls.
class RecitationBar extends StatelessWidget {
  /// Opens the recitation sheet, for the reciter and the options.
  final VoidCallback onOpenSheet;

  const RecitationBar({super.key, required this.onOpenSheet});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranRecitationCubit, QuranRecitationState>(
      buildWhen: (previous, current) => _shown(previous) != _shown(current),
      builder:
          (context, state) => AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.bottomCenter,
            child: switch (state) {
              RecitationIdle() => const SizedBox(width: double.infinity),
              _ => _Bar(state: state, onOpenSheet: onOpenSheet),
            },
          ),
    );
  }

  /// What the bar draws, so it rebuilds only when that changes.
  static Object? _shown(QuranRecitationState state) => switch (state) {
    RecitationIdle() => null,
    RecitationPreparing(:final settings) => ('preparing', settings.reciterName),
    RecitationActive(:final settings, :final trackIndex, :final status) => (
      state.playlist,
      trackIndex,
      status,
      settings.reciterName,
    ),
    RecitationFailure(:final message) => ('failure', message),
  };
}

class _Bar extends StatelessWidget {
  final QuranRecitationState state;
  final VoidCallback onOpenSheet;

  const _Bar({required this.state, required this.onOpenSheet});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final cubit = context.read<QuranRecitationCubit>();
    final direction = Directionality.of(context);
    // The hero surface is dark on every paper, as under the azkar player.
    const ink = ColorsManager.white;
    final muted = ink.withValues(alpha: 0.72);
    final state = this.state;
    final buttonSize = 38.r;

    final (String title, String subtitle) = switch (state) {
      RecitationActive(:final settings, :final playlist) => (
        recitationTrackTitle(state.currentTrack),
        state.isLoading
            ? 'جارٍ التحميل…'
            : '${settings.reciterName} · ${recitationScopeTitle(playlist.scope, surahName: playlist.tracks.first.surahName)}',
      ),
      RecitationFailure(:final message) => ('تعذر تشغيل التلاوة', message),
      RecitationPreparing(:final settings) => (
        'جارٍ تجهيز التلاوة…',
        settings.reciterName,
      ),
      RecitationIdle() => ('', ''),
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
      child: Material(
        color: palette.heroBackground,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(10.w, 8.h, 6.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: '$title، $subtitle، خيارات التلاوة',
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: onOpenSheet,
                    borderRadius: BorderRadius.circular(14.r),
                    child: Row(
                      children: [
                        _Well(state: state),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: ink,
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
              ...switch (state) {
                RecitationActive() => [
                  AppIconButton(
                    tooltip: 'الآية السابقة',
                    icon: previousIcon(direction),
                    variant: AppIconButtonVariant.glass,
                    size: buttonSize,
                    onPressed: cubit.previous,
                  ),
                  SizedBox(width: 4.w),
                  AppIconButton(
                    tooltip: state.isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                    variant: AppIconButtonVariant.glass,
                    size: buttonSize,
                    onPressed: state.isLoading ? null : cubit.togglePlayPause,
                    child: Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  AppIconButton(
                    tooltip: 'الآية التالية',
                    icon: nextIcon(direction),
                    variant: AppIconButtonVariant.glass,
                    size: buttonSize,
                    onPressed: state.hasNext ? cubit.next : null,
                  ),
                ],
                RecitationFailure() => [
                  AppIconButton(
                    tooltip: 'إعادة المحاولة',
                    icon: Icons.refresh_rounded,
                    variant: AppIconButtonVariant.glass,
                    size: buttonSize,
                    onPressed: cubit.togglePlayPause,
                  ),
                ],
                RecitationPreparing() || RecitationIdle() => const <Widget>[],
              },
              SizedBox(width: 4.w),
              AppIconButton(
                tooltip: 'إيقاف التلاوة',
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

/// A spinner while loading, a warning after a failure, else an equaliser.
class _Well extends StatelessWidget {
  final QuranRecitationState state;

  const _Well({required this.state});

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final loading = switch (state) {
      RecitationPreparing() => true,
      RecitationActive(:final status) => status == RecitationStatus.loading,
      _ => false,
    };
    final failed = state is RecitationFailure;
    return Container(
      width: 36.r,
      height: 36.r,
      decoration: BoxDecoration(
        color: failed ? palette.errorSoft : palette.goldBright,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child:
          loading
              ? SizedBox.square(
                dimension: 16.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.onGoldBright,
                ),
              )
              : Icon(
                failed ? Icons.wifi_off_rounded : Icons.graphic_eq_rounded,
                size: 19.r,
                color: failed ? palette.error : palette.onGoldBright,
              ),
    );
  }
}
