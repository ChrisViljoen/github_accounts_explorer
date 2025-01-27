import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_accounts_explorer/data/datasources/github_api_client.dart';

import 'repository_event.dart';
import 'repository_state.dart';

class RepositoryBloc extends Bloc<RepositoryEvent, RepositoryState> {
  final GitHubApiClient _apiClient;
  int _currentPage = 1;
  static const _perPage = 30;
  bool _hasMoreData = true;
  String? _currentUsername;

  RepositoryBloc({required GitHubApiClient apiClient})
      : _apiClient = apiClient,
        super(RepositoryInitial()) {
    on<LoadRepositories>(_onLoadRepositories);
    on<LoadMoreRepositories>(_onLoadMoreRepositories);
    on<CopyRepositoryUrl>(_onCopyRepositoryUrl);
  }

  Future<void> _onLoadRepositories(
    LoadRepositories event,
    Emitter<RepositoryState> emit,
  ) async {
    emit(RepositoryLoading());

    try {
      _currentPage = 1;
      _currentUsername = event.username;

      final response = await _apiClient.getAccountRepos(
        event.username,
        page: _currentPage,
        perPage: _perPage,
      );

      _hasMoreData = response.hasMore;
      emit(RepositoryLoaded(response.repositories, hasMore: _hasMoreData));
    } catch (e) {
      emit(RepositoryError(e.toString()));
    }
  }

  Future<void> _onLoadMoreRepositories(
    LoadMoreRepositories event,
    Emitter<RepositoryState> emit,
  ) async {
    if (state is! RepositoryLoaded) {
      return;
    }

    if (!_hasMoreData || _currentUsername == null) {
      return;
    }

    try {
      final currentState = state as RepositoryLoaded;
      emit(RepositoryLoaded(
        currentState.repositories,
        hasMore: _hasMoreData,
        isLoadingMore: true,
      ));

      _currentPage++;
      final response = await _apiClient.getAccountRepos(
        _currentUsername!,
        page: _currentPage,
        perPage: _perPage,
      );

      _hasMoreData = response.hasMore;

      emit(RepositoryLoaded(
        [...currentState.repositories, ...response.repositories],
        hasMore: _hasMoreData,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(RepositoryError(e.toString()));
    }
  }

  Future<void> _onCopyRepositoryUrl(
    CopyRepositoryUrl event,
    Emitter<RepositoryState> emit,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: event.url));

      if (state is RepositoryLoaded) {
        final currentState = state as RepositoryLoaded;
        emit(currentState.copyWith(copiedUrl: event.url));

        await Future.delayed(const Duration(seconds: 2));
        if (state is RepositoryLoaded) {
          emit((state as RepositoryLoaded).copyWith(copiedUrl: null));
        }
      }
    } catch (e) {
      emit(RepositoryError('Failed to copy URL: ${e.toString()}'));
    }
  }
}
