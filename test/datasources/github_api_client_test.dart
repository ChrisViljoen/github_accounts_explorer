import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_accounts_explorer/core/config/app_config.dart';
import 'package:github_accounts_explorer/data/datasources/github_api_client.dart';
import 'package:github_accounts_explorer/data/models/github_user.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../mocks/mock_github_api_client.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GitHubApiClient', () {
    late GitHubApiClient client;
    late MockClient mockHttpClient;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockHttpClient = MockClient();
      mockSecureStorage = MockFlutterSecureStorage();
      // Set up the mock to return a test token
      when(mockSecureStorage.read(key: 'GITHUB_API_TOKEN'))
          .thenAnswer((_) => Future.value('test_token'));
      // Configure AppConfig to use the mock storage
      AppConfig.setSecureStorage(mockSecureStorage);
      client = GitHubApiClient(httpClient: mockHttpClient);
    });

    group('searchUsers', () {
      test('returns list of users on successful search', () async {
        const query = 'test';
        final responseData = {
          'items': [
            {
              'id': 1,
              'login': 'test_user',
              'avatar_url': 'test_url',
              'type': 'User',
            }
          ]
        };

        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(json.encode(responseData), 200),
        );

        final result = await client.searchUsers(query);

        expect(result, isA<List<GitHubUser>>());
        expect(result.length, 1);
        expect(result.first.login, 'test_user');

        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('throws exception on API error', () async {
        const query = 'test';

        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response('Not Found', 404),
        );

        expect(
          () => client.searchUsers(query),
          throwsException,
        );
      });

      test('throws rate limit exception on 403', () async {
        const query = 'test';
        final now = DateTime.now();
        final resetTime = now.add(const Duration(minutes: 5));
        final headers = {
          'x-ratelimit-reset':
              (resetTime.millisecondsSinceEpoch ~/ 1000).toString(),
        };

        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async =>
              http.Response('Rate limit exceeded', 403, headers: headers),
        );

        expect(
          () => client.searchUsers(query),
          throwsA(predicate((e) =>
              e is Exception &&
              e.toString().contains('API Rate Limit Reached'))),
        );
      });
    });

    group('getAccountDetails', () {
      test('returns user details on success', () async {
        const username = 'test_user';
        final responseData = {
          'id': 1,
          'login': 'test_user',
          'avatar_url': 'test_url',
          'type': 'User',
          'name': 'Test User',
          'bio': 'Test bio',
        };

        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(json.encode(responseData), 200),
        );

        final result = await client.getAccountDetails(username);

        expect(result, isA<GitHubUser>());
        expect(result.login, 'test_user');
        expect(result.name, 'Test User');

        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });
    });
  });
}
