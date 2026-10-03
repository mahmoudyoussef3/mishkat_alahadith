import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleAuthDataSource {
  Future<String?> signInAndGetIdToken();
}

class GoogleAuthDataSourceImpl implements GoogleAuthDataSource {
  @override
  Future<String?> signInAndGetIdToken() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile', 'openid'],
      serverClientId:
          "479373165372-d9vr3f1c1b2aodv4kjngi5ra1diug1v6.apps.googleusercontent.com",
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    return googleAuth.idToken ?? "";
  }
}
