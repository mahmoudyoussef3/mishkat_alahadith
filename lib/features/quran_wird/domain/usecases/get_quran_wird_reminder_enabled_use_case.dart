import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/quran_wird_repo.dart';

class GetQuranWirdReminderEnabledUseCase {
  final QuranWirdRepo _repo;

  GetQuranWirdReminderEnabledUseCase(this._repo);

  Future<ApiResult<bool>> call() => _repo.isReminderEnabled();
}
