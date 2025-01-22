import 'package:equatable/equatable.dart';
import 'package:github_accounts_explorer/data/models/github_repo.dart';

abstract class RepositoryState extends Equatable {
  const RepositoryState();

  @override
  List<Object?> get props => [];
}

class RepositoryInitial extends RepositoryState {}

class RepositoryLoading extends RepositoryState {}

class RepositoryLoaded extends RepositoryState {
  final List<GitHubRepo> repositories;
  final String? copiedUrl;

  const RepositoryLoaded(this.repositories, {this.copiedUrl});

  RepositoryLoaded copyWith({
    List<GitHubRepo>? repositories,
    String? copiedUrl,
  }) {
    return RepositoryLoaded(
      repositories ?? this.repositories,
      copiedUrl: copiedUrl,
    );
  }

  @override
  List<Object?> get props => [repositories, copiedUrl];
}

class RepositoryError extends RepositoryState {
  final String message;

  const RepositoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class UrlCopied extends RepositoryState {
  final String url;

  const UrlCopied(this.url);

  @override
  List<Object?> get props => [url];
}
