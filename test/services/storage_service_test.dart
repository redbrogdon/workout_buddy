import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_buddy/models/workout_session.dart';
import 'package:workout_buddy/models/user_preferences.dart';
import 'package:workout_buddy/services/storage_service.dart';

void main() {
  late MemoryFileSystem fs;
  late StorageService storageService;
  const basePath = '/data';

  setUp(() {
    fs = MemoryFileSystem();
    fs.directory(basePath).createSync(recursive: true);
    storageService = FileStorageService(fs: fs, basePath: basePath);
  });

  group('StorageService - Active Session', () {
    test('Should save and read active session', () async {
      final session = WorkoutSessionRecord(createdTimestamp: DateTime(2024));
      await storageService.saveActiveSession(session);

      final recovered = await storageService.readActiveSession();
      expect(recovered, isNotNull);
      expect(recovered!.createdTimestamp, session.createdTimestamp);
    });

    test('Should clear active session', () async {
      final session = WorkoutSessionRecord(createdTimestamp: DateTime(2024));
      await storageService.saveActiveSession(session);
      await storageService.clearActiveSession();

      final recovered = await storageService.readActiveSession();
      expect(recovered, isNull);
    });
  });

  group('StorageService - History', () {
    test('Should append sessions to history (newest first)', () async {
      final session1 = WorkoutSessionRecord(
        createdTimestamp: DateTime(2024, 1, 1),
        overallFeedback: 'One',
      );
      final session2 = WorkoutSessionRecord(
        createdTimestamp: DateTime(2024, 1, 2),
        overallFeedback: 'Two',
      );

      await storageService.saveToHistory(session1);
      await storageService.saveToHistory(session2);

      final history = await storageService.readHistory();
      expect(history.length, 2);
      expect(history[0].overallFeedback, 'Two'); // Newest first
      expect(history[1].overallFeedback, 'One');
    });
  });

  group('StorageService - Preferences', () {
    test('Should save and read preferences', () async {
      final prefs = UserPreferences(description: 'I like dogs');
      await storageService.savePreferences(prefs);

      final recovered = await storageService.readPreferences();
      expect(recovered.description, 'I like dogs');
    });

    test('Should return empty preferences if file missing', () async {
      final recovered = await storageService.readPreferences();
      expect(recovered.description, '');
    });

    test('Should return default prefs on corrupted JSON', () async {
      final file = fs.file('$basePath/user_preferences.json');
      await file.writeAsString('["not a map"]');
      final prefs = await storageService.readPreferences();
      expect(prefs.description, isEmpty);
    });
  });

  group('StorageService - Corruption Resilience', () {
    test('Should return empty history on corrupted JSON', () async {
      final file = fs.file('$basePath/workout_history.json');
      await file.writeAsString('{ invalid json }');
      final history = await storageService.readHistory();
      expect(history, isEmpty);
    });
  });
}
