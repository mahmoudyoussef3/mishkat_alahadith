import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/chat_message.dart';
import '../entities/serag_hadith_context.dart';

abstract class SeragRepo {
  /// Siraj's reply to the last message of [conversation], which is the
  /// user's question; earlier turns give it context for follow-ups.
  Future<ApiResult<String>> ask({
    required SeragHadithContext hadith,
    required List<ChatMessage> conversation,
  });
}
