import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/widgets/state_message.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_editions/quran_editions_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/audio/quran_audio_catalog_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/recitation/quran_recitation_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_cloud_labels.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/index/quran_index_row.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

class AudioSurahLibrary extends StatelessWidget {
  const AudioSurahLibrary({
    super.key,
    required this.state,
    required this.currentSurah,
    required this.isPlaying,
    required this.onPlay,
  });

  final QuranAudioCatalogState state;
  final int? currentSurah;
  final bool isPlaying;
  final ValueChanged<QuranSurah> onPlay;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      QuranAudioCatalogLoading() => const QuranIndexShimmer(),
      QuranAudioCatalogFailure(:final message) => SliverToBoxAdapter(
        child: StateMessage.error(
          message: message,
          onRetry: context.read<QuranAudioCatalogCubit>().load,
        ),
      ),
      QuranAudioCatalogReady(:final visible, :final query) =>
        SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: TextFormField(
                initialValue: query,
                onChanged: context.read<QuranAudioCatalogCubit>().filter,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'ابحث باسم السورة أو رقمها…',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10.h)),
            if (visible.isEmpty)
              const _EmptyResults()
            else
              QuranIndexCard(
                sliver: SliverList.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, i) {
                    final surah = visible[i];
                    final selected = surah.number == currentSurah;
                    return Semantics(
                      selected: selected,
                      child: QuranIndexRow(
                        isFirst: i == 0,
                        isLast: i == visible.length - 1,
                        leading: QuranIndexWell(
                          label: toArabicNumerals(surah.number),
                          highlighted: selected,
                        ),
                        title: surah.nameArabic,
                        subtitle: [
                          ltrIsolate(surah.nameEnglish),
                          arabicCount(surah.ayahCount, ArabicNoun.ayah),
                        ].join(' · '),
                        trailing: Icon(
                          selected && isPlaying
                              ? Icons.graphic_eq_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        onTap: () => onPlay(surah),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
    };
  }
}

class AudioReciterLibrary extends StatelessWidget {
  const AudioReciterLibrary({
    super.key,
    required this.selectedId,
    required this.onSelect,
  });

  final String selectedId;
  final ValueChanged<QuranEdition> onSelect;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranEditionsCubit, QuranEditionsState>(
      builder:
          (context, state) => switch (state) {
            QuranEditionsLoading() => const QuranIndexShimmer(),
            QuranEditionsFailure(:final message) => SliverToBoxAdapter(
              child: StateMessage.error(
                message: message,
                onRetry:
                    () => context.read<QuranEditionsCubit>().load(
                      QuranEditionType.recitation,
                    ),
              ),
            ),
            QuranEditionsLoaded(:final visible, :final query) =>
              SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: TextFormField(
                      initialValue: query,
                      onChanged: context.read<QuranEditionsCubit>().filter,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'ابحث عن قارئ…',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                  if (visible.isEmpty)
                    const _EmptyResults()
                  else
                    QuranIndexCard(
                      sliver: SliverList.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, i) {
                          final edition = visible[i];
                          final selected = edition.identifier == selectedId;
                          return Semantics(
                            selected: selected,
                            child: QuranIndexRow(
                              isFirst: i == 0,
                              isLast: i == visible.length - 1,
                              leading: QuranIndexWell(
                                icon: Icons.record_voice_over_rounded,
                                highlighted: selected,
                              ),
                              title: edition.name,
                              subtitle: [
                                if (edition.englishName.isNotEmpty &&
                                    edition.englishName != edition.name)
                                  ltrIsolate(edition.englishName),
                                languageName(edition.language),
                              ].join(' · '),
                              trailing: Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.chevron_left,
                              ),
                              onTap: () => onSelect(edition),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
          },
    );
  }
}

class AudioAyahQueue extends StatelessWidget {
  const AudioAyahQueue({
    super.key,
    required this.playback,
    required this.onPlay,
  });

  final RecitationActive playback;
  final ValueChanged<int>? onPlay;

  @override
  Widget build(BuildContext context) {
    final tracks = playback.playlist.tracks;
    return QuranIndexCard(
      sliver: SliverList.builder(
        itemCount: tracks.length,
        itemBuilder: (context, i) {
          final track = tracks[i];
          final selected = playback.trackIndex == i;
          return Semantics(
            selected: selected,
            child: ListTile(
              enabled: onPlay != null,
              leading: QuranIndexWell(
                label: toArabicNumerals(track.ayahNumber),
                highlighted: selected,
              ),
              title: Text(track.title),
              trailing: Icon(
                selected && playback.isPlaying
                    ? Icons.graphic_eq_rounded
                    : Icons.play_arrow_rounded,
              ),
              onTap: onPlay == null ? null : () => onPlay!(track.ayahId),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) => const SliverToBoxAdapter(
    child: StateMessage(
      icon: Icons.search_off_rounded,
      title: 'لا توجد نتائج',
      subtitle: 'جرّب البحث بكلمة أخرى',
    ),
  );
}
