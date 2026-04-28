import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_buddy/catalog/workout_card.dart';

void main() {
  group('WorkoutCardWidget Tests', () {
    testWidgets('Displays title and exercise chips', (
      WidgetTester tester,
    ) async {
      final data = WorkoutCardData(
        title: 'Full Body Blast',
        exercises: ['10 Pushups', '20 Squats', '30s Plank'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutCard(data: data),
          ),
        ),
      );

      expect(find.text('FULL BODY BLAST'), findsOneWidget);
      expect(find.text('10 PUSHUPS'), findsOneWidget);
      expect(find.text('20 SQUATS'), findsOneWidget);
      expect(find.text('30S PLANK'), findsOneWidget);

      // Verify number of stacked exercise cards by finding 'EXERCISE 01', etc.
      expect(find.text('EXERCISE 01'), findsOneWidget);
      expect(find.text('EXERCISE 02'), findsOneWidget);
      expect(find.text('EXERCISE 03'), findsOneWidget);
    });
  });
}
