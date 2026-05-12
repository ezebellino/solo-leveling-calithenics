import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return const AuthLocalDataSource();
});

class AuthLocalDataSource {
  const AuthLocalDataSource();

  static const _accessTokenKey = 'solo_leveling_auth_access_token';

  Future<String?> loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_accessTokenKey);
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
  }

  Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }
}
