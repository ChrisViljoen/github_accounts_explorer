import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_accounts_explorer/data/datasources/github_api_client.dart';

import 'user_details_event.dart';
import 'user_details_state.dart';

class UserDetailsBloc extends Bloc<UserDetailsEvent, UserDetailsState> {
  final GitHubApiClient _apiClient;

  UserDetailsBloc({required GitHubApiClient apiClient})
      : _apiClient = apiClient,
        super(UserDetailsInitial()) {
    on<LoadUserDetails>(_onLoadUserDetails);
  }

  Future<void> _onLoadUserDetails(
    LoadUserDetails event,
    Emitter<UserDetailsState> emit,
  ) async {
    emit(UserDetailsLoading());

    try {
      final user = await _apiClient.getUserDetails(event.username);
      emit(UserDetailsLoaded(user));
    } catch (e) {
      emit(UserDetailsError(e.toString()));
    }
  }
}
