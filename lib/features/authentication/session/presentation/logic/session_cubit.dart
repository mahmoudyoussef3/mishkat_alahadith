import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/authentication/session/domain/usecases/is_signed_in_use_case.dart';
import 'package:mishkat_almasabih/features/authentication/session/domain/usecases/sign_out_use_case.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final IsSignedInUseCase _isSignedIn;
  final SignOutUseCase _signOut;

  SessionCubit(this._isSignedIn, this._signOut) : super(const SessionUnknown());

  bool get isSignedIn => state is SessionSignedIn;

  Future<bool> checkSession() async {
    final signedIn = await _isSignedIn();
    emit(signedIn ? const SessionSignedIn() : const SessionSignedOut());
    return signedIn;
  }

  Future<bool> signOut() async {
    final result = await _signOut();
    return result.when(
      success: (_) {
        emit(const SessionSignedOut());
        return true;
      },
      failure: (_) => false,
    );
  }
}
