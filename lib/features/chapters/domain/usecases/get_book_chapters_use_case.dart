import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/book_chapter.dart';
import '../repos/chapters_repo.dart';

class GetBookChaptersUseCase {
  final ChaptersRepo _repo;

  GetBookChaptersUseCase(this._repo);

  Future<ApiResult<List<BookChapter>>> call(String bookSlug) =>
      _repo.getChapters(bookSlug);
}
