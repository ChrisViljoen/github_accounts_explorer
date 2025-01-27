import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_accounts_explorer/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('Search and like user flow', (tester) async {
      await tester.pumpWidget(const GitHubExplorerApp());
      await tester.pumpAndSettle();

      // Find and tap search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Wait for search results
      await tester.pump(const Duration(seconds: 2));

      // Verify search results appear
      expect(find.byType(ListTile), findsWidgets);

      // Tap first result
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Verify account details screen
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);

      // Find and verify the like button in the app bar
      final likeButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.favorite_border),
      );
      expect(likeButton, findsOneWidget);
      await tester.tap(likeButton);
      await tester.pumpAndSettle();

      // Verify like status changed in the app bar
      final filledLikeButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.favorite),
      );
      expect(filledLikeButton, findsOneWidget);

      // Navigate back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify liked user appears in home screen
      expect(find.byIcon(Icons.favorite), findsWidgets);
    });
  });
}
