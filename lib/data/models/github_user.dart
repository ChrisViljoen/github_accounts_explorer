class GitHubUser {
  final String login;
  final int id;
  final String avatarUrl;
  final String type;
  final String? name;
  final String? bio;
  final int? publicRepos;
  final int? publicGists;
  final int? followers;
  final int? following;
  final DateTime? createdAt;

  GitHubUser({
    required this.login,
    required this.id,
    required this.avatarUrl,
    required this.type,
    this.name,
    this.bio,
    this.publicRepos,
    this.publicGists,
    this.followers,
    this.following,
    this.createdAt,
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
      publicGists: json['public_gists'] as int?,
      followers: json['followers'] as int?,
      following: json['following'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'id': id,
      'avatar_url': avatarUrl,
      'type': type,
      'name': name,
      'bio': bio,
      'public_repos': publicRepos,
      'public_gists': publicGists,
      'followers': followers,
      'following': following,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubUser &&
          runtimeType == other.runtimeType &&
          login == other.login &&
          id == other.id;

  @override
  int get hashCode => login.hashCode ^ id.hashCode;
}
