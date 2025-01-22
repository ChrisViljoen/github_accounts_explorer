class Config {
  static const String baseUrl = 'https://api.github.com';

  static const String searchUsers = '/search/users';
  static const String userDetails = '/users';
  static const String userRepos = '/repos';

  static const int defaultPerPage = 30;
  static const Duration timeoutDuration = Duration(seconds: 30);

  static const Duration cacheDuration = Duration(minutes: 5);
}
