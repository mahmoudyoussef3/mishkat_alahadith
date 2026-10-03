import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_request_model.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_response_model.dart';
import 'package:mishkat_almasabih/features/serag/data/repos/serag_repo_impl.dart';
import 'package:mishkat_almasabih/features/serag/domain/entities/serag_hadith_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  SeragRequestModel? request;

  @override
  Future<SeragResponseModel> serag(SeragRequestModel body, String token) async {
    request = body;
    return SeragResponseModel(response: 'الجواب');
  }
}

const _hadith = SeragHadithContext(
  hadeeth: 'إنما الأعمال بالنيات',
  gradeAr: 'صحيح',
  source: 'البخاري',
  takhrijAr: 'متفق عليه',
);

void main() {
  late _FakeApiService api;
  late SeragRepoImpl repo;

  setUp(() {
    api = _FakeApiService();
    repo = SeragRepoImpl(api, TokenStorage());
  });

  test('sends the hadith context and the question as a user message', () async {
    SharedPreferences.setMockInitialValues({'token': 't1'});

    final result = await repo.ask(hadith: _hadith, question: 'ما معنى النية؟');

    expect((result as ApiSuccess<String>).data, 'الجواب');
    expect(api.request?.hadith.grade_ar, 'صحيح');
    expect(api.request?.hadith.takhrij_ar, 'متفق عليه');
    expect(api.request?.messages.single.role, 'user');
    expect(api.request?.messages.single.content, 'ما معنى النية؟');
  });

  test('fails with UnauthorizedFailure when signed out', () async {
    SharedPreferences.setMockInitialValues({});

    final result = await repo.ask(hadith: _hadith, question: 'سؤال');

    expect((result as ApiFailure).failure, isA<UnauthorizedFailure>());
    expect(api.request, isNull);
  });
}
