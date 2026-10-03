import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/serag/data/repos/chat_history_repo_impl.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final repo = ChatHistoryRepoImpl();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('loads nothing when no conversation is saved', () async {
    expect(await repo.loadMessages(), isEmpty);
  });

  test('round-trips messages in the stored JSON format', () async {
    await repo.saveMessages(const [
      ChatMessage(role: 'user', content: 'سؤال'),
      ChatMessage(role: 'assistant', content: 'جواب'),
    ]);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('serag_messages'), contains('"role":"assistant"'));

    final loaded = await repo.loadMessages();
    expect(loaded.map((m) => m.content), ['سؤال', 'جواب']);
  });

  test('clearMessages removes the saved conversation', () async {
    await repo.saveMessages(const [ChatMessage(role: 'user', content: 'x')]);

    await repo.clearMessages();

    expect(await repo.loadMessages(), isEmpty);
  });

  test('treats an unreadable saved conversation as empty', () async {
    SharedPreferences.setMockInitialValues({'serag_messages': '{not json'});

    expect(await repo.loadMessages(), isEmpty);
  });
}
