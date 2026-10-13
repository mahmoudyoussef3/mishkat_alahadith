import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/entities/hadith_font_scale.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/repos/reading_preferences_repo.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/usecases/get_hadith_font_scale_use_case.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/usecases/save_hadith_font_scale_use_case.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/logic/hadith_font_scale_cubit.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/ui/hadith_text.dart';

class _MemoryRepo implements ReadingPreferencesRepo {
  @override
  Future<ApiResult<HadithFontScale>> getHadithFontScale() async =>
      const ApiResult.success(HadithFontScale.medium);

  @override
  Future<ApiResult<void>> saveHadithFontScale(HadithFontScale scale) async =>
      const ApiResult.success(null);
}

const _style = TextStyle(fontSize: 20);

double _scaledFontSize(WidgetTester tester) {
  final text = tester.widget<Text>(find.byType(Text));
  return text.textScaler!.scale(_style.fontSize!);
}

void main() {
  testWidgets('keeps the designed size without a font scale cubit', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: HadithText('حديث', style: _style),
      ),
    );

    expect(_scaledFontSize(tester), 20);
  });

  testWidgets('scales to the chosen size and follows changes', (tester) async {
    final repo = _MemoryRepo();
    final cubit = HadithFontScaleCubit(
      GetHadithFontScaleUseCase(repo),
      SaveHadithFontScaleUseCase(repo),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: HadithText('حديث', style: _style),
        ),
      ),
    );
    expect(_scaledFontSize(tester), 20);

    await cubit.select(HadithFontScale.extraLarge);
    await tester.pump();

    expect(_scaledFontSize(tester), closeTo(26, 0.001));
  });
}
