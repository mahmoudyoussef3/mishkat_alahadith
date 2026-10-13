import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/chat_message.dart';
import '../entities/serag_hadith_context.dart';
import '../repos/serag_repo.dart';

class AskSeragUseCase {
  final SeragRepo _repo;

  AskSeragUseCase(this._repo);

  Future<ApiResult<String>> call({
    required SeragHadithContext hadith,
    required List<ChatMessage> conversation,
  }) => _repo.ask(hadith: hadith, conversation: conversation);
}
