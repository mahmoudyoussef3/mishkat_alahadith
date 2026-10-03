import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/hadith_analysis_result.dart';

abstract class HadithAnalysisRepo {
  Future<ApiResult<HadithAnalysisResult>> analyzeHadith({
    required String hadith,
    required String attribution,
    required String grade,
    required String reference,
  });
}
