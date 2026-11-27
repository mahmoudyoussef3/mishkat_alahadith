import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/recitation_settings.dart';
import '../repos/quran_reading_repo.dart';

class GetRecitationSettingsUseCase {
  final QuranReadingRepo _repo;

  GetRecitationSettingsUseCase(this._repo);

  Future<ApiResult<RecitationSettings>> call() => _repo.getRecitationSettings();
}

class SaveRecitationSettingsUseCase {
  final QuranReadingRepo _repo;

  SaveRecitationSettingsUseCase(this._repo);

  Future<ApiResult<void>> call(RecitationSettings settings) async {
    if (!RecitationSettings.isValidEditionId(settings.reciterId)) {
      return const ApiResult.failure(UnexpectedFailure());
    }
    return _repo.saveRecitationSettings(settings);
  }
}

class GetCommentarySettingsUseCase {
  final QuranReadingRepo _repo;

  GetCommentarySettingsUseCase(this._repo);

  Future<ApiResult<CommentarySettings>> call() => _repo.getCommentarySettings();
}

class SaveCommentarySettingsUseCase {
  final QuranReadingRepo _repo;

  SaveCommentarySettingsUseCase(this._repo);

  Future<ApiResult<void>> call(CommentarySettings settings) async {
    if (!settings.editionIds.every(RecitationSettings.isValidEditionId)) {
      return const ApiResult.failure(UnexpectedFailure());
    }
    return _repo.saveCommentarySettings(settings);
  }
}
