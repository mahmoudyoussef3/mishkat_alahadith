import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/models/azkar_reader_args.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/reader/azkar_audio_bar.dart';
import 'package:mishkat_almasabih/features/mini_player/presentation/logic/mini_player_placement_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/reader/recitation_bar.dart';

/// Whatever the app's one player has on — a recitation of the Quran or of
/// the azkar — with its controls; nothing while it has nothing. Starting
/// one replaces the other, so only one shows at a time.
///
/// Tapping it opens what plays: the Quran player, or the azkar's
/// chapter at the zikr.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.navigator,
    this.onOpenQuran,
    this.quranTapHint = 'خيارات التلاوة',
  });

  /// The navigator what plays is opened on.
  final NavigatorState? Function() navigator;

  /// Overrides opening the Quran player — in the mushaf itself, with the
  /// recitation's options, which [quranTapHint] names.
  final VoidCallback? onOpenQuran;
  final String quranTapHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RecitationBar(
          onTap: onOpenQuran ?? () => navigator()?.pushNamed(Routes.quranAudio),
          tapHint: onOpenQuran == null ? 'فتح مشغّل القرآن' : quranTapHint,
        ),
        AzkarAudioBar(onTap: (track) => _openAzkar(context, track)),
      ],
    );
  }

  /// The chapter at the zikr recited — unless it is the page on top.
  void _openAzkar(BuildContext context, AzkarAudioTrack track) {
    final page = context.read<MiniPlayerPlacementCubit?>()?.state.page;
    final onTop =
        page?.name == Routes.azkarReader &&
        switch (page?.arguments) {
          AzkarReaderArgs(:final categoryId) => categoryId == track.categoryId,
          _ => false,
        };
    if (onTop) return;
    navigator()?.pushNamed(
      Routes.azkarReader,
      arguments: AzkarReaderArgs(
        categoryId: track.categoryId,
        zikrId: track.zikrId,
      ),
    );
  }
}
