import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_accounts_explorer/core/di/service_locator.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_state.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_details/user_details_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_search/user_search_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_search/user_search_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_search/user_search_state.dart';

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
          create: (context) => ServiceLocator.instance.createLikedUsersBloc()
            ..add(LoadLikedUsers()),
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
  final _storageService = ServiceLocator.instance.storageService;
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    _recentSearches = await _storageService.getRecentSearches();
    if (mounted) setState(() {});
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    _storageService.addRecentSearch(query);
    context.read<UserSearchBloc>().add(SearchUsers(query));
    _loadRecentSearches();
  }

  Widget _buildUserTile(BuildContext context, user) {
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
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) =>
                  ServiceLocator.instance.createUserDetailsBloc()
                    ..add(LoadUserDetails(user.login)),
              child: UserDetailsScreen(user: user),
            ),
          ),
        );
        // Refresh liked users state when returning from details screen
        if (context.mounted) {
          context.read<LikedUsersBloc>().add(LoadLikedUsers());
        }
      },
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search GitHub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter username...',
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
              onSubmitted: _onSearch,
            ),
            if (_recentSearches.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _recentSearches.map((query) {
                  return InputChip(
                    label: Text(query),
                    onPressed: () {
                      _searchController.text = query;
                      _onSearch(query);
                    },
                    onDeleted: () async {
                      await _storageService.removeRecentSearch(query);
                      _loadRecentSearches();
                    },
                  );
                }).toList(),
              ),
              TextButton.icon(
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Search History'),
                onPressed: () async {
                  await _storageService.clearRecentSearches();
                  _loadRecentSearches();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Accounts Explorer'),
        centerTitle: true,
      ),
      body: BlocBuilder<LikedUsersBloc, LikedUsersState>(
        builder: (context, likedState) {
          return CustomScrollView(
            slivers: [
              // Favorite Accounts Section
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Favorite Accounts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (likedState is LikedUsersLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (likedState is LikedUsersLoaded) ...[
                if (likedState.users.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No favorite accounts yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildUserTile(context, likedState.users[index]),
                      childCount: likedState.users.length,
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: Divider(height: 32),
                ),
              ],

              // Search Section with Recent Searches
              _buildSearchSection(),

              // Search Results Section
              BlocBuilder<UserSearchBloc, UserSearchState>(
                builder: (context, searchState) {
                  if (searchState is UserSearchLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (searchState is UserSearchError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          searchState.message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  } else if (searchState is UserSearchSuccess) {
                    if (searchState.users.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text('No users found'),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildUserTile(context, searchState.users[index]),
                        childCount: searchState.users.length,
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
