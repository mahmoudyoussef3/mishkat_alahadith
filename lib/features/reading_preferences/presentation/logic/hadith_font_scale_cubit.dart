import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/entities/hadith_font_scale.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/usecases/get_hadith_font_scale_use_case.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/usecases/save_hadith_font_scale_use_case.dart';

/// App-wide size of hadith text. Changes apply immediately and are saved in
/// the background; a failed save keeps the choice for the session.
class HadithFontScaleCubit extends Cubit<HadithFontScale> {
  final GetHadithFontScaleUseCase _getFontScale;
  final SaveHadithFontScaleUseCase _saveFontScale;

  HadithFontScaleCubit(this._getFontScale, this._saveFontScale)
    : super(HadithFontScale.medium);

  Future<void> load() async {
    final result = await _getFontScale();
    if (result case ApiSuccess(:final data)) emit(data);
  }

  Future<void> select(HadithFontScale scale) async {
    if (scale == state) return;
    emit(scale);
    await _saveFontScale(scale);
  }

  Future<void> increase() => select(state.larger);

  Future<void> decrease() => select(state.smaller);
}
