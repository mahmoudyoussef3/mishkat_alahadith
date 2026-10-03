import '../../domain/entities/hadith_analysis_result.dart';
import '../models/hadith_analysis_response.dart';

extension HadithAnalysisMapper on HadithAnalysisResponse {
  HadithAnalysisResult toEntity() => HadithAnalysisResult(
    hadith: hadith,
    attribution: attribution,
    analysis: analysis,
    timestamp: timestamp,
  );
}
