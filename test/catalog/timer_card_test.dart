import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_buddy/catalog/timer_card.dart';

void main() {
  group('TimerCardWidget Tests', () {
    late TimerCardData testData;

    setUp(() {
      testData = TimerCardData(
        exercise: 'Plank',
        instructions: 'Stay flat.',
        suggestedDuration: 60,
        actualDuration: 0,
        isCompleted: false,
      );
    });

    testWidgets('Displays initial data correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimerCard(
            data: testData,
            onCompleted: (_) {},
          ),
        ),
      ));

      expect(find.text('Plank'), findsOneWidget);
      expect(find.text('Stay flat.'), findsOneWidget);
      expect(find.text('Suggested Duration: 60s'), findsOneWidget);
      expect(find.text('0s'), findsOneWidget);
    });

    testWidgets('Timer increments when play is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimerCard(
            data: testData,
            onCompleted: (_) {},
          ),
        ),
      ));

      // Press Play
      await tester.tap(find.byKey(const ValueKey('toggle_timer')));
      await tester.pump();

      // Wait 2 seconds
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('2s'), findsOneWidget);

      // Press Pause
      await tester.tap(find.byKey(const ValueKey('toggle_timer')));
      await tester.pump();

      // Wait another 2 seconds, should stay at 2s
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('2s'), findsOneWidget);
    });

    testWidgets('Reset button clears duration', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimerCard(
            data: testData,
            onCompleted: (_) {},
          ),
        ),
      ));

      // Press Play and wait
      await tester.tap(find.byKey(const ValueKey('toggle_timer')));
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('5s'), findsOneWidget);

      // Press Reset
      await tester.tap(find.byKey(const ValueKey('reset_timer')));
      await tester.pump();

      expect(find.text('0s'), findsOneWidget);
    });

    testWidgets('Complete button calls onCompleted with actual duration', (WidgetTester tester) async {
      int? capturedDuration;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimerCard(
            data: testData,
            onCompleted: (duration) => capturedDuration = duration,
          ),
        ),
      ));

      // Run timer for 10 seconds
      await tester.tap(find.byKey(const ValueKey('toggle_timer')));
      await tester.pump(const Duration(seconds: 10));

      // Press Complete
      await tester.tap(find.byKey(const ValueKey('complete_button')));
      await tester.pump();

      expect(capturedDuration, 10);
    });
  });
}
