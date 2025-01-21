import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_accounts_explorer/core/di/service_locator.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_details/user_details_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_search/user_search_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_search/user_search_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_search/user_search_state.dart';
import 'package:github_accounts_explorer/presentation/screens/liked_users_screen.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_state.dart';

import 'user_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ServiceLocator.instance.createUserSearchBloc(),
        ),
        BlocProvider(
          create: (context) => ServiceLocator.instance.createLikedUsersBloc()..add(LoadLikedUsers()),
        ),
      ],
      child: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Accounts Explorer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LikedUsersScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search GitHub users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<UserSearchBloc>().add(ClearSearch());
                  },
                ),
              ),
              onSubmitted: (query) {
                context.read<UserSearchBloc>().add(SearchUsers(query));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<UserSearchBloc, UserSearchState>(
              builder: (context, state) {
                if (state is UserSearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is UserSearchError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      state.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                } else if (state is UserSearchSuccess) {
                  return ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.avatarUrl),
                        ),
                        title: Text(user.login),
                        subtitle: Text(user.type),
                        trailing: BlocBuilder<LikedUsersBloc, LikedUsersState>(
                          builder: (context, likedState) {
                            final bool isLiked = likedState is LikedUsersLoaded && 
                                               likedState.likedUserIds.contains(user.id);
                            return IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : null,
                              ),
                              onPressed: () {
                                context.read<LikedUsersBloc>().add(ToggleLikeUser(user));
                              },
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => ServiceLocator.instance
                                    .createUserDetailsBloc()
                                  ..add(LoadUserDetails(user.login)),
                                child: UserDetailsScreen(user: user),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(
                  child: Text('Search for GitHub users'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
