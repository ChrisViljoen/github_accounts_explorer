import 'package:github_accounts_explorer/data/datasources/github_api_client.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_details/user_details_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_search/user_search_bloc.dart';
import 'package:http/http.dart' as http;

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._();

  ServiceLocator._();

  final _httpClient = http.Client();
  late final _apiClient = GitHubApiClient(httpClient: _httpClient);

  // Datasources
  GitHubApiClient get apiClient => _apiClient;

  // BLoCs
  UserSearchBloc createUserSearchBloc() =>
      UserSearchBloc(apiClient: _apiClient);
  UserDetailsBloc createUserDetailsBloc() =>
      UserDetailsBloc(apiClient: _apiClient);

  void dispose() {
    _httpClient.close();
  }
}
