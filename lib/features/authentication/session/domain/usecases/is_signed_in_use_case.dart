import '../repos/session_repo.dart';

class IsSignedInUseCase {
  final SessionRepo _repo;

  IsSignedInUseCase(this._repo);

  Future<bool> call() => _repo.isSignedIn();
}
