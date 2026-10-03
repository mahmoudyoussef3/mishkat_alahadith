import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/hadith_navigation.dart';
import '../repos/navigation_repo.dart';

class GetLocalHadithNavigationUseCase {
  final NavigationRepo _repo;

  GetLocalHadithNavigationUseCase(this._repo);

  Future<ApiResult<HadithNavigation>> call({
    required String hadithNumber,
    required String bookSlug,
  }) =>
      _repo.getLocalNavigation(hadithNumber: hadithNumber, bookSlug: bookSlug);
}
