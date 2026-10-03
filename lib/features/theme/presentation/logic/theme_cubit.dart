import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/theme/domain/entities/app_theme_mode.dart';
import 'package:mishkat_almasabih/features/theme/domain/usecases/get_theme_mode_use_case.dart';
import 'package:mishkat_almasabih/features/theme/domain/usecases/save_theme_mode_use_case.dart';

class ThemeCubit extends Cubit<AppThemeMode> {
  final GetThemeModeUseCase _getThemeMode;
  final SaveThemeModeUseCase _saveThemeMode;

  ThemeCubit(this._getThemeMode, this._saveThemeMode)
    : super(AppThemeMode.light);

  Future<void> load() async {
    final result = await _getThemeMode();
    if (result case ApiSuccess(:final data)) emit(data);
  }

  Future<void> toggle() async {
    final mode = state.toggled;
    emit(mode);
    await _saveThemeMode(mode);
  }
}
