import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/hadith_analysis_result.dart';
import '../repos/hadith_analysis_repo.dart';

class AnalyzeHadithUseCase {
  final HadithAnalysisRepo _repo;

  AnalyzeHadithUseCase(this._repo);

  Future<ApiResult<HadithAnalysisResult>> call({
    required String hadith,
    required String attribution,
    required String grade,
    required String reference,
  }) => _repo.analyzeHadith(
    hadith: hadith,
    attribution: attribution,
    grade: grade,
    reference: reference,
  );
}
