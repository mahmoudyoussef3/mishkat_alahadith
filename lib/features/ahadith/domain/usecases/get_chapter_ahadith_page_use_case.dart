import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/chapter_ahadith_page.dart';
import '../repos/ahadith_repo.dart';

class GetChapterAhadithPageUseCase {
  final AhadithRepo _repo;

  GetChapterAhadithPageUseCase(this._repo);

  Future<ApiResult<ChapterAhadithPage>> call({
    required String bookSlug,
    required int chapterId,
    required int page,
    required int paginate,
  }) => _repo.getAhadithPage(
    bookSlug: bookSlug,
    chapterId: chapterId,
    page: page,
    paginate: paginate,
  );
}
