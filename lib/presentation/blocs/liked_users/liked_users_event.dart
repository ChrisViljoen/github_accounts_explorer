import 'package:equatable/equatable.dart';
import '../../../data/models/github_user.dart';

abstract class LikedUsersEvent extends Equatable {
  const LikedUsersEvent();

  @override
  List<Object> get props => [];
}

class LoadLikedUsers extends LikedUsersEvent {}

class ToggleLikeUser extends LikedUsersEvent {
  final GitHubUser user;

  const ToggleLikeUser(this.user);

  @override
  List<Object> get props => [user];
}

class ClearLikedUsers extends LikedUsersEvent {} 