import '../../domain/repositories/ramadan_config_repository.dart';
import '../datasources/ramadan_config_remote_datasource.dart';

/// Implementation of Ramadan configuration repository.
///
/// Delegates to the remote datasource while providing a clean domain interface.
class RamadanConfigRepositoryImpl implements RamadanConfigRepository {
  final RamadanConfigRemoteDataSource _remoteDataSource;

  RamadanConfigRepositoryImpl({
    required RamadanConfigRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<void> initializeRemoteConfig() async {
    await _remoteDataSource.fetchAndActivate();
  }

  @override
  int getRamadanStartOffset() {
    return _remoteDataSource.getRamadanStartOffset();
  }

  @override
  int getRamadanTotalDays() {
    return _remoteDataSource.getRamadanTotalDays();
  }
}
