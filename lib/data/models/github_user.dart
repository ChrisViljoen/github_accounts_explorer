class GitHubUser {
  final String login;
  final int id;
  final String avatarUrl;
  final String type;
  final String? name;
  final String? bio;
  final int? publicRepos;
  final int? followers;
  final int? following;

  GitHubUser({
    required this.login,
    required this.id,
    required this.avatarUrl,
    required this.type,
    this.name,
    this.bio,
    this.publicRepos,
    this.followers,
    this.following,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      login: json['login'] as String,
      id: json['id'] as int,
      avatarUrl: json['avatar_url'] as String,
      type: json['type'] as String,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      publicRepos: json['public_repos'] as int?,
      followers: json['followers'] as int?,
      following: json['following'] as int?,
    );
  }
} 