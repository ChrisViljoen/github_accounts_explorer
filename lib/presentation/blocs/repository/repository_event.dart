import 'package:equatable/equatable.dart';

abstract class RepositoryEvent extends Equatable {
  const RepositoryEvent();

  @override
  List<Object> get props => [];
}

class LoadRepositories extends RepositoryEvent {
  final String username;

  const LoadRepositories(this.username);

  @override
  List<Object> get props => [username];
}

class LoadMoreRepositories extends RepositoryEvent {}

class CopyRepositoryUrl extends RepositoryEvent {
  final String url;

  const CopyRepositoryUrl(this.url);

  @override
  List<Object> get props => [url];
}
