import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  ServiceLocator.instance;
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
