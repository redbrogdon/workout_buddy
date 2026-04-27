import 'package:flutter_test/flutter_test.dart';
import 'package:workout_buddy/models/workout_session.dart';
import 'package:workout_buddy/models/user_preferences.dart';
import 'package:workout_buddy/services/mock_storage_service.dart';

void main() {
  group('MockStorageService', () {
    late MockStorageService service;

    setUp(() {
      service = MockStorageService();
    });

    test('starts empty', () async {
      final history = await service.readHistory();
      final prefs = await service.readPreferences();
      expect(history, isEmpty);
      expect(prefs.description, isEmpty);
    });

    test('saves and reads history', () async {
      final session = WorkoutSessionRecord(
        id: 'test_id',
        createdTimestamp: DateTime.now(),
      );
      await service.saveToHistory(session);
      final history = await service.readHistory();
      expect(history.length, 1);
      expect(history.first.id, 'test_id');
    });

    test('updates existing session', () async {
      final session1 = WorkoutSessionRecord(
        id: 'id1',
        createdTimestamp: DateTime.now(),
        overallFeedback: 'first',
      );
      final session2 = WorkoutSessionRecord(
        id: 'id1',
        createdTimestamp: DateTime.now(),
        overallFeedback: 'second',
      );
      await service.saveToHistory(session1);
      await service.saveToHistory(session2);
      final history = await service.readHistory();
      expect(history.length, 1);
      expect(history.first.overallFeedback, 'second');
    });

    test('saves and reads preferences', () async {
      final prefs = UserPreferences(description: 'my prefs');
      await service.savePreferences(prefs);
      final readPrefs = await service.readPreferences();
      expect(readPrefs.description, 'my prefs');
    });

    test('withSeedData populates history', () async {
      final seededService = MockStorageService.withSeedData();
      final history = await seededService.readHistory();
      final prefs = await seededService.readPreferences();
      expect(history, isNotEmpty);
      // We expect roughly 60 * 0.75 * 1.1 = ~50 workouts
      expect(history.length, greaterThan(10));
      expect(history.length, lessThan(120));
      expect(prefs.description, contains('inexperienced with exercising'));
    });
  });
}
