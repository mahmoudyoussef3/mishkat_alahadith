import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_ayah.dart';
import '../entities/quran_metrics.dart';
import '../entities/quran_surah.dart';
import '../entities/recitation.dart';
import '../entities/recitation_settings.dart';
import '../repos/quran_cloud_repo.dart';
import '../repos/quran_repo.dart';

/// A playlist ready to play, and the track to start on.
typedef RecitationStart = ({RecitationPlaylist playlist, int startIndex});

/// Turns what the reader asked to hear into a playlist: the reciter's audio
/// from the service, each ayah placed on its page of the bundled mushaf so
/// the reader can follow along.
class LoadRecitationUseCase {
  final QuranCloudRepo _cloud;
  final QuranRepo _quran;

  LoadRecitationUseCase(this._cloud, this._quran);

  Future<ApiResult<RecitationStart>> call(
    RecitationRequest request,
    RecitationSettings settings,
  ) async {
    if (!RecitationSettings.isValidEditionId(settings.reciterId)) {
      return const ApiResult.failure(
        UnexpectedFailure(FailureMessages.audioUnavailable),
      );
    }

    final RecitationScope scope;
    int? startAyahId;
    switch (request) {
      case RecitationFromAyah(:final ayahId):
        if (!QuranMetrics.isValidAyahId(ayahId)) {
          return const ApiResult.failure(UnexpectedFailure());
        }
        switch (await _quran.getAyah(ayahId)) {
          case ApiFailure(:final failure):
            return ApiResult.failure(failure);
          case ApiSuccess(data: final ayah):
            scope = RecitationScope.surah(ayah.surahNumber);
            startAyahId = ayahId;
        }
      case RecitationOfScope(scope: final requested, startAyahId: final from):
        if (!requested.isValid) {
          return const ApiResult.failure(UnexpectedFailure());
        }
        scope = requested;
        startAyahId = from;
    }

    final (audioResult, ayahsResult, surahsResult) =
        await (
          _cloud.getRecitation(settings.reciterId, scope),
          _quran.getAllAyahs(),
          _quran.getSurahs(),
        ).wait;

    switch ((audioResult, ayahsResult, surahsResult)) {
      case (ApiFailure(:final failure), _, _):
      case (_, ApiFailure(:final failure), _):
      case (_, _, ApiFailure(:final failure)):
        return ApiResult.failure(failure);
      case (
        ApiSuccess(data: final audio),
        ApiSuccess(data: final ayahs),
        ApiSuccess(data: final surahs),
      ):
        final tracks = _tracks(audio, ayahs, surahs, settings.quality);
        if (tracks.isEmpty) {
          return const ApiResult.failure(
            ServerFailure(FailureMessages.audioUnavailable),
          );
        }
        final playlist = RecitationPlaylist(
          scope: scope,
          reciterId: settings.reciterId,
          tracks: List.unmodifiable(tracks),
        );
        final start =
            startAyahId == null ? 0 : playlist.indexOfAyah(startAyahId);
        return ApiResult.success((
          playlist: playlist,
          startIndex: start < 0 ? 0 : start,
        ));
    }
  }

  /// The audio in mushaf order, each ayah once, dropping any the bundled
  /// mushaf cannot place.
  static List<RecitationTrack> _tracks(
    List<RecitationAudio> audio,
    List<QuranAyah> ayahs,
    List<QuranSurah> surahs,
    RecitationQuality quality,
  ) {
    final surahNames = {for (final s in surahs) s.number: s.nameArabic};
    final seen = <int>{};
    final tracks = <RecitationTrack>[];
    for (final entry in audio) {
      final ayah = QuranAyah.withId(ayahs, entry.ayahId);
      if (ayah == null || !seen.add(ayah.id)) continue;
      final url = switch (quality) {
        RecitationQuality.high => entry.url,
        RecitationQuality.dataSaver =>
          entry.lowBitrateUrls.firstOrNull ?? entry.url,
      };
      tracks.add(
        RecitationTrack(
          ayahId: ayah.id,
          surahNumber: ayah.surahNumber,
          surahName: surahNames[ayah.surahNumber] ?? '',
          ayahNumber: ayah.number,
          page: ayah.page,
          url: url,
        ),
      );
    }
    tracks.sort((a, b) => a.ayahId.compareTo(b.ayahId));
    return tracks;
  }
}
