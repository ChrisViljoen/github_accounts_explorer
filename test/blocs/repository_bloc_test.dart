import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_accounts_explorer/data/datasources/github_api_client.dart';
import 'package:github_accounts_explorer/data/models/github_repo.dart';
import 'package:github_accounts_explorer/presentation/blocs/repository/repository_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/repository/repository_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/repository/repository_state.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_github_api_client.mocks.dart';

void main() {
  late MockGitHubApiClient mockApiClient;
  late RepositoryBloc repositoryBloc;

  setUp(() {
    mockApiClient = MockGitHubApiClient();
    repositoryBloc = RepositoryBloc(apiClient: mockApiClient);
  });

  tearDown(() {
    repositoryBloc.close();
  });

  final testRepos = [
    GitHubRepo(
      name: 'repo1',
      description: 'description1',
      htmlUrl: 'https://github.com/user/repo1',
      stargazersCount: 10,
      forksCount: 5,
      watchersCount: 8,
      createdAt: DateTime(2024, 1, 1),
      language: 'Dart',
    ),
  ];

  group('RepositoryBloc', () {
    blocTest<RepositoryBloc, RepositoryState>(
      'initial state is RepositoryInitial',
      build: () => repositoryBloc,
      verify: (bloc) {
        expect(bloc.state, isA<RepositoryInitial>());
      },
    );

    blocTest<RepositoryBloc, RepositoryState>(
      'emits [RepositoryLoading, RepositoryLoaded] when LoadRepositories succeeds',
      build: () {
        when(mockApiClient.getAccountRepos(
          'testuser',
          page: 1,
          perPage: 30,
        )).thenAnswer((_) async => RepositoryResponse(testRepos, false));
        return repositoryBloc;
      },
      act: (bloc) => bloc.add(const LoadRepositories('testuser')),
      expect: () => [
        RepositoryLoading(),
        RepositoryLoaded(testRepos, hasMore: false),
      ],
    );

    blocTest<RepositoryBloc, RepositoryState>(
      'emits [RepositoryLoading, RepositoryError] when LoadRepositories fails',
      build: () {
        when(mockApiClient.getAccountRepos(
          'testuser',
          page: 1,
          perPage: 30,
        )).thenThrow(Exception('API Error'));
        return repositoryBloc;
      },
      act: (bloc) => bloc.add(const LoadRepositories('testuser')),
      expect: () => [
        RepositoryLoading(),
        const RepositoryError('Exception: API Error'),
      ],
    );

    blocTest<RepositoryBloc, RepositoryState>(
      'loads second page when hasMore is true',
      build: () {
        when(mockApiClient.getAccountRepos(
          'testuser',
          page: 1,
          perPage: 30,
        )).thenAnswer((_) async => RepositoryResponse(testRepos, true));

        final secondPageRepo = GitHubRepo(
          name: 'repo2',
          description: 'description2',
          htmlUrl: 'https://github.com/user/repo2',
          stargazersCount: 20,
          forksCount: 10,
          watchersCount: 15,
          createdAt: DateTime(2024, 1, 2),
          language: 'Flutter',
        );
        when(mockApiClient.getAccountRepos(
          'testuser',
          page: 2,
          perPage: 30,
        )).thenAnswer((_) async => RepositoryResponse([secondPageRepo], false));

        return repositoryBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadRepositories('testuser'));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(LoadMoreRepositories());
      },
      expect: () => [
        RepositoryLoading(),
        RepositoryLoaded(testRepos, hasMore: true),
        RepositoryLoaded(testRepos, hasMore: true, isLoadingMore: true),
        RepositoryLoaded([
          ...testRepos,
          GitHubRepo(
            name: 'repo2',
            description: 'description2',
            htmlUrl: 'https://github.com/user/repo2',
            stargazersCount: 20,
            forksCount: 10,
            watchersCount: 15,
            createdAt: DateTime(2024, 1, 2),
            language: 'Flutter',
          )
        ], hasMore: false),
      ],
      verify: (_) {
        verify(mockApiClient.getAccountRepos('testuser', page: 1, perPage: 30))
            .called(1);
        verify(mockApiClient.getAccountRepos('testuser', page: 2, perPage: 30))
            .called(1);
      },
    );
  });
}
