// This is a basic Flutter widget test for the Habit Tracker app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habit/main.dart';

void main() {
  testWidgets('Habit Tracker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('Habit Tracker'), findsOneWidget);
    
    // Verify that the input field is present
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Enter a habit'), findsOneWidget);
    
    // Verify that the add button is present
    expect(find.text('ADD HABIT'), findsOneWidget);
    
    // Verify that the empty state is shown initially
    expect(find.text('No habits yet!'), findsOneWidget);
    expect(find.text('Add your first habit to get started'), findsOneWidget);
  });

  testWidgets('Add habit functionality test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Enter a habit name
    await tester.enterText(find.byType(TextField), 'Exercise daily');
    await tester.pump();

    // Tap the add button
    await tester.tap(find.text('ADD HABIT'));
    await tester.pump();

    // Verify that the habit was added
    expect(find.text('Exercise daily'), findsOneWidget);
    expect(find.text('No habits yet!'), findsNothing);
    
    // Verify that the stats card appears
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);
  });

  testWidgets('Complete habit functionality test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Add a habit
    await tester.enterText(find.byType(TextField), 'Read books');
    await tester.tap(find.text('ADD HABIT'));
    await tester.pump();

    // Verify habit is not completed initially
    expect(find.text('0/1'), findsOneWidget);

    // Tap the checkbox to complete the habit
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    // Verify habit is now completed
    expect(find.text('1/1'), findsOneWidget);
    
    // Verify streak information appears
    expect(find.text('🔥 Current Streak: 1 days'), findsOneWidget);
    expect(find.text('🏆 Best Streak: 1 days'), findsOneWidget);
  });

  testWidgets('Delete habit functionality test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Add a habit
    await tester.enterText(find.byType(TextField), 'Test habit');
    await tester.tap(find.text('ADD HABIT'));
    await tester.pump();

    // Verify habit was added
    expect(find.text('Test habit'), findsOneWidget);

    // Tap the delete button
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    // Verify delete confirmation dialog appears
    expect(find.text('Delete Habit'), findsOneWidget);
    expect(find.text('Are you sure you want to delete "Test habit"?'), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.text('Delete'));
    await tester.pump();

    // Verify habit was deleted
    expect(find.text('Test habit'), findsNothing);
    expect(find.text('No habits yet!'), findsOneWidget);
  });
}
