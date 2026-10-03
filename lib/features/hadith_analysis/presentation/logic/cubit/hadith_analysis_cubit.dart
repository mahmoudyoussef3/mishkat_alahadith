import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/domain/entities/hadith_analysis_result.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/domain/usecases/analyze_hadith_use_case.dart';

part 'hadith_analysis_state.dart';

class HadithAnalysisCubit extends Cubit<HadithAnalysisState> {
  final AnalyzeHadithUseCase _analyzeHadith;
  HadithAnalysisCubit(this._analyzeHadith) : super(HadithAnalysisInitial());
  String sharhHadith = '';
  Future<void> analyzeHadith({
    required String hadith,
    required String attribution,
    required String grade,
    required String reference,
  }) async {
    emit(HadithAnalysisLoading());
    final result = await _analyzeHadith(
      hadith: hadith,
      attribution: attribution,
      grade: grade,
      reference: reference,
    );
    result.when(
      success: (analysis) {
        sharhHadith = analysis.analysis ?? '';
        emit(HadithAnalysisLoaded(analysis));
      },
      failure: (failure) => emit(HadithAnalysisError(failure.message)),
    );
  }
}
