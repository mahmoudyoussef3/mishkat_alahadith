import '../entities/library_statistics.dart';
import '../repos/library_repo.dart';

class GetCachedLibraryStatisticsUseCase {
  final LibraryRepo _repo;

  GetCachedLibraryStatisticsUseCase(this._repo);

  Future<LibraryStatistics?> call() => _repo.getCachedStatistics();
}
