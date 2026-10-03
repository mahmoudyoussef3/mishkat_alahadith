import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/library_statistics.dart';
import '../repos/library_repo.dart';

class GetLibraryStatisticsUseCase {
  final LibraryRepo _repo;

  GetLibraryStatisticsUseCase(this._repo);

  Future<ApiResult<LibraryStatistics>> call() => _repo.getStatistics();
}
