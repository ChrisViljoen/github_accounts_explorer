import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_accounts_explorer/data/models/github_user.dart';
import 'package:github_accounts_explorer/presentation/blocs/account_details/account_details_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/account_details/account_details_state.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_state.dart';
import 'package:github_accounts_explorer/core/di/service_locator.dart';

class AccountDetailsScreen extends StatelessWidget {
  final GitHubUser user;

  const AccountDetailsScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.instance.createLikedUsersBloc()..add(LoadLikedUsers()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(user.login),
          centerTitle: true,
          actions: [
            BlocBuilder<LikedUsersBloc, LikedUsersState>(
              builder: (context, state) {
                final bool isLiked = state is LikedUsersLoaded && 
                                   state.likedUserIds.contains(user.id);
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
          ],
        ),
        body: BlocBuilder<AccountDetailsBloc, AccountDetailsState>(
          builder: (context, state) {
            if (state is AccountDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AccountDetailsError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            } else if (state is AccountDetailsLoaded) {
              return _buildAccountDetails(context, state.user);
            }
            return _buildAccountDetails(context, user);
          },
        ),
      ),
    );
  }

  Widget _buildAccountDetails(BuildContext context, GitHubUser user) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? user.login,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.type,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bio Section
          if (user.bio != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                user.bio!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],

          // Stats Section
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Repositories',
                  user.publicRepos?.toString() ?? '0',
                ),
                _buildStatItem(
                  context,
                  'Followers',
                  user.followers?.toString() ?? '0',
                ),
                _buildStatItem(
                  context,
                  'Following',
                  user.following?.toString() ?? '0',
                ),
              ],
            ),
          ),
          const Divider(),

          // Repositories Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Repositories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // TODO: Add repositories list
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
