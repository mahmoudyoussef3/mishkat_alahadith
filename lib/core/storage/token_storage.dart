import 'package:shared_preferences/shared_preferences.dart';

import '../errors/exceptions.dart';

class TokenStorage {
  static const String _tokenKey = 'token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return (token == null || token.isEmpty) ? null : token;
  }

  Future<String> requireToken() async {
    final token = await getToken();
    if (token == null) throw const UnauthorizedException();
    return token;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<bool> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_tokenKey);
  }
}
