import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_buddy/catalog/workout_card.dart';

void main() {
  group('WorkoutCardWidget Tests', () {
    testWidgets('Displays title and exercise chips', (WidgetTester tester) async {
      final data = WorkoutCardData(
        title: 'Full Body Blast',
        exercises: ['10 Pushups', '20 Squats', '30s Plank'],
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: WorkoutCard(data: data),
        ),
      ));

      expect(find.text('Full Body Blast'), findsOneWidget);
      expect(find.text('10 Pushups'), findsOneWidget);
      expect(find.text('20 Squats'), findsOneWidget);
      expect(find.text('30s Plank'), findsOneWidget);

      // Verify number of chips
      expect(find.byType(Chip), findsNWidgets(3));
    });
  });
}
