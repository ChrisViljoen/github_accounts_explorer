class GitHubRepo {
  final String name;
  final DateTime createdAt;
  final int stargazersCount;
  final int forksCount;
  final int watchersCount;
  final String? description;
  final String? language;
  final String htmlUrl;

  GitHubRepo({
    required this.name,
    required this.createdAt,
    required this.stargazersCount,
    required this.forksCount,
    required this.watchersCount,
    this.description,
    this.language,
    required this.htmlUrl,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      stargazersCount: json['stargazers_count'] as int,
      forksCount: json['forks_count'] as int,
      watchersCount: json['watchers_count'] as int,
      description: json['description'] as String?,
      language: json['language'] as String?,
      htmlUrl: json['html_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'stargazers_count': stargazersCount,
      'forks_count': forksCount,
      'watchers_count': watchersCount,
      'description': description,
      'language': language,
      'html_url': htmlUrl,
    };
  }
}
