import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppConfig {
  static const String _tokenKey = 'GITHUB_API_TOKEN';
  static FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static String? _cachedToken;

  static void setSecureStorage(FlutterSecureStorage storage) {
    _secureStorage = storage;
  }

  static Future<Map<String, String>> getGitHubHeaders() async {
    final token = await _getToken();
    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<String?> _getToken() async {
    if (_cachedToken != null) return _cachedToken;

    _cachedToken = await _secureStorage.read(key: _tokenKey);
    return _cachedToken;
  }

  static Future<void> setToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    _cachedToken = token;
  }

  static void clearCache() {
    _cachedToken = null;
  }
}
