import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/data/models/hadith_analysis_request.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/data/models/hadith_analysis_response.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/data/repos/hadith_analysis_repo_impl.dart';
import 'package:mishkat_almasabih/features/hadith_analysis/domain/entities/hadith_analysis_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  int calls = 0;
  Object? error;

  @override
  Future<HadithAnalysisResponse> hadithAnalysis(
    HadithAnalysisRequest body,
    String token,
  ) async {
    calls++;
    if (error != null) throw error!;
    return HadithAnalysisResponse(hadith: body.hadeeth, analysis: 'تحليل $calls');
  }
}

void main() {
  final cache = GenericCacheService.instance;
  late _FakeApiService api;
  late HadithAnalysisRepoImpl repo;

  setUpAll(() => SharedPreferences.setMockInitialValues({'token': 't1'}));

  setUp(() {
    api = _FakeApiService();
    repo = HadithAnalysisRepoImpl(api, TokenStorage(), cache);
  });

  tearDown(
    () => cache.clearCache(CacheKeys.hadithAnalysis('إنما الأعمال', 'البخاري', 'صحيح', '1')),
  );

  Future<ApiResult<HadithAnalysisResult>> analyze() => repo.analyzeHadith(
    hadith: 'إنما الأعمال',
    attribution: 'البخاري',
    grade: 'صحيح',
    reference: '1',
  );

  test('asks the server every time while online', () async {
    await analyze();

    final result = await analyze();

    expect((result as ApiSuccess<HadithAnalysisResult>).data.analysis, 'تحليل 2');
    expect(api.calls, 2);
  });

  test('offline, returns the last analysis of the same hadith', () async {
    await analyze();
    api.error = DioException(
      requestOptions: RequestOptions(path: '/analysis'),
      type: DioExceptionType.connectionError,
    );

    final result = await analyze();

    expect((result as ApiSuccess<HadithAnalysisResult>).data.analysis, 'تحليل 1');
  });

  test('a refusal from the server is passed on, not covered by the last analysis', () async {
    await analyze();
    api.error = DioException(
      requestOptions: RequestOptions(path: '/analysis'),
      response: Response(requestOptions: RequestOptions(path: '/analysis'), statusCode: 429),
      type: DioExceptionType.badResponse,
    );

    final result = await analyze();

    expect((result as ApiFailure).failure, isA<ServerFailure>());
  });
}
