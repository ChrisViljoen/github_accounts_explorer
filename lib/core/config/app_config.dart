import 'package:github_accounts_explorer/core/config/env_config.dart';

class AppConfig {
  static String? _cachedToken;

  static Future<Map<String, String>> getGitHubHeaders() async {
    final headers = {
      'Accept': 'application/vnd.github.v3+json',
      'X-GitHub-Api-Version': '2022-11-28',
    };

    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<String?> _getToken() async {
    if (_cachedToken != null) return _cachedToken;

    _cachedToken = await EnvConfig.instance.getGitHubToken();
    return _cachedToken;
  }

  static void clearCache() {
    _cachedToken = null;
  }
}
