import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_last_read.dart';
import '../entities/quran_metrics.dart';
import '../repos/quran_reading_repo.dart';

class SaveLastReadUseCase {
  final QuranReadingRepo _repo;
  final DateTime Function() _now;

  SaveLastReadUseCase(this._repo, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  Future<ApiResult<void>> call(int page) async {
    if (!QuranMetrics.isValidPage(page)) {
      return const ApiResult.failure(UnexpectedFailure());
    }
    return _repo.saveLastRead(QuranLastRead(page: page, savedAt: _now()));
  }
}
