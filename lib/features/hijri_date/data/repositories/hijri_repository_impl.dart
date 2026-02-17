import 'package:mishkat_almasabih/features/hijri_date/data/datasources/hijri_remote_datasource.dart';
import 'package:mishkat_almasabih/features/hijri_date/domain/repositories/hijri_repository.dart';

/// Implementation of the Hijri repository that delegates to the remote data source.
///
/// This layer exists as part of Clean Architecture to:
/// - Separate domain logic from data source implementation details
/// - Allow easy switching of data sources (e.g., local cache, different remote config)
/// - Provide a consistent interface for the domain layer
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
