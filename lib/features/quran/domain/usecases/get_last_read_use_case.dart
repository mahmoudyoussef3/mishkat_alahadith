import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_last_read.dart';
import '../repos/quran_reading_repo.dart';

class GetLastReadUseCase {
  final QuranReadingRepo _repo;

  GetLastReadUseCase(this._repo);

  Future<ApiResult<QuranLastRead?>> call() => _repo.getLastRead();
}
