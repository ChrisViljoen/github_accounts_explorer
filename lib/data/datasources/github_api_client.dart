import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/config.dart';
import '../models/github_user.dart';

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
} 