// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alfred/main.dart';

void main() {
  testWidgets('Habit tracker app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const HabitApp());

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify the app title is displayed
    expect(find.text('Habit Tracker'), findsOneWidget);

    // Verify the input field is present
    expect(find.byType(TextField), findsOneWidget);

    // Verify the add button is present
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
