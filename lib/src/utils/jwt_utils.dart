import 'dart:convert';

Map<String, dynamic>? decodeJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));

    return jsonDecode(decoded) as Map<String, dynamic>;
  } catch (error) {
    return null;
  }
}

String? getUserRoleFromToken(String token) {
  final decodedToken = decodeJwt(token);
  return decodedToken?['role'] as String?;
}

String? getUserNameFromToken(String token) {
  final decodedToken = decodeJwt(token);
  return decodedToken?['sub'] as String?;
}
