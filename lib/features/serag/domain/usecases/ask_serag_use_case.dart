import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/serag_hadith_context.dart';
import '../repos/serag_repo.dart';

class AskSeragUseCase {
  final SeragRepo _repo;

  AskSeragUseCase(this._repo);

  Future<ApiResult<String>> call({
    required SeragHadithContext hadith,
    required String question,
  }) => _repo.ask(hadith: hadith, question: question);
}
