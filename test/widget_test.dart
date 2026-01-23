import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_todo/main.dart';

void main() {
  testWidgets('Todo app smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const GlassTodoApp());
    await tester.pumpAndSettle(); // Wait for FutureBuilder/loading to finish

    // Verify that the empty state is shown.
    expect(find.text('No tasks yet!'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle), findsOneWidget);

    // Enter a new task
    await tester.enterText(find.byType(TextField), 'Buy Milk');
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 300)); // Finish animation

    // Verify task is added
    expect(find.text('Buy Milk'), findsOneWidget);
    expect(find.text('No tasks yet!'), findsNothing);
  });
}
