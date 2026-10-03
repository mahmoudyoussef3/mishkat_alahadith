import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/authentication/session/domain/repos/session_repo.dart';
import 'package:mishkat_almasabih/features/authentication/session/domain/usecases/is_signed_in_use_case.dart';
import 'package:mishkat_almasabih/features/authentication/session/domain/usecases/sign_out_use_case.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';

class _FakeSessionRepo implements SessionRepo {
  bool signedIn;
  bool failSignOut = false;
  _FakeSessionRepo(this.signedIn);

  @override
  Future<bool> isSignedIn() async => signedIn;

  @override
  Future<ApiResult<void>> signOut() async {
    if (failSignOut) return const ApiResult.failure(CacheFailure());
    signedIn = false;
    return const ApiResult.success(null);
  }
}

SessionCubit _cubit(_FakeSessionRepo repo) =>
    SessionCubit(IsSignedInUseCase(repo), SignOutUseCase(repo));

void main() {
  test('starts unknown until the session is checked', () {
    final cubit = _cubit(_FakeSessionRepo(true));

    expect(cubit.state, isA<SessionUnknown>());
    expect(cubit.isSignedIn, isFalse);
  });

  test('checkSession reflects the stored session', () async {
    final repo = _FakeSessionRepo(true);
    final cubit = _cubit(repo);

    expect(await cubit.checkSession(), isTrue);
    expect(cubit.isSignedIn, isTrue);

    repo.signedIn = false;
    expect(await cubit.checkSession(), isFalse);
    expect(cubit.state, isA<SessionSignedOut>());
  });

  test('signOut ends the session for every listener', () async {
    final repo = _FakeSessionRepo(true);
    final cubit = _cubit(repo);
    await cubit.checkSession();

    expect(await cubit.signOut(), isTrue);

    expect(cubit.state, isA<SessionSignedOut>());
    expect(repo.signedIn, isFalse);
  });

  test('a failed sign-out keeps the user signed in', () async {
    final repo = _FakeSessionRepo(true)..failSignOut = true;
    final cubit = _cubit(repo);
    await cubit.checkSession();

    expect(await cubit.signOut(), isFalse);

    expect(cubit.isSignedIn, isTrue);
  });
}
