import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo/services/theme_provider.dart';

import 'package:flutter_todo/main.dart';

void main() {
  testWidgets('Todo app smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const GlassTodoApp(),
      ),
    );
    await tester.pumpAndSettle(); // Wait for FutureBuilder/loading to finish

    // Verify that the empty state is shown.
    expect(find.text('No tasks yet!'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget); // FAB

    // Enter a new task via FAB
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(); // Navigat to TaskEditor

    // Find input in TaskEditorPage
    await tester.enterText(find.byType(TextField).first, 'Buy Milk');

    // Tap Save
    await tester.tap(find.text('Save Task'));
    await tester.pumpAndSettle(); // Navigate back

    // Verify task is added
    expect(find.text('Buy Milk'), findsOneWidget);
    expect(find.text('No tasks yet!'), findsNothing);
  });
}
