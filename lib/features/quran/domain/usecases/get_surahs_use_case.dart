import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_surah.dart';
import '../repos/quran_repo.dart';

class GetSurahsUseCase {
  final QuranRepo _repo;

  GetSurahsUseCase(this._repo);

  Future<ApiResult<List<QuranSurah>>> call() => _repo.getSurahs();
}
