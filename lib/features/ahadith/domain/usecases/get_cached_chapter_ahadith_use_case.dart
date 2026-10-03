import '../entities/chapter_ahadith_page.dart';
import '../repos/ahadith_repo.dart';

class GetCachedChapterAhadithUseCase {
  final AhadithRepo _repo;

  GetCachedChapterAhadithUseCase(this._repo);

  Future<CachedChapterAhadith?> call({
    required String bookSlug,
    required int chapterId,
  }) => _repo.getCachedAhadith(bookSlug: bookSlug, chapterId: chapterId);
}
