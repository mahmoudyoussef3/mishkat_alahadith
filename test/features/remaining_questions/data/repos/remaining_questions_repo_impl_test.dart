import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';
import 'package:mishkat_almasabih/features/remaining_questions/data/models/remaining_questions_response_model.dart';
import 'package:mishkat_almasabih/features/remaining_questions/data/repos/remaining_questions_repo_impl.dart';
import 'package:mishkat_almasabih/features/remaining_questions/domain/entities/remaining_questions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  String? receivedToken;

  @override
  Future<RmainingQuestionsResponse> getReaminingQuestions(String token) async {
    receivedToken = token;
    return RmainingQuestionsResponse(remaining: 3, max: 5);
  }
}

void main() {
  late _FakeApiService api;
  late RemainingQuestionsRepoImpl repo;

  setUp(() {
    api = _FakeApiService();
    repo = RemainingQuestionsRepoImpl(api, TokenStorage());
  });

  test('sends the session token and maps the response to an entity', () async {
    SharedPreferences.setMockInitialValues({'token': 't1'});

    final result = await repo.getRemainingQuestions();

    expect(api.receivedToken, 't1');
    final data = (result as ApiSuccess<RemainingQuestions>).data;
    expect(data.remaining, 3);
    expect(data.max, 5);
  });

  test('returns UnauthorizedFailure without calling the API when signed out', () async {
    SharedPreferences.setMockInitialValues({});

    final result = await repo.getRemainingQuestions();

    expect(api.receivedToken, isNull);
    expect((result as ApiFailure).failure, isA<UnauthorizedFailure>());
  });
}
