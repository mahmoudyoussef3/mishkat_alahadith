import '../../domain/entities/chat_message.dart';
import '../../domain/entities/serag_hadith_context.dart';
import '../models/serag_request_model.dart';

extension SeragHadithContextMapper on SeragHadithContext {
  Hadith toModel() => Hadith(
    hadeeth: hadeeth,
    grade_ar: gradeAr,
    source: source,
    takhrij_ar: takhrijAr,
  );
}

extension ChatMessageMapper on ChatMessage {
  Message toModel() => Message(role: role, content: content);
}

extension MessageMapper on Message {
  ChatMessage toEntity() => ChatMessage(role: role, content: content);
}
