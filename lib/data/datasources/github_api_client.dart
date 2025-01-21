import 'dart:convert';

import 'package:github_accounts_explorer/core/constants/config.dart';
import 'package:github_accounts_explorer/data/models/github_user.dart';
import 'package:http/http.dart' as http;

class GitHubApiClient {
  final http.Client _httpClient;

  GitHubApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<List<GitHubUser>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse('${Config.baseUrl}${Config.searchUsers}?q=$query');

    try {
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        return items.map((item) => GitHubUser.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  Future<GitHubUser> getUserDetails(String username) async {
    final url = Uri.parse('${Config.baseUrl}${Config.userDetails}/$username');

    try {
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GitHubUser.fromJson(data);
      } else {
        throw Exception('Failed to get user details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get user details: $e');
    }
  }
}
