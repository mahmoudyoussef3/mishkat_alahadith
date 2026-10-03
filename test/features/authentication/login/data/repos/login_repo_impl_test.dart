import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';
import 'package:mishkat_almasabih/features/authentication/login/data/datasources/google_auth_datasource.dart';
import 'package:mishkat_almasabih/features/authentication/login/data/models/login_request_body.dart';
import 'package:mishkat_almasabih/features/authentication/login/data/models/login_response_body.dart';
import 'package:mishkat_almasabih/features/authentication/login/data/repos/login_repo_impl.dart';
import 'package:mishkat_almasabih/features/authentication/login/domain/entities/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  LoginResponseBody response = LoginResponseBody(token: 'server-token');
  Object? error;
  Map<String, dynamic>? googleBody;

  @override
  Future<LoginResponseBody> login(LoginRequestBody body) async {
    if (error != null) throw error!;
    return response;
  }

  @override
  Future<LoginResponseBody> googleLogin(Map<String, dynamic> data) async {
    googleBody = data;
    return response;
  }
}

class _FakeGoogleAuth implements GoogleAuthDataSource {
  String? idToken = 'google-id-token';

  @override
  Future<String?> signInAndGetIdToken() async => idToken;
}

void main() {
  late _FakeApiService api;
  late _FakeGoogleAuth google;
  late TokenStorage storage;
  late LoginRepoImpl repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = _FakeApiService();
    google = _FakeGoogleAuth();
    storage = TokenStorage();
    repo = LoginRepoImpl(api, google, storage);
  });

  group('login', () {
    test('persists the returned token and returns the session', () async {
      final result = await repo.login(email: 'a@b.c', password: 'p');

      expect((result as ApiSuccess<AuthSession>).data.token, 'server-token');
      expect(await storage.getToken(), 'server-token');
    });

    test(
      'fails without persisting anything when the server omits the token',
      () async {
        api.response = LoginResponseBody();

        final result = await repo.login(email: 'a@b.c', password: 'p');

        expect((result as ApiFailure).failure, isA<UnexpectedFailure>());
        expect(await storage.getToken(), isNull);
      },
    );

    test(
      'maps a 401 to UnauthorizedFailure keeping the server message',
      () async {
        final options = RequestOptions(path: '/login');
        api.error = DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {'messageAr': 'كلمة المرور غير صحيحة'},
          ),
        );

        final result = await repo.login(email: 'a@b.c', password: 'p');

        final failure = (result as ApiFailure).failure;
        expect(failure, isA<UnauthorizedFailure>());
        expect(failure.message, 'كلمة المرور غير صحيحة');
      },
    );

    test(
      'explains a 401 without an Arabic message as wrong credentials',
      () async {
        final options = RequestOptions(path: '/login');
        api.error = DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {'message': 'Invalid credentials'},
          ),
        );

        final result = await repo.login(email: 'a@b.c', password: 'wrong');

        final failure = (result as ApiFailure).failure;
        expect(failure, isA<UnauthorizedFailure>());
        expect(failure.message, isNot(FailureMessages.unauthorized));
        expect(failure.message, contains('كلمة المرور'));
      },
    );
  });

  group('loginWithGoogle', () {
    test(
      'exchanges the Google ID token and persists the session token',
      () async {
        final result = await repo.loginWithGoogle();

        expect(api.googleBody, {'token': 'google-id-token'});
        expect(result, isA<ApiSuccess<AuthSession>>());
        expect(await storage.getToken(), 'server-token');
      },
    );

    test(
      'returns a failure without calling the API when the user cancels',
      () async {
        google.idToken = null;

        final result = await repo.loginWithGoogle();

        expect(api.googleBody, isNull);
        expect((result as ApiFailure).failure, isA<UnexpectedFailure>());
      },
    );
  });
}
