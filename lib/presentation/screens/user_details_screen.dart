import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_accounts_explorer/data/models/github_user.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_details/user_details_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/user_details/user_details_state.dart';

class UserDetailsScreen extends StatelessWidget {
  final GitHubUser user;

  const UserDetailsScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.login),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Implement like functionality
            },
          ),
        ],
      ),
      body: BlocBuilder<UserDetailsBloc, UserDetailsState>(
        builder: (context, state) {
          if (state is UserDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserDetailsError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          } else if (state is UserDetailsLoaded) {
            return _buildUserDetails(context, state.user);
          }
          return _buildUserDetails(context, user);
        },
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context, GitHubUser user) {
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
