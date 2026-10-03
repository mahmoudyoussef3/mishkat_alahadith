import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/exceptions.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final storage = TokenStorage();

  group('TokenStorage', () {
    test('requireToken returns the stored token', () async {
      SharedPreferences.setMockInitialValues({'token': 'abc'});

      expect(await storage.requireToken(), 'abc');
    });

    test('requireToken throws UnauthorizedException when no token is stored', () async {
      SharedPreferences.setMockInitialValues({});

      expect(storage.requireToken(), throwsA(isA<UnauthorizedException>()));
    });

    test('treats an empty stored token as signed out', () async {
      SharedPreferences.setMockInitialValues({'token': ''});

      expect(await storage.getToken(), isNull);
    });

    test('saveToken then clearToken round-trips through preferences', () async {
      SharedPreferences.setMockInitialValues({});

      await storage.saveToken('xyz');
      expect(await storage.getToken(), 'xyz');

      await storage.clearToken();
      expect(await storage.getToken(), isNull);
    });
  });
}
