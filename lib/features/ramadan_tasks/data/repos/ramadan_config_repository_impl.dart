import '../../domain/repos/ramadan_config_repository.dart';
import '../datasources/ramadan_config_remote_datasource.dart';

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

  @override
  String getRamadanStartGregorian() {
    return _remoteDataSource.getRamadanStartGregorian();
  }
}
