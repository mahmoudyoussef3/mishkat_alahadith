import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/last_read_chapter.dart';
import '../repos/chapters_repo.dart';

class GetLastReadChapterUseCase {
  final ChaptersRepo _repo;

  GetLastReadChapterUseCase(this._repo);

  Future<ApiResult<LastReadChapter?>> call(String bookSlug) =>
      _repo.getLastReadChapter(bookSlug);
}
