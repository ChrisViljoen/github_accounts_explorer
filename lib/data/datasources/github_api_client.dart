import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:github_accounts_explorer/core/config/app_config.dart';
import 'package:github_accounts_explorer/core/constants/config.dart';
import 'package:github_accounts_explorer/data/models/github_user.dart';
import 'package:http/http.dart' as http;

class CacheEntry<T> {
  final T data;
  final DateTime expiryTime;

  CacheEntry(this.data, this.expiryTime);

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

class GitHubApiClient {
  final http.Client _httpClient;
  final Map<String, CacheEntry<List<GitHubUser>>> _searchCache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  GitHubApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  String _formatWaitTime(DateTime resetTime) {
    final waitTime = resetTime.difference(DateTime.now());
    final minutes = waitTime.inMinutes;
    final seconds = waitTime.inSeconds % 60;

    if (minutes > 0) {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    } else if (seconds > 0) {
      return '$seconds second${seconds == 1 ? '' : 's'}';
    } else {
      return '1 minute';
    }
  }

  void _checkRateLimit(http.Response response) {
    final remaining = response.headers['x-ratelimit-remaining'];
    final reset = response.headers['x-ratelimit-reset'];

    if (remaining != null && reset != null) {
      final remainingCount = int.tryParse(remaining) ?? 0;
      if (remainingCount < 5) {
        final resetTime = DateTime.fromMillisecondsSinceEpoch(
          (int.tryParse(reset) ?? 0) * 1000,
        );
        final waitTime = _formatWaitTime(resetTime);
        if (kDebugMode) {
          print(
              'API Rate Limit Warning: $remainingCount requests remaining\nLimit will reset in $waitTime');
        }
      }
    }
  }

  Future<List<GitHubUser>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    if (_searchCache.containsKey(query)) {
      final cacheEntry = _searchCache[query]!;
      if (!cacheEntry.isExpired) {
        return cacheEntry.data;
      } else {
        _searchCache.remove(query);
      }
    }

    final url = Uri.parse('${Config.baseUrl}${Config.searchUsers}?q=$query');

    try {
      final headers = await AppConfig.getGitHubHeaders();
      final response = await _httpClient.get(url, headers: headers);

      _checkRateLimit(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        final users = items.map((item) => GitHubUser.fromJson(item)).toList();

        _searchCache[query] = CacheEntry(
          users,
          DateTime.now().add(_cacheDuration),
        );

        return users;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication Error: Please check your GitHub token');
      } else if (response.statusCode == 403) {
        final resetTime = response.headers['x-ratelimit-reset'];
        if (resetTime != null) {
          final reset = DateTime.fromMillisecondsSinceEpoch(
            int.parse(resetTime) * 1000,
          );
          final waitTime = _formatWaitTime(reset);
          throw Exception(
            'API Rate Limit Reached\nPlease wait $waitTime before searching again',
          );
        }
        throw Exception('API Rate Limit Reached\nPlease try again later');
      } else {
        throw Exception(
            'Failed to search users (Error ${response.statusCode})');
      }
    } catch (e) {
      throw Exception(
          'Search failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<GitHubUser> getAccountDetails(String username) async {
    final url = Uri.parse('${Config.baseUrl}${Config.userDetails}/$username');

    try {
      final headers = await AppConfig.getGitHubHeaders();
      final response = await _httpClient.get(url, headers: headers);

      _checkRateLimit(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GitHubUser.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication Error: Please check your GitHub token');
      } else if (response.statusCode == 403) {
        final resetTime = response.headers['x-ratelimit-reset'];
        if (resetTime != null) {
          final reset = DateTime.fromMillisecondsSinceEpoch(
            int.parse(resetTime) * 1000,
          );
          final waitTime = _formatWaitTime(reset);
          throw Exception(
            'API Rate Limit Reached\nPlease wait $waitTime before trying again',
          );
        }
        throw Exception('API Rate Limit Reached\nPlease try again later');
      } else {
        throw Exception(
            'Failed to get account details (Error ${response.statusCode})');
      }
    } catch (e) {
      throw Exception(
          'Failed to load profile: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}
