import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_audio/azkar_audio_cubit.dart';

/// Plays, pauses or resumes [track], showing a spinner while it downloads.
class AzkarAudioButton extends StatelessWidget {
  const AzkarAudioButton({
    super.key,
    required this.track,
    required this.tooltip,
    this.idleVariant = AppIconButtonVariant.ghost,
    this.size,
  });

  final AzkarAudioTrack track;
  final String tooltip;

  /// How the button looks while [track] is not on the player.
  final AppIconButtonVariant idleVariant;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AzkarAudioCubit, AzkarAudioState, AzkarPlaybackStatus?>(
      selector:
          (state) =>
              state is AzkarAudioActive && state.track == track
                  ? state.status
                  : null,
      builder: (context, status) {
        final dimension = size ?? 42.r;
        return AppIconButton(
          tooltip:
              status == AzkarPlaybackStatus.playing ? 'إيقاف مؤقت' : tooltip,
          variant: status == null ? idleVariant : AppIconButtonVariant.tonal,
          size: dimension,
          onPressed: () => context.read<AzkarAudioCubit>().toggle(track),
          child: switch (status) {
            AzkarPlaybackStatus.loading => SizedBox.square(
              dimension: dimension * 0.4,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            AzkarPlaybackStatus.playing => const Icon(Icons.pause_rounded),
            AzkarPlaybackStatus.paused => const Icon(Icons.play_arrow_rounded),
            _ => const Icon(Icons.headphones_rounded),
          },
        );
      },
    );
  }
}
