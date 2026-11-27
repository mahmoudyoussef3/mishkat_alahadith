import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/reading_preferences/data/datasources/reading_preferences_local_datasource.dart';
import 'package:mishkat_almasabih/features/reading_preferences/data/repos/reading_preferences_repo_impl.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/entities/hadith_font_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ThrowingDataSource implements ReadingPreferencesLocalDataSource {
  @override
  Future<String?> getHadithFontScale() async =>
      throw Exception('prefs unavailable');

  @override
  Future<void> saveHadithFontScale(String scale) async =>
      throw Exception('prefs unavailable');
}

HadithFontScale _scaleOf(ApiResult<HadithFontScale> result) =>
    (result as ApiSuccess<HadithFontScale>).data;

void main() {
  late ReadingPreferencesRepoImpl repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = ReadingPreferencesRepoImpl(ReadingPreferencesLocalDataSource());
  });

  test('getHadithFontScale is medium when nothing has been saved', () async {
    expect(_scaleOf(await repo.getHadithFontScale()), HadithFontScale.medium);
  });

  test('getHadithFontScale returns the size saved before', () async {
    final saved = await repo.saveHadithFontScale(HadithFontScale.large);

    expect(saved, isA<ApiSuccess<void>>());
    expect(_scaleOf(await repo.getHadithFontScale()), HadithFontScale.large);
  });

  test('getHadithFontScale falls back to medium for an unknown value', () async {
    SharedPreferences.setMockInitialValues({'hadith_font_scale': 'huge'});

    expect(_scaleOf(await repo.getHadithFontScale()), HadithFontScale.medium);
  });

  test('getHadithFontScale maps a storage error to CacheFailure', () async {
    final result =
        await ReadingPreferencesRepoImpl(
          _ThrowingDataSource(),
        ).getHadithFontScale();

    expect((result as ApiFailure).failure, isA<CacheFailure>());
  });

  test('saveHadithFontScale maps a storage error to CacheFailure', () async {
    final result = await ReadingPreferencesRepoImpl(
      _ThrowingDataSource(),
    ).saveHadithFontScale(HadithFontScale.small);

    expect((result as ApiFailure).failure, isA<CacheFailure>());
  });
}
