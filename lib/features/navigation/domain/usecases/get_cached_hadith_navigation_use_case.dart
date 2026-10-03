import '../entities/hadith_navigation.dart';
import '../repos/navigation_repo.dart';

class GetCachedHadithNavigationUseCase {
  final NavigationRepo _repo;

  GetCachedHadithNavigationUseCase(this._repo);

  Future<HadithNavigation?> call({
    required String hadithNumber,
    required String bookSlug,
    required String chapterNumber,
  }) => _repo.getCachedNavigation(
    hadithNumber: hadithNumber,
    bookSlug: bookSlug,
    chapterNumber: chapterNumber,
  );
}
