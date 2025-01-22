import 'dart:math' as math;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EnvConfig {
  static const String _tokenKey = 'GITHUB_API_TOKEN';
  static final EnvConfig instance = EnvConfig._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  EnvConfig._();

  Future<void> init() async {
    const defaultToken = String.fromEnvironment(
      'GITHUB_TOKEN',
      defaultValue: '',
    );

    if (defaultToken.isNotEmpty) {
      print('Found token in environment, updating stored token...');
      await setGitHubToken(defaultToken);
      print(
          'Token from environment starts with: ${defaultToken.substring(0, math.min(10, defaultToken.length))}...');
    } else {
      final token = await getGitHubToken();
      if (token?.isNotEmpty == true) {
        print(
            'Using existing token that starts with: ${token!.substring(0, math.min(10, token.length))}...');
      } else {
        print('No token available - will use unauthenticated access');
      }
    }
  }

  Future<void> setGitHubToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getGitHubToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearGitHubToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
