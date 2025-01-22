import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_accounts_explorer/data/datasources/github_api_client.dart';

import 'account_details_event.dart';
import 'account_details_state.dart';

class AccountDetailsBloc
    extends Bloc<AccountDetailsEvent, AccountDetailsState> {
  final GitHubApiClient _apiClient;

  AccountDetailsBloc({required GitHubApiClient apiClient})
      : _apiClient = apiClient,
        super(AccountDetailsInitial()) {
    on<LoadAccountDetails>(_onLoadAccountDetails);
  }

  Future<void> _onLoadAccountDetails(
    LoadAccountDetails event,
    Emitter<AccountDetailsState> emit,
  ) async {
    emit(AccountDetailsLoading());

    try {
      final user = await _apiClient.getAccountDetails(event.username);
      emit(AccountDetailsLoaded(user));
    } catch (e) {
      emit(AccountDetailsError(e.toString()));
    }
  }
}
