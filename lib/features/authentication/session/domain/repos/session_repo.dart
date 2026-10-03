import 'package:mishkat_almasabih/core/networking/api_result.dart';

abstract class SessionRepo {
  Future<bool> isSignedIn();

  Future<ApiResult<void>> signOut();
}
