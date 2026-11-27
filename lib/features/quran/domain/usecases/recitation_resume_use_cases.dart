import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/recitation.dart';
import '../repos/quran_reading_repo.dart';

/// Where the last recitation was left off when the app was closed, if it
/// was not ended; null when there is nothing to pick up.
class GetRecitationResumePointUseCase {
  final QuranReadingRepo _repo;

  GetRecitationResumePointUseCase(this._repo);

  Future<ApiResult<RecitationResumePoint?>> call() =>
      _repo.getRecitationResumePoint();
}

/// Keeps where the recitation is, to pick it up again after the app is
/// closed; null once it is ended, so nothing is picked up.
class SaveRecitationResumePointUseCase {
  final QuranReadingRepo _repo;

  SaveRecitationResumePointUseCase(this._repo);

  Future<ApiResult<void>> call(RecitationResumePoint? point) =>
      _repo.saveRecitationResumePoint(point);
}
