import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/last_read_chapter.dart';
import '../repos/chapters_repo.dart';

class SaveLastReadChapterUseCase {
  final ChaptersRepo _repo;

  SaveLastReadChapterUseCase(this._repo);

  Future<ApiResult<void>> call(String bookSlug, LastReadChapter chapter) =>
      _repo.saveLastReadChapter(bookSlug, chapter);
}
