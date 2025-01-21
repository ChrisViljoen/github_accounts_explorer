import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/github_api_client.dart';
import 'user_search_event.dart';
import 'user_search_state.dart';

class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  final GitHubApiClient _apiClient;

  UserSearchBloc({GitHubApiClient? apiClient})
      : _apiClient = apiClient ?? GitHubApiClient(),
        super(UserSearchInitial()) {
    on<SearchUsers>(_onSearchUsers);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<UserSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(UserSearchInitial());
      return;
    }

    emit(UserSearchLoading());

    try {
      final users = await _apiClient.searchUsers(event.query);
      emit(UserSearchSuccess(users));
    } catch (e) {
      emit(UserSearchError(e.toString()));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<UserSearchState> emit) {
    emit(UserSearchInitial());
  }
} 