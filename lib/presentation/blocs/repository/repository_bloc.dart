import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_accounts_explorer/data/datasources/github_api_client.dart';

import 'repository_event.dart';
import 'repository_state.dart';

class RepositoryBloc extends Bloc<RepositoryEvent, RepositoryState> {
  final GitHubApiClient _apiClient;

  RepositoryBloc({required GitHubApiClient apiClient})
      : _apiClient = apiClient,
        super(RepositoryInitial()) {
    on<LoadRepositories>(_onLoadRepositories);
    on<CopyRepositoryUrl>(_onCopyRepositoryUrl);
  }

  Future<void> _onLoadRepositories(
    LoadRepositories event,
    Emitter<RepositoryState> emit,
  ) async {
    emit(RepositoryLoading());

    try {
      final repositories = await _apiClient.getAccountRepos(event.username);
      emit(RepositoryLoaded(repositories));
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
