import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:github_accounts_explorer/core/config/app_config.dart';

class EnvConfig {
  static final EnvConfig instance = EnvConfig._();

  EnvConfig._();

  Future<void> init() async {
    const defaultToken = String.fromEnvironment(
      'GITHUB_TOKEN',
      defaultValue: '',
    );

    if (defaultToken.isNotEmpty) {
      if (kDebugMode) {
        print('Found token in environment, updating stored token...');
      }
      await AppConfig.setToken(defaultToken);
      if (kDebugMode) {
        print(
            'Token from environment starts with: ${defaultToken.substring(0, math.min(10, defaultToken.length))}...');
      }
    } else {
      final headers = await AppConfig.getGitHubHeaders();
      final token = headers['Authorization']?.replaceAll('Bearer ', '');
      if (token?.isNotEmpty == true) {
        if (kDebugMode) {
          print(
              'Using existing token that starts with: ${token!.substring(0, math.min(10, token.length))}...');
        }
      } else {
        if (kDebugMode) {
          print('No token available - will use unauthenticated access');
        }
      }
    }
  }
}
