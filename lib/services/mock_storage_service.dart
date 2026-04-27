import 'dart:math';
import '../models/workout_session.dart';
import '../models/user_preferences.dart';
import 'storage_service.dart';

/// An in-memory implementation of [StorageService] for testing.
class MockStorageService implements StorageService {
  final List<WorkoutSessionRecord> _history;
  UserPreferences _prefs;

  MockStorageService({
    List<WorkoutSessionRecord>? initialHistory,
    UserPreferences? initialPrefs,
  }) : _history = initialHistory ?? [],
       _prefs = initialPrefs ?? UserPreferences(description: '');

  /// Creates a [MockStorageService] populated with several days of test data.
  factory MockStorageService.withSeedData() {
    final history = _generateSeedData();
    return MockStorageService(
      initialHistory: history,
      initialPrefs: UserPreferences(
        description:
            'I am inexperienced with exercising, and my goal is to lose weight and gain a measure of strength.',
      ),
    );
  }

  static List<WorkoutSessionRecord> _generateSeedData() {
    final now = DateTime.now();
    final random = Random();
    final history = <WorkoutSessionRecord>[];

    final workoutNames = [
      'Full Body Blast',
      'Lower Body Power',
      'Upper Body Strength',
      'Core Crusher',
      'Morning Mobility',
    ];

    final exercisePool = [
      {'name': 'Pushups', 'reps': 15, 'timed': false},
      {'name': 'Squats', 'reps': 20, 'timed': false},
      {'name': 'Plank', 'duration': 60, 'timed': true},
      {'name': 'Lunges', 'reps': 20, 'timed': false},
      {'name': 'Burpees', 'reps': 10, 'timed': false},
      {'name': 'Jumping Jacks', 'reps': 30, 'timed': false},
      {'name': 'Glute Bridges', 'reps': 15, 'timed': false},
      {'name': 'Mountain Climbers', 'reps': 20, 'timed': false},
    ];

    // Seed 60 days (approx 2 months) of history
    for (int i = 59; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // 75% chance of working out on any given day
      if (random.nextDouble() > 0.75) continue;

      // Some days have two workouts (10% chance)
      int numWorkouts = random.nextDouble() > 0.9 ? 2 : 1;

      for (int w = 0; w < numWorkouts; w++) {
        final sessionDate = DateTime(
          date.year,
          date.month,
          date.day,
          (w == 0 ? 17 : 8) + random.nextInt(2), // Evening or morning
        );

        final exercises = <ExerciseRecord>[];
        final numExercises = 3 + random.nextInt(3);
        final pickedExercises = (List.from(exercisePool)..shuffle()).take(
          numExercises,
        );

        for (final ex in pickedExercises) {
          final timed = ex['timed'] as bool;
          exercises.add(
            ExerciseRecord(
              name: ex['name'] as String,
              suggestedDuration: timed ? ex['duration'] as int : 0,
              numberOfReps: timed ? 0 : ex['reps'] as int,
              actualDuration: timed
                  ? (ex['duration'] as int) + random.nextInt(10)
                  : 0,
              repsCompleted: timed
                  ? 0
                  : (ex['reps'] as int) + random.nextInt(5),
              exerciseFeedback: 'Felt great!',
              completedTimestamp: sessionDate.add(const Duration(minutes: 5)),
              wasSkipped: false,
            ),
          );
        }

        history.add(
          WorkoutSessionRecord(
            id: 'mock_session_${i}_$w',
            createdTimestamp: sessionDate.subtract(const Duration(minutes: 10)),
            startedTimestamp: sessionDate,
            completedTimestamp: sessionDate.add(const Duration(minutes: 20)),
            overallFeedback: 'A solid workout session.',
            exercises: exercises,
          ),
        );
      }
    }

    return history;
  }

  @override
  Future<void> saveToHistory(WorkoutSessionRecord session) async {
    final index = _history.indexWhere((e) => e.id == session.id);
    if (index >= 0) {
      _history[index] = session;
    } else {
      _history.insert(0, session);
    }
  }

  @override
  Future<List<WorkoutSessionRecord>> readHistory() async {
    return List.from(_history);
  }

  @override
  Future<void> savePreferences(UserPreferences prefs) async {
    _prefs = prefs;
  }

  @override
  Future<UserPreferences> readPreferences() async {
    return _prefs;
  }
}
