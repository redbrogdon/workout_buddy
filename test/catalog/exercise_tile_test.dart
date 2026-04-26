import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_buddy/catalog/exercise_tile.dart';

void main() {
  testWidgets('ExerciseTile displays name and details correctly', (
    WidgetTester tester,
  ) async {
    final data = ExerciseTileData(
      name: 'Pushups',
      sets: 3,
      repetitions: 10,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseTile(
            data: data,
            onDelete: () {},
            onReplace: () {},
          ),
        ),
      ),
    );

    expect(find.text('Pushups'), findsOneWidget);
    expect(find.text('3 sets of 10 reps'), findsOneWidget);
  });

  testWidgets('ExerciseTile displays duration correctly', (
    WidgetTester tester,
  ) async {
    final data = ExerciseTileData(
      name: 'Plank',
      sets: 1,
      duration: 60,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseTile(
            data: data,
            onDelete: () {},
            onReplace: () {},
          ),
        ),
      ),
    );

    expect(find.text('1 sets for 60s'), findsOneWidget);
  });

  testWidgets('Interactions trigger callbacks', (WidgetTester tester) async {
    bool deleteCalled = false;
    bool replaceCalled = false;

    final data = ExerciseTileData(name: 'Bench Press');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseTile(
            data: data,
            onDelete: () => deleteCalled = true,
            onReplace: () => replaceCalled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(deleteCalled, true);

    await tester.tap(find.byIcon(Icons.swap_horiz));
    expect(replaceCalled, true);
  });
}
