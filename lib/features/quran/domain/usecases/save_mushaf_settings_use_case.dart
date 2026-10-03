import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/mushaf_reader_settings.dart';
import '../repos/quran_reading_repo.dart';

class SaveMushafSettingsUseCase {
  final QuranReadingRepo _repo;

  SaveMushafSettingsUseCase(this._repo);

  Future<ApiResult<void>> call(MushafReaderSettings settings) =>
      _repo.saveSettings(settings);
}
