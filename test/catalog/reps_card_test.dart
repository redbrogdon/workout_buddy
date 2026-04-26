import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_buddy/catalog/reps_card.dart';

void main() {
  group('RepsCardWidget Tests', () {
    late RepsCardData testData;

    setUp(() {
      testData = RepsCardData(
        exercise: 'Pushups',
        instructions: 'Go low.',
        numberOfReps: 10,
        isCompleted: false,
      );
    });

    testWidgets('Displays initial data correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RepsCard(
            data: testData,
            onCompleted: (_) {},
          ),
        ),
      ));

      expect(find.text('Pushups'), findsOneWidget);
      expect(find.byKey(const ValueKey('target_reps')), findsOneWidget);
      expect(find.byKey(const ValueKey('reps_completed_text')), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const ValueKey('target_reps'))).data, '10');
      expect(tester.widget<Text>(find.byKey(const ValueKey('reps_completed_text'))).data, '10');
    });

    testWidgets('Increments and decrements reps', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RepsCard(
            data: testData,
            onCompleted: (_) {},
          ),
        ),
      ));

      // Initial state is 10
      expect(find.byKey(const ValueKey('reps_completed_text')), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const ValueKey('reps_completed_text'))).data, '10');

      // Increment
      await tester.tap(find.byKey(const ValueKey('increment_reps')));
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const ValueKey('reps_completed_text'))).data, '11');

      // Decrement twice
      await tester.tap(find.byKey(const ValueKey('decrement_reps')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('decrement_reps')));
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const ValueKey('reps_completed_text'))).data, '9');
    });

    testWidgets('Complete button dispatches actual reps', (WidgetTester tester) async {
      int? capturedReps;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RepsCard(
            data: testData,
            onCompleted: (reps) => capturedReps = reps,
          ),
        ),
      ));

      // Change reps to 15
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const ValueKey('increment_reps')));
      }
      await tester.pump();

      // Press Complete
      await tester.tap(find.byKey(const ValueKey('complete_button')));
      await tester.pump();

      expect(capturedReps, 15);
    });
    group('Edge Cases', () {
    testWidgets('Buttons are disabled when isCompleted is true', (WidgetTester tester) async {
      final completedData = RepsCardData(
        exercise: 'Pushups',
        instructions: 'Done.',
        numberOfReps: 10,
        isCompleted: true,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RepsCard(
            data: completedData,
            onCompleted: (_) {},
          ),
        ),
      ));

      // Attempt to tap increment
      await tester.tap(find.byKey(const ValueKey('increment_reps')));
      await tester.pump();
      expect(tester.widget<Text>(find.byKey(const ValueKey('reps_completed_text'))).data, '10');

      // Check if IconButton onPressed is null (disabled)
      final incrementButton = tester.widget<IconButton>(find.byKey(const ValueKey('increment_reps')));
      expect(incrementButton.onPressed, isNull);
    });
  });
  });
}
