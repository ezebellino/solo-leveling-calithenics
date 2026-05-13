import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return const AuthLocalDataSource();
});

class AuthLocalDataSource {
  const AuthLocalDataSource();

  static const _accessTokenKey = 'solo_leveling_auth_access_token';
  static const _biometricUnlockEnabledKey =
      'solo_leveling_auth_biometric_unlock_enabled';

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

  Future<bool> hasStoredAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_accessTokenKey);
    return value != null && value.isNotEmpty;
  }

  Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }

  Future<bool> loadBiometricUnlockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricUnlockEnabledKey) ?? false;
  }

  Future<void> saveBiometricUnlockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricUnlockEnabledKey, enabled);
  }
}
