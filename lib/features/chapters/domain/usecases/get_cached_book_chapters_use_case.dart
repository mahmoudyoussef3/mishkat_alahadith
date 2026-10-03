import '../entities/book_chapter.dart';
import '../repos/chapters_repo.dart';

class GetCachedBookChaptersUseCase {
  final ChaptersRepo _repo;

  GetCachedBookChaptersUseCase(this._repo);

  Future<List<BookChapter>?> call(String bookSlug) =>
      _repo.getCachedChapters(bookSlug);
}
