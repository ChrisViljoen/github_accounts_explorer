import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_accounts_explorer/core/di/service_locator.dart';
import 'package:github_accounts_explorer/data/models/github_repo.dart';
import 'package:github_accounts_explorer/data/models/github_user.dart';
import 'package:github_accounts_explorer/presentation/blocs/account_details/account_details_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/account_details/account_details_state.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/liked_users/liked_users_state.dart';
import 'package:github_accounts_explorer/presentation/blocs/repository/repository_bloc.dart';
import 'package:github_accounts_explorer/presentation/blocs/repository/repository_event.dart';
import 'package:github_accounts_explorer/presentation/blocs/repository/repository_state.dart';
import 'package:intl/intl.dart';

class AccountDetailsScreen extends StatelessWidget {
  final GitHubUser user;

  const AccountDetailsScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ServiceLocator.instance.createLikedUsersBloc()
            ..add(LoadLikedUsers()),
        ),
        BlocProvider(
          create: (context) => ServiceLocator.instance.createRepositoryBloc()
            ..add(LoadRepositories(user.login)),
        ),
      ],
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Repositories',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<RepositoryBloc, RepositoryState>(
          builder: (context, state) {
            if (state is RepositoryLoading) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            } else if (state is RepositoryError) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      state.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              );
            } else if (state is RepositoryLoaded) {
              if (state.repositories.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No repositories found'),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= state.repositories.length - 3 &&
                        !state.isLoadingMore &&
                        state.hasMore) {
                      Future.microtask(() {
                        context
                            .read<RepositoryBloc>()
                            .add(LoadMoreRepositories());
                      });
                    }

                    if (index == state.repositories.length) {
                      if (!state.hasMore) return null;

                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return _buildRepositoryCard(
                      context,
                      state.repositories[index],
                    );
                  },
                  childCount:
                      state.repositories.length + (state.hasMore ? 1 : 0),
                ),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          },
        ),
      ],
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

  Widget _buildRepositoryCard(BuildContext context, GitHubRepo repo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    repo.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                BlocBuilder<RepositoryBloc, RepositoryState>(
                  builder: (context, state) {
                    final bool isCopied = state is RepositoryLoaded &&
                        state.copiedUrl == repo.htmlUrl;
                    return IconButton(
                      icon: Icon(
                        isCopied ? Icons.check : Icons.copy,
                        color: isCopied ? Colors.green : null,
                      ),
                      onPressed: () {
                        context.read<RepositoryBloc>().add(
                              CopyRepositoryUrl(repo.htmlUrl),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Repository URL copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: 'Copy repository URL',
                    );
                  },
                ),
              ],
            ),
            if (repo.description != null) ...[
              const SizedBox(height: 8),
              Text(repo.description!),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (repo.language != null)
                  Chip(
                    label: Text(repo.language!),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                Text(
                  'Created ${DateFormat.yMMMd().format(repo.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRepoStat(Icons.star_border, repo.stargazersCount),
                _buildRepoStat(Icons.fork_right, repo.forksCount),
                _buildRepoStat(Icons.visibility_outlined, repo.watchersCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepoStat(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(count.toString()),
      ],
    );
  }
}
