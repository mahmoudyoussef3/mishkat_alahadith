import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/send_suggestion/data/datasources/suggestion_remote_datasource.dart';
import 'package:mishkat_almasabih/features/send_suggestion/data/repos/suggestion_repo_impl.dart';

class _FakeRemote implements SuggestionRemoteDataSource {
  bool accepted = true;
  String? sent;

  @override
  Future<bool> sendSuggestion(String suggestion) async {
    sent = suggestion;
    return accepted;
  }
}

void main() {
  late _FakeRemote remote;
  late SuggestionRepoImpl repo;

  setUp(() {
    remote = _FakeRemote();
    repo = SuggestionRepoImpl(remote);
  });

  test('succeeds when the endpoint accepts the suggestion', () async {
    final result = await repo.sendSuggestion('اقتراح');

    expect(result, isA<ApiSuccess<void>>());
    expect(remote.sent, 'اقتراح');
  });

  test('returns a ServerFailure when the endpoint rejects it', () async {
    remote.accepted = false;

    final result = await repo.sendSuggestion('اقتراح');

    expect((result as ApiFailure).failure, isA<ServerFailure>());
  });
}
