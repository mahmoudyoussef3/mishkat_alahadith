import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/theme/domain/entities/app_theme_mode.dart';
import 'package:mishkat_almasabih/features/theme/domain/repos/theme_repo.dart';
import 'package:mishkat_almasabih/features/theme/domain/usecases/get_theme_mode_use_case.dart';
import 'package:mishkat_almasabih/features/theme/domain/usecases/save_theme_mode_use_case.dart';
import 'package:mishkat_almasabih/features/theme/presentation/logic/theme_cubit.dart';

class _FakeThemeRepo implements ThemeRepo {
  AppThemeMode stored;
  bool failReads;
  bool failWrites;
  final saved = <AppThemeMode>[];

  _FakeThemeRepo({
    this.stored = AppThemeMode.light,
    this.failReads = false,
    this.failWrites = false,
  });

  @override
  Future<ApiResult<AppThemeMode>> getThemeMode() async =>
      failReads
          ? const ApiResult.failure(CacheFailure())
          : ApiResult.success(stored);

  @override
  Future<ApiResult<void>> saveThemeMode(AppThemeMode mode) async {
    if (failWrites) return const ApiResult.failure(CacheFailure());
    saved.add(mode);
    stored = mode;
    return const ApiResult.success(null);
  }
}

ThemeCubit _cubitWith(_FakeThemeRepo repo) =>
    ThemeCubit(GetThemeModeUseCase(repo), SaveThemeModeUseCase(repo));

void main() {
  test('starts in light mode', () async {
    final cubit = _cubitWith(_FakeThemeRepo());

    expect(cubit.state, AppThemeMode.light);

    await cubit.close();
  });

  test('load restores the saved dark mode', () async {
    final cubit = _cubitWith(_FakeThemeRepo(stored: AppThemeMode.dark));

    await cubit.load();

    expect(cubit.state, AppThemeMode.dark);
    await cubit.close();
  });

  test('load stays light when the saved mode cannot be read', () async {
    final cubit = _cubitWith(_FakeThemeRepo(failReads: true));

    await cubit.load();

    expect(cubit.state, AppThemeMode.light);
    await cubit.close();
  });

  test('toggle switches to dark and saves it', () async {
    final repo = _FakeThemeRepo();
    final cubit = _cubitWith(repo);

    await cubit.toggle();

    expect(cubit.state, AppThemeMode.dark);
    expect(repo.saved, [AppThemeMode.dark]);
    await cubit.close();
  });

  test('toggling twice returns to light and saves both choices', () async {
    final repo = _FakeThemeRepo();
    final cubit = _cubitWith(repo);

    await cubit.toggle();
    await cubit.toggle();

    expect(cubit.state, AppThemeMode.light);
    expect(repo.saved, [AppThemeMode.dark, AppThemeMode.light]);
    await cubit.close();
  });

  test('toggle keeps the new mode for the session when saving fails', () async {
    final cubit = _cubitWith(_FakeThemeRepo(failWrites: true));

    await cubit.toggle();

    expect(cubit.state, AppThemeMode.dark);
    await cubit.close();
  });
}
