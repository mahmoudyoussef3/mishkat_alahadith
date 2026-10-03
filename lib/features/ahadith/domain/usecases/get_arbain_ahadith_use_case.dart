import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/local_book_hadith.dart';
import '../repos/ahadith_repo.dart';

class GetArbainAhadithUseCase {
  final AhadithRepo _repo;

  GetArbainAhadithUseCase(this._repo);

  Future<ApiResult<List<LocalBookHadith>>> call({
    required String bookSlug,
    required int chapterId,
  }) => _repo.getArbainAhadith(bookSlug: bookSlug, chapterId: chapterId);
}
