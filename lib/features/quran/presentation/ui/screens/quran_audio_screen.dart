import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';
import 'package:mishkat_almasabih/core/widgets/snackbars.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/audio/quran_audio_catalog_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/recitation/quran_recitation_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/audio/quran_audio_library.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/audio/quran_now_playing.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/sheets/recitation_sheet.dart';

class QuranAudioScreen extends StatefulWidget {
  const QuranAudioScreen({super.key});

  @override
  State<QuranAudioScreen> createState() => _QuranAudioScreenState();
}

class _QuranAudioScreenState extends State<QuranAudioScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final cubit = context.read<QuranRecitationCubit>();
    final index = context.watch<QuranAudioCatalogCubit>().state;
    final playback = context.watch<QuranRecitationCubit>().state;
    final surahs =
        index is QuranAudioCatalogReady ? index.surahs : const <QuranSurah>[];
    final scope = switch (playback) {
      RecitationPreparing(request: RecitationOfScope(:final scope)) ||
      RecitationFailure(request: RecitationOfScope(:final scope)) => scope,
      _ => null,
    };
    final currentSurah =
        playback.currentTrack?.surahNumber ??
        (scope?.kind == RecitationScopeKind.surah ? scope?.number : null);
    final pendingSurah = QuranSurah.numbered(surahs, currentSurah);
    final firstSurah = surahs.firstOrNull;
    final canChangeTrack = playback is RecitationActive && !playback.isLoading;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: palette.secondaryBackground,
        appBar: AppBar(
          title: const Text('مشغّل القرآن'),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12.w),
              child: AppIconButton(
                icon: Icons.tune_rounded,
                tooltip: 'إعدادات التشغيل',
                onPressed: () => showRecitationOptions(context, cubit),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.w,
                      12.h,
                      16.w,
                      16.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: QuranNowPlaying(
                        state: playback,
                        pendingSurah: pendingSurah,
                        onChooseReciter: () => setState(() => _tab = 1),
                        onPlay: switch (playback) {
                          RecitationIdle() when firstSurah != null =>
                            () => _playSurah(firstSurah),
                          RecitationIdle() || RecitationPreparing() => null,
                          RecitationActive() when playback.isLoading => null,
                          _ => cubit.togglePlayPause,
                        },
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.w,
                      0,
                      16.w,
                      12.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: SegmentedTabs(
                        labels: const ['السور', 'القرّاء', 'الآيات'],
                        selectedIndex: _tab,
                        onChanged: (value) => setState(() => _tab = value),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.w,
                      0,
                      16.w,
                      24.h,
                    ),
                    sliver: switch (_tab) {
                      0 => AudioSurahLibrary(
                        state: index,
                        currentSurah: currentSurah,
                        isPlaying:
                            playback is RecitationActive && playback.isPlaying,
                        onPlay: _playSurah,
                      ),
                      1 => AudioReciterLibrary(
                        selectedId: playback.settings.reciterId,
                        onSelect: _selectReciter,
                      ),
                      _ =>
                        playback is RecitationActive
                            ? AudioAyahQueue(
                              playback: playback,
                              onPlay: canChangeTrack ? cubit.playAyah : null,
                            )
                            : const SliverToBoxAdapter(
                              child: StateMessage(
                                icon: Icons.queue_music_rounded,
                                title: 'قائمة الآيات فارغة',
                                subtitle: 'اختر سورة لعرض آياتها هنا',
                              ),
                            ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _playSurah(QuranSurah surah) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<QuranRecitationCubit>().start(
      RecitationOfScope(RecitationScope.surah(surah.number)),
    );
  }

  Future<void> _selectReciter(QuranEdition edition) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final saved = await context.read<QuranRecitationCubit>().setReciter(
      edition,
    );
    if (mounted && !saved) {
      showErrorSnackbar(context, 'تعذر حفظ اختيارك لمرة قادمة');
    }
  }
}
