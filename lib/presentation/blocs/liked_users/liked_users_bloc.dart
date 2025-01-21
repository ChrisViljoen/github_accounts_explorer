import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_accounts_explorer/data/datasources/local_storage_service.dart';

import 'liked_users_event.dart';
import 'liked_users_state.dart';

class LikedUsersBloc extends Bloc<LikedUsersEvent, LikedUsersState> {
  final LocalStorageService _storageService;

  LikedUsersBloc({required LocalStorageService storageService})
      : _storageService = storageService,
        super(LikedUsersInitial()) {
    on<LoadLikedUsers>(_onLoadLikedUsers);
    on<ToggleLikeUser>(_onToggleLikeUser);
    on<ClearLikedUsers>(_onClearLikedUsers);
  }

  Future<void> _onLoadLikedUsers(
    LoadLikedUsers event,
    Emitter<LikedUsersState> emit,
  ) async {
    emit(LikedUsersLoading());

    try {
      final users = await _storageService.getLikedUsers();
      final likedUserIds = users.map((user) => user.id).toSet();
      emit(LikedUsersLoaded(users: users, likedUserIds: likedUserIds));
    } catch (e) {
      emit(LikedUsersError(e.toString()));
    }
  }

  Future<void> _onToggleLikeUser(
    ToggleLikeUser event,
    Emitter<LikedUsersState> emit,
  ) async {
    try {
      await _storageService.toggleLikedUser(event.user);
      add(LoadLikedUsers());
    } catch (e) {
      emit(LikedUsersError(e.toString()));
    }
  }

  Future<void> _onClearLikedUsers(
    ClearLikedUsers event,
    Emitter<LikedUsersState> emit,
  ) async {
    try {
      await _storageService.clearLikedUsers();
      emit(const LikedUsersLoaded(users: [], likedUserIds: {}));
    } catch (e) {
      emit(LikedUsersError(e.toString()));
    }
  }
}
