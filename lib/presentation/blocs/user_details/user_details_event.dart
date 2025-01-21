import 'package:equatable/equatable.dart';

abstract class UserDetailsEvent extends Equatable {
  const UserDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadUserDetails extends UserDetailsEvent {
  final String username;

  const LoadUserDetails(this.username);

  @override
  List<Object> get props => [username];
}
