import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:serv_oeste/core/services/secure_storage_service.dart';

class FlutterSecureStorageService implements SecureStorageService {
  final FlutterSecureStorage _storage;

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  FlutterSecureStorageService(this._storage);

  @override
  Future<void> deleteTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
    ]);
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  @override
  bool hasToken(String? token) {
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      if (refreshToken.isNotEmpty)
        _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  @override
  Future<void> updateAccessToken(String accessToken) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
  }
}
