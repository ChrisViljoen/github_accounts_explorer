// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_accounts_explorer/main.dart';
import 'package:github_accounts_explorer/presentation/screens/home_screen.dart';

void main() {
  group('GitHub Explorer App Tests', () {
    testWidgets('App should render HomeScreen', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const GitHubExplorerApp());

      // Verify that HomeScreen is rendered
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify that search field is present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search GitHub users...'), findsOneWidget);
    });
  });
}
