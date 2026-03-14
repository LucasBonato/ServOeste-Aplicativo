abstract class SecureStorageService {
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> deleteTokens();
  Future<void> updateAccessToken(String accessToken);
  bool hasToken(String? token);
}
