import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';
import 'package:mishkat_almasabih/core/data/models/hadith_daily_response.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/datasources/custom_api_service.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/models/random_ahadith_model.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/repos/random_ahadith_repo_impl.dart';

class _FakeApi extends Fake implements CustomApiService {
  int calls = 0;

  @override
  Future<RandomAhadithResponse> getRandomAhadith() async {
    calls++;
    return RandomAhadithResponse(
      hadiths: [
        RandomHadithModel(
          hadithId: '9',
          hadith: 'من حسن إسلام المرء',
          title: 'ترك ما لا يعني',
          words_meanings: const [WordMeaning(word: 'يعنيه', meaning: 'يهمه')],
        ),
      ],
    );
  }
}

class _FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;
}

void main() {
  late _FakeApi api;
  late _FakeNetworkInfo network;
  late RandomAhadithRepoImpl repo;

  setUp(() {
    api = _FakeApi();
    network = _FakeNetworkInfo();
    repo = RandomAhadithRepoImpl(api, network);
  });

  test('maps the random hadith shape onto ExplainedHadith', () async {
    final result = await repo.getRandomAhadith();

    final hadith = (result as ApiSuccess<List<ExplainedHadith>>).data.single;
    expect(hadith.id, '9');
    expect(hadith.hadeeth, 'من حسن إسلام المرء');
    expect(hadith.hadeethIntro, 'ترك ما لا يعني');
    expect(hadith.wordsMeanings?.single.meaning, 'يهمه');
  });

  test('fails with the offline message without calling the API', () async {
    network.connected = false;

    final result = await repo.getRandomAhadith();

    expect((result as ApiFailure).failure.message, FailureMessages.noConnection);
    expect(api.calls, 0);
  });
}
