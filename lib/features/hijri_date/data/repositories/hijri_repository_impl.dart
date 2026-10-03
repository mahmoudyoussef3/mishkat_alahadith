import 'package:mishkat_almasabih/features/hijri_date/data/datasources/hijri_remote_datasource.dart';
import 'package:mishkat_almasabih/features/hijri_date/domain/repositories/hijri_repository.dart';

class HijriRepositoryImpl implements HijriRepository {
  final HijriRemoteDataSource _remoteDataSource;

  HijriRepositoryImpl({required HijriRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<void> initializeRemoteConfig() async {
    await _remoteDataSource.fetchAndActivate();
  }

  @override
  int getHijriDateOffset() {
    return _remoteDataSource.getHijriOffset();
  }
}
