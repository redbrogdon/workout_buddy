import 'package:flutter_test/flutter_test.dart';
import 'package:workout_buddy/models/workout_session.dart';
import 'package:workout_buddy/models/user_preferences.dart';

void main() {
  group('WorkoutSessionRecord Serialization', () {
    test('Should survive round-trip JSON serialization', () {
      final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
      final session = WorkoutSessionRecord(
        createdTimestamp: now,
        startedTimestamp: now.add(const Duration(minutes: 5)),
        completedTimestamp: now.add(const Duration(minutes: 35)),
        overallFeedback: 'Great workout!',
        exercises: [
          ExerciseRecord(
            name: 'Pushups',
            numberOfReps: 15,
            repsCompleted: 15,
            completedTimestamp: now.add(const Duration(minutes: 10)),
          ),
          ExerciseRecord(
            name: 'Plank',
            suggestedDuration: 60,
            actualDuration: 45,
            exerciseFeedback: 'Hard today',
            wasSkipped: false,
          ),
        ],
      );

      final json = session.toJson();
      final roundTrip = WorkoutSessionRecord.fromJson(json);

      expect(roundTrip.createdTimestamp, session.createdTimestamp);
      expect(roundTrip.startedTimestamp, session.startedTimestamp);
      expect(roundTrip.completedTimestamp, session.completedTimestamp);
      expect(roundTrip.overallFeedback, session.overallFeedback);
      expect(roundTrip.exercises.length, session.exercises.length);
      expect(roundTrip.exercises[0].name, 'Pushups');
      expect(roundTrip.exercises[1].actualDuration, 45);
      expect(roundTrip.exercises[1].wasSkipped, false);
    });
  });

  group('UserPreferences Serialization', () {
    test('Should survive round-trip JSON serialization', () {
      final prefs = UserPreferences(
        description: 'I like high intensity training.',
      );

      final json = prefs.toJson();
      final roundTrip = UserPreferences.fromJson(json);

      expect(roundTrip.description, prefs.description);
    });
  });
}
