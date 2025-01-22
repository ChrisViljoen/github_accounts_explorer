import 'package:flutter/material.dart';
import 'package:github_accounts_explorer/core/config/env_config.dart';
import 'package:github_accounts_explorer/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.instance.init();

  runApp(const GitHubExplorerApp());
}

class GitHubExplorerApp extends StatelessWidget {
  const GitHubExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Accounts Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
