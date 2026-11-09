part of 'surah_tafsir_cubit.dart';

@immutable
sealed class SurahTafsirState {
  final CommentarySettings settings;

  const SurahTafsirState(this.settings);
}

final class SurahTafsirLoading extends SurahTafsirState {
  const SurahTafsirLoading(super.settings);
}

final class SurahTafsirLoaded extends SurahTafsirState {
  final QuranSurah surah;
  final List<CommentedAyah> ayahs;

  /// The ayah the reading began at; 1 for the whole surah.
  final int startAyah;

  final int nextOffset;
  final bool hasMore;
  final bool isLoadingMore;

  /// Why the last page could not be loaded; null when it could.
  final String? loadMoreFailure;

  const SurahTafsirLoaded(
    super.settings, {
    required this.surah,
    required this.ayahs,
    required this.startAyah,
    required this.nextOffset,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  bool get startsMidway => startAyah > 1;

  SurahTafsirLoaded copyWith({
    List<CommentedAyah>? ayahs,
    int? nextOffset,
    bool? hasMore,
    bool? isLoadingMore,
    String? Function()? loadMoreFailure,
  }) {
    return SurahTafsirLoaded(
      settings,
      surah: surah,
      ayahs: ayahs ?? this.ayahs,
      startAyah: startAyah,
      nextOffset: nextOffset ?? this.nextOffset,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailure:
          loadMoreFailure != null ? loadMoreFailure() : this.loadMoreFailure,
    );
  }
}

final class SurahTafsirFailure extends SurahTafsirState {
  final String message;

  const SurahTafsirFailure(super.settings, this.message);
}
