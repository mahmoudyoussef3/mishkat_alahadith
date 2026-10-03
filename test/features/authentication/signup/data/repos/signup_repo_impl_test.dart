import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/authentication/signup/data/models/sign_up_request_body.dart';
import 'package:mishkat_almasabih/features/authentication/signup/data/models/sign_up_response_body.dart';
import 'package:mishkat_almasabih/features/authentication/signup/data/repos/signup_repo_impl.dart';

class _FakeApiService extends Fake implements ApiService {
  SignupRequestBody? received;
  Object? error;

  @override
  Future<SignUpResponseBody> signup(SignupRequestBody body) async {
    received = body;
    if (error != null) throw error!;
    return SignUpResponseBody(status: true);
  }
}

void main() {
  late _FakeApiService api;
  late SignupRepoImpl repo;

  setUp(() {
    api = _FakeApiService();
    repo = SignupRepoImpl(api);
  });

  test('sends the form fields and succeeds', () async {
    final result = await repo.signup(
      username: 'user',
      email: 'a@b.c',
      password: 'secret',
    );

    expect(result, isA<ApiSuccess<void>>());
    expect(api.received?.username, 'user');
    expect(api.received?.email, 'a@b.c');
  });

  test('maps a timeout to NetworkFailure', () async {
    api.error = DioException(
      requestOptions: RequestOptions(path: '/signup'),
      type: DioExceptionType.receiveTimeout,
    );

    final result = await repo.signup(username: 'u', email: 'e', password: 'p');

    expect((result as ApiFailure).failure, isA<NetworkFailure>());
  });
}
