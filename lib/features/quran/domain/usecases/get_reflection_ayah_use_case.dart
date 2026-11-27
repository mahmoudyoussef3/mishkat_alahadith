import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_commentary.dart';
import '../entities/quran_surah.dart';
import '../entities/recitation_settings.dart';
import '../repos/quran_cloud_repo.dart';
import '../repos/quran_repo.dart';

/// An ayah picked at random, with its tafsir, to stop and reflect on.
class GetReflectionAyahUseCase {
  final QuranCloudRepo _cloud;
  final QuranRepo _quran;

  GetReflectionAyahUseCase(this._cloud, this._quran);

  Future<ApiResult<CommentedAyah>> call(CommentarySettings settings) async {
    if (!RecitationSettings.isValidEditionId(settings.tafsirId)) {
      return const ApiResult.failure(UnexpectedFailure());
    }
    final random = await _cloud.getRandomAyahText(settings.tafsirId);
    final AyahEditionText picked;
    switch (random) {
      case ApiFailure(:final failure):
        return ApiResult.failure(failure);
      case ApiSuccess(:final data):
        picked = data;
    }

    final (ayahResult, surahsResult) =
        await (_quran.getAyah(picked.ayahId), _quran.getSurahs()).wait;
    switch ((ayahResult, surahsResult)) {
      case (ApiFailure(:final failure), _):
      case (_, ApiFailure(:final failure)):
        return ApiResult.failure(failure);
      case (ApiSuccess(data: final ayah), ApiSuccess(data: final surahs)):
        final surah = QuranSurah.numbered(surahs, ayah.surahNumber);
        if (surah == null) return const ApiResult.failure(UnexpectedFailure());
        return ApiResult.success(
          CommentedAyah(
            ayah: ayah,
            surah: surah,
            commentary: AyahCommentary(
              ayahId: ayah.id,
              tafsir: picked.text.text.trim().isEmpty ? null : picked.text,
            ),
          ),
        );
    }
  }
}
