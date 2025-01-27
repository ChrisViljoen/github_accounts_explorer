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
  final bool hasMore;
  final bool isLoadingMore;

  const RepositoryLoaded(
    this.repositories, {
    this.copiedUrl,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  RepositoryLoaded copyWith({
    List<GitHubRepo>? repositories,
    String? copiedUrl,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return RepositoryLoaded(
      repositories ?? this.repositories,
      copiedUrl: copiedUrl ?? this.copiedUrl,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [repositories, copiedUrl, hasMore, isLoadingMore];
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
