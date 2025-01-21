import 'package:equatable/equatable.dart';
import 'package:github_accounts_explorer/data/models/github_user.dart';

abstract class LikedUsersState extends Equatable {
  const LikedUsersState();

  @override
  List<Object?> get props => [];
}

class LikedUsersInitial extends LikedUsersState {}

class LikedUsersLoading extends LikedUsersState {}

class LikedUsersLoaded extends LikedUsersState {
  final List<GitHubUser> users;
  final Set<int> likedUserIds;

  const LikedUsersLoaded({
    required this.users,
    required this.likedUserIds,
  });

  bool isUserLiked(GitHubUser user) => likedUserIds.contains(user.id);

  @override
  List<Object?> get props => [users, likedUserIds];
}

class LikedUsersError extends LikedUsersState {
  final String message;

  const LikedUsersError(this.message);

  @override
  List<Object?> get props => [message];
}
