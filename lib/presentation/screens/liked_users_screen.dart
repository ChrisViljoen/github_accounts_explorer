import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_accounts_explorer/core/di/service_locator.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_state.dart';
import 'package:github_accounts_explorer/presentation/screens/user_details_screen.dart';

class LikedUsersScreen extends StatelessWidget {
  const LikedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.instance.createLikedUsersBloc()..add(LoadLikedUsers()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Liked Users'),
          centerTitle: true,
        ),
        body: BlocBuilder<LikedUsersBloc, LikedUsersState>(
          builder: (context, state) {
            if (state is LikedUsersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LikedUsersError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            } else if (state is LikedUsersLoaded) {
              if (state.users.isEmpty) {
                return const Center(
                  child: Text('No liked users yet'),
                );
              }
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.avatarUrl),
                    ),
                    title: Text(user.name ?? user.login),
                    subtitle: Text(user.type),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        context.read<LikedUsersBloc>().add(ToggleLikeUser(user));
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsScreen(user: user),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
} 