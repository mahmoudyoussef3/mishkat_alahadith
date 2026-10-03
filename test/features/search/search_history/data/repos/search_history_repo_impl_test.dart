import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';
import 'package:mishkat_almasabih/features/search/search_history/data/models/search_history_models.dart';
import 'package:mishkat_almasabih/features/search/search_history/data/repos/search_history_repo_impl.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/entities/search_history_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  AddSearchRequest? added;
  Map<String, dynamic>? clearBody;

  @override
  Future<GetSearchHistoryResponse> getSearchHistory(String token) async =>
      GetSearchHistoryResponse(
        success: true,
        data: [
          SearchHistoryItem(
            id: 1,
            title: 'الصلاة',
            time: '10:00:00',
            date: '2026-10-02',
            createdAt: '2026-10-02T10:00:00Z',
          ),
        ],
        pagination: Pagination(total: 1, limit: 10, offset: 0, hasMore: false),
      );

  @override
  Future<AddSearchResponse> addSearch(String token, AddSearchRequest body) async {
    added = body;
    return AddSearchResponse(success: true, message: 'ok', data: AddSearchData(id: 2));
  }

  @override
  Future<DeleteAllSearchResponse> deleteAllSearch(
    String token,
    Map<String, dynamic> body,
  ) async {
    clearBody = body;
    return DeleteAllSearchResponse(success: true, message: 'ok', deletedCount: 1);
  }
}

void main() {
  late _FakeApiService api;
  late SearchHistoryRepoImpl repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({'token': 't1'});
    api = _FakeApiService();
    repo = SearchHistoryRepoImpl(api, TokenStorage());
  });

  test('getHistory maps server items to entries', () async {
    final result = await repo.getHistory();

    final entry = (result as ApiSuccess<List<SearchHistoryEntry>>).data.single;
    expect(entry.title, 'الصلاة');
    expect(entry.createdAt, '2026-10-02T10:00:00Z');
  });

  test('addEntry sends the entry as an AddSearchRequest', () async {
    await repo.addEntry(
      const NewSearchHistoryEntry(title: 'الصيام', time: '11:00:00', date: '2026-10-02'),
    );

    expect(api.added?.title, 'الصيام');
    expect(api.added?.date, '2026-10-02');
  });

  test('clearHistory sends the confirmation body', () async {
    await repo.clearHistory();

    expect(api.clearBody, {'confirm': true});
  });

  test('fails with UnauthorizedFailure when signed out', () async {
    SharedPreferences.setMockInitialValues({});

    final result = await repo.getHistory();

    expect((result as ApiFailure).failure, isA<UnauthorizedFailure>());
  });
}
