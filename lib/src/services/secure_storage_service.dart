import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  static Future<void> saveTokens(String accessToken,
      [String refreshToken = '']) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    if (refreshToken.isNotEmpty) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  static Future<void> deleteTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
