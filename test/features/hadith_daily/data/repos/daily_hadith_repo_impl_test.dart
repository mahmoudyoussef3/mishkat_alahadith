import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';
import 'package:mishkat_almasabih/core/data/datasources/hadeethenc_datasource.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/datasources/daily_hadith_local_datasource.dart';
import 'package:mishkat_almasabih/core/data/models/new_daily_hadith_model.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/daily_hadith_repo_impl.dart';

class _FakeRemote implements HadeethEncDataSource {
  Object? error;
  int calls = 0;

  @override
  Future<NewDailyHadithModel> fetchHadith(String id) async {
    calls++;
    if (error != null) throw error!;
    return NewDailyHadithModel(
      id: id,
      hadeeth: 'الطهور شطر الإيمان',
      words_meanings: const [
        DailyHadithWordMeaning(word: 'الطهور', meaning: 'الطهارة'),
      ],
    );
  }
}

class _FakeLocal implements DailyHadithLocalDataSource {
  NewDailyHadithModel? saved;
  bool corrupt = false;

  @override
  Future<void> saveHadith(NewDailyHadithModel model) async => saved = model;

  @override
  Future<NewDailyHadithModel?> getHadith() async {
    if (corrupt) throw const FormatException('bad json');
    return saved;
  }
}

class _OfflineNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => false;
}

void main() {
  late _FakeRemote remote;
  late _FakeLocal local;
  late DailyHadithRepoImpl repo;

  setUp(() {
    remote = _FakeRemote();
    local = _FakeLocal();
    repo = DailyHadithRepoImpl(remote, local);
  });

  test('fetchAndSaveHadith saves the hadith and maps word meanings', () async {
    final result = await repo.fetchAndSaveHadith('42');

    final hadith = (result as ApiSuccess<ExplainedHadith>).data;
    expect(hadith.id, '42');
    expect(hadith.wordsMeanings?.single.meaning, 'الطهارة');
    expect(local.saved?.id, '42');
    expect((await repo.getSavedHadith())?.hadeeth, 'الطهور شطر الإيمان');
  });

  test(
    'fetchAndSaveHadith keeps the saved hadith when the fetch fails',
    () async {
      local.saved = const NewDailyHadithModel(id: 'old');
      remote.error = DioException(
        requestOptions: RequestOptions(path: '/hadeeths/one'),
        type: DioExceptionType.connectionError,
      );

      final result = await repo.fetchAndSaveHadith('42');

      expect((result as ApiFailure).failure, isA<NetworkFailure>());
      expect(local.saved?.id, 'old');
    },
  );

  test('getSavedHadith treats an unreadable saved hadith as none', () async {
    local.corrupt = true;

    expect(await repo.getSavedHadith(), isNull);
  });

  test('fails fast with the no-internet message when offline', () async {
    final offlineRepo = DailyHadithRepoImpl(
      remote,
      local,
      networkInfo: _OfflineNetworkInfo(),
    );

    final result = await offlineRepo.fetchAndSaveHadith('42');

    final failure = (result as ApiFailure).failure;
    expect(failure, isA<NetworkFailure>());
    expect(failure.message, FailureMessages.noConnection);
    expect(remote.calls, 0);
  });
}
