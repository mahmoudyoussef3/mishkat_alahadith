import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/theme/data/datasources/theme_local_datasource.dart';
import 'package:mishkat_almasabih/features/theme/data/repos/theme_repo_impl.dart';
import 'package:mishkat_almasabih/features/theme/domain/entities/app_theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ThrowingDataSource implements ThemeLocalDataSource {
  @override
  Future<String?> getThemeMode() async => throw Exception('prefs unavailable');

  @override
  Future<void> saveThemeMode(String mode) async =>
      throw Exception('prefs unavailable');
}

AppThemeMode _modeOf(ApiResult<AppThemeMode> result) =>
    (result as ApiSuccess<AppThemeMode>).data;

void main() {
  late ThemeRepoImpl repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = ThemeRepoImpl(ThemeLocalDataSource());
  });

  test('getThemeMode is light when nothing has been saved', () async {
    expect(_modeOf(await repo.getThemeMode()), AppThemeMode.light);
  });

  test('getThemeMode returns the mode saved by saveThemeMode', () async {
    final saved = await repo.saveThemeMode(AppThemeMode.dark);

    expect(saved, isA<ApiSuccess<void>>());
    expect(_modeOf(await repo.getThemeMode()), AppThemeMode.dark);
  });

  test('getThemeMode falls back to light for an unknown stored value', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'sepia'});

    expect(_modeOf(await repo.getThemeMode()), AppThemeMode.light);
  });

  test('getThemeMode maps a storage error to CacheFailure', () async {
    final result = await ThemeRepoImpl(_ThrowingDataSource()).getThemeMode();

    expect((result as ApiFailure).failure, isA<CacheFailure>());
  });

  test('saveThemeMode maps a storage error to CacheFailure', () async {
    final result = await ThemeRepoImpl(
      _ThrowingDataSource(),
    ).saveThemeMode(AppThemeMode.dark);

    expect((result as ApiFailure).failure, isA<CacheFailure>());
  });
}
