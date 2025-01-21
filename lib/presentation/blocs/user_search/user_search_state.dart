import 'package:equatable/equatable.dart';
import '../../../data/models/github_user.dart';

abstract class UserSearchState extends Equatable {
  const UserSearchState();

  @override
  List<Object?> get props => [];
}

class UserSearchInitial extends UserSearchState {}

class UserSearchLoading extends UserSearchState {}

class UserSearchSuccess extends UserSearchState {
  final List<GitHubUser> users;

  const UserSearchSuccess(this.users);

  @override
  List<Object?> get props => [users];
}

class UserSearchError extends UserSearchState {
  final String message;

  const UserSearchError(this.message);

  @override
  List<Object?> get props => [message];
} 