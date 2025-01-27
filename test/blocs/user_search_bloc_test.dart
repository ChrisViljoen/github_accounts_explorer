import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_accounts_explorer/data/models/github_user.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_search/user_search_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_search/user_search_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_search/user_search_state.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_github_api_client.mocks.dart';

void main() {
  group('UserSearchBloc', () {
    late UserSearchBloc bloc;
    late MockGitHubApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockGitHubApiClient();
      bloc = UserSearchBloc(apiClient: mockApiClient);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is UserSearchInitial', () {
      expect(bloc.state, isA<UserSearchInitial>());
    });

    blocTest<UserSearchBloc, UserSearchState>(
      'emits [] when query is empty',
      build: () => bloc,
      act: (bloc) => bloc.add(const SearchUsers('')),
      expect: () => [isA<UserSearchInitial>()],
    );

    blocTest<UserSearchBloc, UserSearchState>(
      'emits [Loading, Success] when search is successful',
      setUp: () {
        when(mockApiClient.searchUsers('test')).thenAnswer(
          (_) async => [
            GitHubUser(
              id: 1,
              login: 'test',
              avatarUrl: 'test_url',
              type: 'User',
            ),
          ],
        );
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const SearchUsers('test')),
      expect: () => [
        isA<UserSearchLoading>(),
        isA<UserSearchSuccess>(),
      ],
      verify: (_) {
        verify(mockApiClient.searchUsers('test')).called(1);
      },
    );

    blocTest<UserSearchBloc, UserSearchState>(
      'emits [Loading, Error] when search fails',
      setUp: () {
        when(mockApiClient.searchUsers('test'))
            .thenThrow(Exception('Search failed'));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const SearchUsers('test')),
      expect: () => [
        isA<UserSearchLoading>(),
        isA<UserSearchError>(),
      ],
      verify: (_) {
        verify(mockApiClient.searchUsers('test')).called(1);
      },
    );

    blocTest<UserSearchBloc, UserSearchState>(
      'emits [Initial] when search is cleared',
      build: () => bloc,
      act: (bloc) => bloc.add(ClearSearch()),
      expect: () => [isA<UserSearchInitial>()],
    );
  });
}
