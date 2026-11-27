import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_commentary.dart';
import '../entities/quran_metrics.dart';
import '../entities/recitation_settings.dart';
import '../repos/quran_cloud_repo.dart';

/// The reader's tafsir and translation of one ayah, in one request.
class GetAyahCommentaryUseCase {
  final QuranCloudRepo _repo;

  GetAyahCommentaryUseCase(this._repo);

  Future<ApiResult<AyahCommentary>> call(
    int ayahId,
    CommentarySettings settings,
  ) async {
    final ids = settings.editionIds;
    if (!QuranMetrics.isValidAyahId(ayahId) ||
        !ids.every(RecitationSettings.isValidEditionId)) {
      return const ApiResult.failure(UnexpectedFailure());
    }
    final result = await _repo.getAyahTexts(ayahId, ids);
    return switch (result) {
      ApiFailure(:final failure) => ApiResult.failure(failure),
      ApiSuccess(data: final texts) => ApiResult.success(
        commentaryOf(ayahId, texts, settings),
      ),
    };
  }

  /// Sorts [texts] into the tafsir and translation [settings] asked for.
  static AyahCommentary commentaryOf(
    int ayahId,
    Iterable<EditionText> texts,
    CommentarySettings settings,
  ) {
    EditionText? find(String? id) =>
        id == null
            ? null
            : texts
                .where(
                  (t) => t.edition.identifier == id && t.text.trim().isNotEmpty,
                )
                .firstOrNull;
    return AyahCommentary(
      ayahId: ayahId,
      tafsir: find(settings.tafsirId),
      translation: find(settings.translationId),
    );
  }
}
