import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/serag_hadith_context.dart';

abstract class SeragRepo {
  Future<ApiResult<String>> ask({
    required SeragHadithContext hadith,
    required String question,
  });
}
