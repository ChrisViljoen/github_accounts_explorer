import 'package:github_accounts_explorer/data/datasources/github_api_client.dart';
import 'package:github_accounts_explorer/data/datasources/local_storage_service.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_details/user_details_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_search/user_search_bloc.dart';
import 'package:http/http.dart' as http;

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._();

  ServiceLocator._();

  final _httpClient = http.Client();
  late final _apiClient = GitHubApiClient(httpClient: _httpClient);
  late final _storageService = LocalStorageService();

  // Datasources
  GitHubApiClient get apiClient => _apiClient;
  LocalStorageService get storageService => _storageService;

  // BLoCs
  UserSearchBloc createUserSearchBloc() =>
      UserSearchBloc(apiClient: _apiClient);
  UserDetailsBloc createUserDetailsBloc() =>
      UserDetailsBloc(apiClient: _apiClient);
  LikedUsersBloc createLikedUsersBloc() =>
      LikedUsersBloc(storageService: storageService);

  void dispose() {
    _httpClient.close();
  }
}
