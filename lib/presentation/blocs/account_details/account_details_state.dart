import 'package:equatable/equatable.dart';
import 'package:github_accounts_explorer/data/models/github_user.dart';

abstract class AccountDetailsState extends Equatable {
  const AccountDetailsState();

  @override
  List<Object?> get props => [];
}

class AccountDetailsInitial extends AccountDetailsState {}

class AccountDetailsLoading extends AccountDetailsState {}

class AccountDetailsLoaded extends AccountDetailsState {
  final GitHubUser user;

  const AccountDetailsLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class AccountDetailsError extends AccountDetailsState {
  final String message;

  const AccountDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
