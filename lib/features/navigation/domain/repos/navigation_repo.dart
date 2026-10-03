import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/hadith_navigation.dart';

abstract class NavigationRepo {
  Future<HadithNavigation?> getCachedNavigation({
    required String hadithNumber,
    required String bookSlug,
    required String chapterNumber,
  });

  Future<ApiResult<HadithNavigation>> getNavigation({
    required String hadithNumber,
    required String bookSlug,
    required String chapterNumber,
  });

  Future<ApiResult<HadithNavigation>> getLocalNavigation({
    required String hadithNumber,
    required String bookSlug,
  });
}
