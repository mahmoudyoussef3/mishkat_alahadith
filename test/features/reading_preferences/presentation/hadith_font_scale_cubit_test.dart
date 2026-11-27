import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/entities/hadith_font_scale.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/repos/reading_preferences_repo.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/usecases/get_hadith_font_scale_use_case.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/usecases/save_hadith_font_scale_use_case.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/logic/hadith_font_scale_cubit.dart';

class _FakeRepo implements ReadingPreferencesRepo {
  HadithFontScale stored;
  bool failReads;
  bool failWrites;
  final saved = <HadithFontScale>[];

  _FakeRepo({
    this.stored = HadithFontScale.medium,
    this.failReads = false,
    this.failWrites = false,
  });

  @override
  Future<ApiResult<HadithFontScale>> getHadithFontScale() async =>
      failReads
          ? const ApiResult.failure(CacheFailure())
          : ApiResult.success(stored);

  @override
  Future<ApiResult<void>> saveHadithFontScale(HadithFontScale scale) async {
    if (failWrites) return const ApiResult.failure(CacheFailure());
    saved.add(scale);
    stored = scale;
    return const ApiResult.success(null);
  }
}

HadithFontScaleCubit _cubitWith(_FakeRepo repo) => HadithFontScaleCubit(
  GetHadithFontScaleUseCase(repo),
  SaveHadithFontScaleUseCase(repo),
);

void main() {
  test('starts at the medium size', () async {
    final cubit = _cubitWith(_FakeRepo());

    expect(cubit.state, HadithFontScale.medium);

    await cubit.close();
  });

  test('load restores the saved size', () async {
    final cubit = _cubitWith(_FakeRepo(stored: HadithFontScale.extraLarge));

    await cubit.load();

    expect(cubit.state, HadithFontScale.extraLarge);
    await cubit.close();
  });

  test('load stays at medium when the saved size cannot be read', () async {
    final cubit = _cubitWith(_FakeRepo(failReads: true));

    await cubit.load();

    expect(cubit.state, HadithFontScale.medium);
    await cubit.close();
  });

  test('select applies and saves the chosen size', () async {
    final repo = _FakeRepo();
    final cubit = _cubitWith(repo);

    await cubit.select(HadithFontScale.small);

    expect(cubit.state, HadithFontScale.small);
    expect(repo.saved, [HadithFontScale.small]);
    await cubit.close();
  });

  test('select does not save the size that is already chosen', () async {
    final repo = _FakeRepo();
    final cubit = _cubitWith(repo);

    await cubit.select(HadithFontScale.medium);

    expect(repo.saved, isEmpty);
    await cubit.close();
  });

  test('increase steps up one size', () async {
    final cubit = _cubitWith(_FakeRepo());

    await cubit.increase();

    expect(cubit.state, HadithFontScale.large);
    await cubit.close();
  });

  test('decrease steps down one size', () async {
    final cubit = _cubitWith(_FakeRepo());

    await cubit.decrease();

    expect(cubit.state, HadithFontScale.small);
    await cubit.close();
  });

  test('keeps the new size for the session when saving fails', () async {
    final cubit = _cubitWith(_FakeRepo(failWrites: true));

    await cubit.select(HadithFontScale.large);

    expect(cubit.state, HadithFontScale.large);
    await cubit.close();
  });
}
