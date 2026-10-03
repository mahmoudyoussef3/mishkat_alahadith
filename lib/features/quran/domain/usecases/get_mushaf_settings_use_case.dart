import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/mushaf_reader_settings.dart';
import '../repos/quran_reading_repo.dart';

class GetMushafSettingsUseCase {
  final QuranReadingRepo _repo;

  GetMushafSettingsUseCase(this._repo);

  Future<ApiResult<MushafReaderSettings>> call() => _repo.getSettings();
}
