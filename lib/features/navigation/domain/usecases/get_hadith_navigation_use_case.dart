import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/hadith_navigation.dart';
import '../repos/navigation_repo.dart';

class GetHadithNavigationUseCase {
  final NavigationRepo _repo;

  GetHadithNavigationUseCase(this._repo);

  Future<ApiResult<HadithNavigation>> call({
    required String hadithNumber,
    required String bookSlug,
    required String chapterNumber,
  }) => _repo.getNavigation(
    hadithNumber: hadithNumber,
    bookSlug: bookSlug,
    chapterNumber: chapterNumber,
  );
}
